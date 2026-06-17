module top (
    input logic clk,
    input logic [15:0] sw,
    input logic btnC, btnU, btnL, btnR, btnD,
    input logic enc_a, enc_b,
    input logic PS2Clk, PS2Data,
    output logic [15:0] led,
    output logic [6:0] seg,
    output logic dp,
    output logic [3:0] an,
    output logic mclk, bclk, lrclk, sdin
);
    logic rst;
    logic sample_tick;
    logic [23:0] phase;

    logic [23:0] inc;
    logic [23:0] sample_wave, sample_wave_detune, sample_env, sample_svf, sample_vol;

    logic is_editing;

    // Reset gen
    rst_gen rg (.clk, .rst);

    // Switch: volume 9:8, waveform 7:6, filter 5:4, ADSR 3:0

    // PS2 input (output scancode, valid)
    logic [7:0] ps2_scancode;
    logic ps2_valid;
    io_ps2_rx ps2 (.clk, .rst, .ps2_clk(PS2Clk), .ps2_data(PS2Data), .scancode(ps2_scancode), .valid(ps2_valid));
    
    // Controls
    logic rotary_pulse_pos, rotary_pulse_neg;
    io_rotary_decoder rot_dec (.clk, .rst, .enc_a, .enc_b, .pulse_pos(rotary_pulse_pos), .pulse_neg(rotary_pulse_neg));

    logic [1:0] wave_sel;
    logic detune_sel;
    logic [2:0] vol_shift;
    logic [4:0] vol_a_shift, vol_d_shift, vol_r_shift;
    logic [11:0] vol_s_level;
    logic [15:0] filter_F_floor;
    logic [15:0] filter_k;
    logic [15:0] filter_F_env_amount;
    logic [4:0] filter_a_shift, filter_d_shift, filter_r_shift;
    logic [11:0] filter_s_level;

    logic [2:0] global_vol_shift;

    logic [3:0] control_digit_value;

    control_params control (
        .clk, .rst,
        .sw,
        .rotary_pulse_pos(!is_editing && rotary_pulse_pos), .rotary_pulse_neg(!is_editing && rotary_pulse_neg),
        .wave_sel, .detune_sel,
        .vol_shift, .vol_a_shift, .vol_d_shift, .vol_r_shift,
        .vol_s_level,
        .filter_F_floor, .filter_k, .filter_F_env_amount,
        .filter_a_shift, .filter_d_shift, .filter_r_shift, .filter_s_level,
        .global_vol_shift,
        .digit_value(control_digit_value)
    );


    // Note recorder (output inc, adsr_gate, leds)
    logic adsr_gate;
    logic pulse_play_stop, pulse_edit, pulse_bar_left, pulse_bar_right, btn_clear_reset;
    io_btn_debouncer db_pulse_play_stop(.clk, .rst, .in(btnC), .out(), .pulse_pos(pulse_play_stop), .pulse_neg());
    io_btn_debouncer db_pulse_edit(.clk, .rst, .in(btnU), .out(), .pulse_pos(pulse_edit), .pulse_neg());
    io_btn_debouncer db_pulse_bar_left(.clk, .rst, .in(btnL), .out(), .pulse_pos(pulse_bar_left), .pulse_neg());
    io_btn_debouncer db_pulse_bar_right(.clk, .rst, .in(btnR), .out(), .pulse_pos(pulse_bar_right), .pulse_neg());
    io_btn_debouncer db_btn_clear_reset(.clk, .rst, .in(btnD), .out(btn_clear_reset), .pulse_pos(), .pulse_neg());

    logic note_tick;
    clk_divider #(.DIV(12_500_000)) note_div (.clk, .rst, .tick(note_tick));

    logic [7:0] midi_from_keyboard, midi_from_keyboard_raw;
    note_ps2_midi ps2_to_midi(.clk, .rst, .scancode(ps2_scancode), .valid(ps2_valid), .midi(midi_from_keyboard_raw)); // PS2 to midi
    always_comb begin
        case (sw[1:0])
            2'b00: midi_from_keyboard = midi_from_keyboard_raw - 12;
            2'b01: midi_from_keyboard = midi_from_keyboard_raw;
            2'b10: midi_from_keyboard = midi_from_keyboard_raw + 12;
            2'b11: midi_from_keyboard = midi_from_keyboard_raw + 24;
        endcase
    end

    logic [3:0] bar_count;

    logic [7:0] midi_final;

    note_recorder nr (
        .clk, .rst,
        .note_tick, .sample_tick,
        .pulse_play_stop, .pulse_edit, .pulse_left(is_editing && rotary_pulse_neg), .pulse_right(is_editing && rotary_pulse_pos),
        .sw_clear_reset(btn_clear_reset),
        .pulse_bar_left, .pulse_bar_right,
        .midi_in(midi_from_keyboard), .midi_out(midi_final),
        .led, .bar_count,
        .is_editing
    );

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

    logic [23:0] sample_wave_lower, sample_wave_higher;
    waveform_gen wave_gen_lower (.phase(phase_lower), .wave_sel, .sample(sample_wave_lower));
    waveform_gen wave_gen_higher (.phase(phase_higher), .wave_sel, .sample(sample_wave_higher));

    always_comb begin
        if (detune_sel) sample_wave_detune = ($signed(sample_wave)>>>1) + ($signed(sample_wave_lower)>>>2) + ($signed(sample_wave_higher)>>>2);
        else sample_wave_detune = ($signed(sample_wave)>>>1);
    end
    
    
    // Envelope (output sample_env)
    logic [11:0] env_level;
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
    audio_volume_control global_vol_control (.vol_shift(global_vol_shift), .sample_in(sample_svf <<< 1), .sample_out(sample_vol));

    // Transmit to I2S
    io_i2s_tx tx (
        .clk, .rst,
        .left(sample_vol), .right(sample_vol),
        .sample_req(sample_tick),
        .mclk, .bclk, .lrclk, .sdin
    );


    // Output to 7seg
    seg7_mux4 seg7 (
        .clk, .rst,
        .digit3(4'd10), .digit2(control_digit_value), .digit1(4'd10), .digit0(bar_count + 4'd1), .dps(4'b0011),
        .seg, .dp, .an
    );
endmodule