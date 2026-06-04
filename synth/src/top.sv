module top (
    input logic clk,
    input logic rst,
    input logic [3:0] sw,
    output logic mclk, bclk, lrclk, sdin
);
    logic sample_req;
    logic [23:0] phase;

    logic [23:0] inc;
    logic [23:0] sample;
    note_select ns (.note_sel(sw[3:2]), .inc);
    waveform_gen wave_gen (.phase, .wave_sel(sw[1:0]), .sample);

    phase_acc #(.W(24)) nco (
        .clk, .rst(btnC),
        .tick(sample_req), .inc,
        .phase
    );

    i2s_tx tx (
        .clk, .rst(btnC),
        .left(sample), .right(sample),
        .sample_req,
        .mclk, .bclk, .lrclk, .sdin
    );
endmodule