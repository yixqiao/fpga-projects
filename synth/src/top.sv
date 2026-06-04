module top (
    input logic clk,
    input logic btnC,
    input logic [5:0] sw,
    output logic mclk, bclk, lrclk, sdin
);
    logic rst;
    logic sample_tick;
    logic [23:0] phase;

    logic [23:0] inc;
    logic [23:0] sample_1, sample_2, sample_3;

    // Reset gen
    rst_gen rg (.clk, .rst);


    // Choose note (output inc)
    note_select ns (.note_sel(sw[3:2]), .inc);

    // Get phase (output phase)
    phase_acc #(.W(24)) nco (
        .clk, .rst,
        .tick(sample_tick), .inc,
        .phase
    );

    // Get waveform (output sample_1)
    waveform_gen wave_gen (.phase, .wave_sel(sw[1:0]), .sample(sample_1));

    // Envelope (output sample_2)
    logic adsr_gate;
    logic [11:0] env_level;
    logic [35:0] adsr_env_product;
    io_btn_debouncer db_adsr_gate (.clk, .rst, .in(btnC), .out(adsr_gate), .pulse_pos(), .pulse_neg());
    envelope_adsr env_adsr (.clk, .rst, .gate(adsr_gate), .sample_tick, .env_level);
    assign adsr_env_product = $signed(sample_1) * env_level; // TODO use_dsp48 and possible register rebalancing
    always_ff @(posedge clk)
        sample_2 <= adsr_env_product[35:12];

    // Volume control (output sample_3)
    audio_volume_control vol_control (.volume(sw[5:4]), .sample_in(sample_2), .sample_out(sample_3));

    // Transmit to I2S
    io_i2s_tx tx (
        .clk, .rst,
        .left(sample_3), .right(sample_3),
        .sample_req(sample_tick),
        .mclk, .bclk, .lrclk, .sdin
    );
endmodule