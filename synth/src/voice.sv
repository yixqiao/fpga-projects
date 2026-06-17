module voice (
    input logic clk, rst,

    // Params
    input logic [1:0] wave_sel,
    input logic detune_sel,
    input logic [2:0] vol_shift,
    input logic [4:0] vol_a_shift, vol_d_shift, vol_r_shift,
    input logic [11:0] vol_s_level,
    input logic [15:0] filter_F_floor,
    input logic [15:0] filter_k,
    input logic [15:0] filter_F_env_amount,
    input logic [4:0] filter_a_shift, filter_d_shift, filter_r_shift,
    input logic [11:0] filter_s_level,

    // Note recorder
    input logic note_tick, sample_tick,
    input logic pulse_play_stop, pulse_edit, pulse_bar_left, pulse_bar_right, btn_clear_reset,
    input logic rotary_pulse_pos, rotary_pulse_neg,
    input logic [7:0] midi_in,

    output logic [15:0] led,
    output logic [3:0] bar_count,
    output logic is_editing,
    output logic [23:0] sample_out
);
    logic adsr_gate;
    logic [7:0] midi_final;

    note_recorder nr (
        .clk, .rst,
        .note_tick, .sample_tick,
        .pulse_play_stop, .pulse_edit, .pulse_left(rotary_pulse_neg), .pulse_right(rotary_pulse_pos),
        .sw_clear_reset(btn_clear_reset),
        .pulse_bar_left, .pulse_bar_right,
        .midi_in, .midi_out(midi_final),
        .led, .bar_count,
        .is_editing
    );

    logic [23:0] inc, sample_wave, sample_svf, sample_vol;
    logic [23:0] inc_raw, inc_latched;
    note_midi_inc inc_default (.midi(midi_final), .detune(2'b00), .inc(inc_raw));
    always_ff @(posedge clk) begin
        if (rst) inc_latched <= '0;
        else if (inc_raw != 24'h000000) inc_latched <= inc_raw;
    end
    assign inc = inc_latched;

    logic [23:0] inc_raw_lower, inc_latched_lower;
    note_midi_inc inc_lower (.midi(midi_final), .detune(2'b10), .inc(inc_raw_lower));
    always_ff @(posedge clk) begin
        if (rst) inc_latched_lower <= '0;
        else if (inc_raw_lower != 24'h000000) inc_latched_lower <= inc_raw_lower;
    end
    logic [23:0] inc_raw_higher, inc_latched_higher;
    note_midi_inc inc_higher (.midi(midi_final), .detune(2'b01), .inc(inc_raw_higher));
    always_ff @(posedge clk) begin
        if (rst) inc_latched_higher <= '0;
        else if (inc_raw_higher != 24'h000000) inc_latched_higher <= inc_raw_higher;
    end


    assign adsr_gate = midi_final != 8'hFF;
    
    // Get phase (output phase)
    logic [23:0] phase;
    phase_acc #(.W(24)) nco (
        .clk, .rst,
        .tick(sample_tick), .inc,
        .phase
    );
    logic [23:0] phase_lower, phase_higher;
    phase_acc #(.W(24)) nco_lower (
        .clk, .rst,
        .tick(sample_tick), .inc(inc_latched_lower),
        .phase(phase_lower)
    );
    phase_acc #(.W(24)) nco_higher (
        .clk, .rst,
        .tick(sample_tick), .inc(inc_latched_higher),
        .phase(phase_higher)
    );

    // Get waveform (output sample_wave)
    waveform_gen wave_gen (.phase, .wave_sel, .sample(sample_wave));

    logic [23:0] sample_wave_lower, sample_wave_higher, sample_wave_detune;
    waveform_gen wave_gen_lower (.phase(phase_lower), .wave_sel, .sample(sample_wave_lower));
    waveform_gen wave_gen_higher (.phase(phase_higher), .wave_sel, .sample(sample_wave_higher));

    always_comb begin
        if (detune_sel) sample_wave_detune = ($signed(sample_wave)>>>1) + ($signed(sample_wave_lower)>>>2) + ($signed(sample_wave_higher)>>>2);
        else sample_wave_detune = ($signed(sample_wave)>>>1);
    end
    
    
    // Envelope (output sample_env)
    logic [11:0] env_level;
    logic [23:0] sample_env;
    envelope_adsr env_adsr (
        .clk, .rst, .gate(adsr_gate), .sample_tick,
        .a_shift(vol_a_shift), .d_shift(vol_d_shift), .r_shift(vol_r_shift), .s_level(vol_s_level),
        .env_level
    );
    
    logic signed [23:0] s1_reg;
    logic signed [12:0] env_reg;
    logic signed [36:0] mult_reg;
    (* use_dsp48 = "yes" *)
    always_ff @(posedge clk) begin
        if (rst) begin
            s1_reg   <= '0;
            env_reg  <= '0;
            mult_reg <= '0;
            sample_env <= '0;
        end else begin
            s1_reg   <= sample_wave_detune; // AREG stage
            env_reg  <= {1'b0, env_level}; // BREG stage
            mult_reg <= s1_reg * env_reg; // MREG stage
            sample_env <= mult_reg >>> 12; // PREG stage
        end
    end

    // Filter envelope (output F)
    logic [11:0] filter_env_level;
    envelope_adsr fitler_env_adsr (
        .clk, .rst, .gate(adsr_gate), .sample_tick,
        .a_shift(filter_a_shift), .d_shift(filter_d_shift), .r_shift(filter_r_shift), .s_level(filter_s_level),
        .env_level(filter_env_level)
    );

    logic signed [15:0] f_mod_reg;    // AREG: mod cutoff
    logic signed [12:0] env_f_reg;     // BREG: zero-extended filter_env_level
    logic signed [28:0] f_mult_reg;    // MREG: 16+13 = 28-bit product
    logic signed [15:0] F;             // PREG: final F after scale-back
    logic signed [15:0] f_floor;
    assign f_floor = filter_F_floor;

    (* use_dsp48 = "yes" *)
    always_ff @(posedge clk) begin
        if (rst) begin
            f_mod_reg <= '0;
            env_f_reg  <= '0;
            f_mult_reg <= '0;
            F          <= '0;
        end else begin
            f_mod_reg <= filter_F_env_amount;  // AREG
            env_f_reg  <= $signed({1'b0, filter_env_level});       // BREG: unsigned→signed
            f_mult_reg <= f_mod_reg * env_f_reg;           // MREG
            F          <= (f_mult_reg >>> 12);                // PREG
        end
    end


    // Filter (output sample_svf)
    // Right shift by two before filter
    audio_svf svf (
        .clk, .rst, .sample_tick,
        .sample_in($signed(sample_env) >>> 2), .F(F + f_floor), .k(filter_k), .filt_sel(2'b00),
        .sample_out(sample_svf)
    );

    // Volume control (output sample_vol)
    // Left shift by 1 before volume control
    audio_volume_control voice_vol_control (.vol_shift(vol_shift), .sample_in(sample_svf <<< 1), .sample_out(sample_vol));

    assign sample_out = sample_vol;
endmodule