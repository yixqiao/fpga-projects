module top (
    input logic clk,
    input logic btnC,
    input logic [9:0] sw,
    output logic mclk, bclk, lrclk, sdin
);
    logic rst;
    logic sample_tick;
    logic [23:0] phase;

    logic [23:0] inc;
    logic [23:0] sample_wave, sample_env, sample_svf, sample_vol;

    // Reset gen
    rst_gen rg (.clk, .rst);

    // Switch: volume, note, waveform, ADSR

    // Choose note (output inc)
    note_select ns (.note_sel(sw[7:6]), .inc);

    // Get phase (output phase)
    phase_acc #(.W(24)) nco (
        .clk, .rst,
        .tick(sample_tick), .inc,
        .phase
    );

    // Get waveform (output sample_wave)
    waveform_gen wave_gen (.phase, .wave_sel(sw[5:4]), .sample(sample_wave));

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
            s1_reg   <= sample_wave; // AREG stage
            env_reg  <= {1'b0, env_level}; // BREG stage
            mult_reg <= s1_reg * env_reg; // MREG stage
            sample_env <= mult_reg >>> 12; // PREG stage
        end
    end

    // Filter (output sample_svf)
    audio_svf svf (
        .clk, .rst, .sample_tick,
        .sample_in(sample_env), .F(16'sh218A), .Q(16'sh5A82), .filt_sel(2'b00),
        .sample_out(sample_svf)
    );

    // Volume control (output sample_vol)
    audio_volume_control vol_control (.volume(sw[9:8]), .sample_in(sample_svf), .sample_out(sample_vol));

    // Transmit to I2S
    io_i2s_tx tx (
        .clk, .rst,
        .left(sample_vol), .right(sample_vol),
        .sample_req(sample_tick),
        .mclk, .bclk, .lrclk, .sdin
    );
endmodule