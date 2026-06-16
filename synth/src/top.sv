module top (
    input logic clk,
    input logic [9:0] sw,
    input logic btnC, btnU, btnL, btnR, btnD,
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
    logic [23:0] sample_wave, sample_env, sample_svf, sample_vol;

    // Reset gen
    rst_gen rg (.clk, .rst);

    // Switch: volume 9:8, waveform 7:6, filter 5:4, ADSR 3:0

    // PS2 input (output scancode, valid)
    logic [7:0] ps2_scancode;
    logic ps2_valid;
    io_ps2_rx ps2 (.clk, .rst, .ps2_clk(PS2Clk), .ps2_data(PS2Data), .scancode(ps2_scancode), .valid(ps2_valid));


    // Note recorder (output inc, adsr_gate, leds)
    logic adsr_gate;
    logic pulse_play_stop, pulse_edit, pulse_left, pulse_right, pulse_clear_note;
    io_btn_debouncer db_pulse_play_stop(.clk, .rst, .in(btnC), .out(), .pulse_pos(pulse_play_stop), .pulse_neg());
    io_btn_debouncer db_pulse_edit(.clk, .rst, .in(btnU), .out(), .pulse_pos(pulse_edit), .pulse_neg());
    io_btn_debouncer db_pulse_left(.clk, .rst, .in(btnL), .out(), .pulse_pos(pulse_left), .pulse_neg());
    io_btn_debouncer db_pulse_right(.clk, .rst, .in(btnR), .out(), .pulse_pos(pulse_right), .pulse_neg());
    io_btn_debouncer db_pulse_clear_note(.clk, .rst, .in(btnD), .out(), .pulse_pos(pulse_clear_note), .pulse_neg());

    logic note_tick;
    clk_divider #(.DIV(12_500_000)) note_div (.clk, .rst, .tick(note_tick));

    logic [7:0] midi_from_keyboard;
    note_ps2_midi ps2_to_midi(.clk, .rst, .scancode(ps2_scancode), .valid(ps2_valid), .midi(midi_from_keyboard)); // PS2 to midi

    logic [3:0] bar_count;

    note_recorder nr (
        .clk, .rst,
        .note_tick, .sample_tick,
        .pulse_play_stop, .pulse_edit, .pulse_left, .pulse_right, .pulse_clear_note,
        .midi_in(midi_from_keyboard), .inc, .gate(adsr_gate),
        .led, .bar_count
    );
    
    // Get phase (output phase)
    phase_acc #(.W(24)) nco (
        .clk, .rst,
        .tick(sample_tick), .inc,
        .phase
    );

    // Get waveform (output sample_wave)
    waveform_gen wave_gen (.phase, .wave_sel(sw[7:6]), .sample(sample_wave));

    // Envelope (output sample_env)
    logic [11:0] env_level;
    envelope_adsr env_adsr (
        .clk, .rst, .gate(adsr_gate), .sample_tick,
        .sel_a(sw[3]), .sel_d(sw[2]), .sel_s(sw[1]), .sel_r(sw[0]),
        .env_level
        );
    logic signed [23:0] s1_reg;
    logic signed [12:0] env_reg;
    logic signed [36:0] mult_reg;

    // TODO move envelope multiply into a separate module
    (* use_dsp48 = "yes" *)
    always_ff @(posedge clk) begin
        if (rst) begin
            s1_reg   <= '0;
            env_reg  <= '0;
            mult_reg <= '0;
            sample_env <= '0;
        end else begin
            s1_reg   <= sample_wave; // AREG stage
            env_reg  <= {1'b0, env_level}; // BREG stage
            mult_reg <= s1_reg * env_reg; // MREG stage
            sample_env <= mult_reg >>> 12; // PREG stage
        end
    end

    // F envelope modulation pipeline
    // F_final = F_mod * env_level >> 12
    // When env=0xFFF (max): F_final ≈ F_floor + F_mod (fully open)
    // When env=0x000 (off):  F_final = F_floor (filter closed)

    logic signed [15:0] f_mod_reg;    // AREG: mod cutoff
    logic signed [12:0] env_f_reg;     // BREG: zero-extended env_level
    logic signed [28:0] f_mult_reg;    // MREG: 16+13 = 28-bit product
    logic signed [15:0] F;             // PREG: final F after scale-back
    logic signed [15:0] f_floor;
    assign f_floor = sw[5] ? 16'sh1000 : 16'sh0A00;

    (* use_dsp48 = "yes" *)
    always_ff @(posedge clk) begin
        if (rst) begin
            f_mod_reg <= '0;
            env_f_reg  <= '0;
            f_mult_reg <= '0;
            F          <= '0;
        end else begin
            f_mod_reg <= sw[5] ? 16'sh4000 : 16'sh2000;  // AREG
            env_f_reg  <= $signed({1'b0, env_level});       // BREG: unsigned→signed
            f_mult_reg <= f_mod_reg * env_f_reg;           // MREG
            F          <= (f_mult_reg >>> 12);                // PREG
        end
    end

    // Filter (output sample_svf)
    // Right shift by one before filter
    audio_svf svf (
        .clk, .rst, .sample_tick,
        .sample_in($signed(sample_env) >>> 2), .F(F + f_floor), .Q(sw[4] ? 16'sh3800 : 16'sh7000), .filt_sel(2'b00),
        .sample_out(sample_svf)
    );

    // Volume control (output sample_vol)
    audio_volume_control vol_control (.volume(sw[9:8]), .sample_in(sample_svf <<< 1), .sample_out(sample_vol));

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
        .digit3(4'd10), .digit2(4'd10), .digit1(4'd10), .digit0(bar_count + 4'd1), .dps(4'b1011),
        .seg, .dp, .an
    );
endmodule