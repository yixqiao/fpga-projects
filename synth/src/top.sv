module top (
    input logic clk,
    input logic btnC,
    input logic [11:0] sw,
    output logic mclk, bclk, lrclk, sdin
);
    logic rst;
    logic sample_tick;
    logic [23:0] phase;

    logic [23:0] inc;
    logic [23:0] sample_wave, sample_env, sample_svf, sample_vol;

    // Reset gen
    rst_gen rg (.clk, .rst);

    // Switch: volume 11:10, note 9:8, waveform 7:6, filter 5:4, ADSR 3:0

    // Choose note (output inc)
    note_select ns (.note_sel(sw[9:8]), .inc);

    // Get phase (output phase)
    phase_acc #(.W(24)) nco (
        .clk, .rst,
        .tick(sample_tick), .inc,
        .phase
    );

    // Get waveform (output sample_wave)
    waveform_gen wave_gen (.phase, .wave_sel(sw[7:6]), .sample(sample_wave));

    // Envelope (output sample_env)
    logic adsr_gate;
    logic [11:0] env_level;
    io_btn_debouncer db_adsr_gate (.clk, .rst, .in(btnC), .out(adsr_gate), .pulse_pos(), .pulse_neg());
    envelope_adsr env_adsr (
        .clk, .rst, .gate(adsr_gate), .sample_tick,
        .sel_a(sw[3]), .sel_d(sw[2]), .sel_s(sw[1]), .sel_r(sw[0]),
        .env_level
        );
    logic signed [23:0] s1_reg;
    logic signed [11:0] env_reg;
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
    logic signed [11:0] env_f_reg;     // BREG: zero-extended env_level
    logic signed [27:0] f_mult_reg;    // MREG: 16+12 = 28-bit product
    logic signed [15:0] F;             // PREG: final F after scale-back
    logic signed [15:0] f_floor;
    assign f_floor = sw[5] ? 16'sh2000 : 16'sh0A00;

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
            F          <= (f_mult_reg >>> 12) + f_floor;                // PREG
        end
    end

    // Filter (output sample_svf)
    // Right shift by one before filter
    audio_svf svf (
        .clk, .rst, .sample_tick,
        .sample_in($signed(sample_env) >>> 2), .F, .Q(sw[4] ? 16'sh7FFF : 16'sh3FFF), .filt_sel(2'b00),
        .sample_out(sample_svf)
    );

    // Volume control (output sample_vol)
    audio_volume_control vol_control (.volume(sw[11:10]), .sample_in(sample_svf <<< 1), .sample_out(sample_vol));

    // Transmit to I2S
    io_i2s_tx tx (
        .clk, .rst,
        .left(sample_vol), .right(sample_vol),
        .sample_req(sample_tick),
        .mclk, .bclk, .lrclk, .sdin
    );
endmodule