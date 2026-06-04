module top (
    input logic clk,
    input logic btnC,
    input logic [5:0] sw,
    output logic mclk, bclk, lrclk, sdin
);
    logic sample_req;
    logic [23:0] phase;

    logic [23:0] inc;
    logic [23:0] sample_1, sample_2;

    note_select ns (.note_sel(sw[3:2]), .inc);
    
    phase_acc #(.W(24)) nco (
        .clk, .rst(btnC),
        .tick(sample_req), .inc,
        .phase
    );

    waveform_gen wave_gen (.phase, .wave_sel(sw[1:0]), .sample(sample_1));

    audio_volume_control vol_control (.volume(sw[5:4]), .sample_in(sample_1), .sample_out(sample_2));

    i2s_tx tx (
        .clk, .rst(btnC),
        .left(sample_2), .right(sample_2),
        .sample_req,
        .mclk, .bclk, .lrclk, .sdin
    );
endmodule