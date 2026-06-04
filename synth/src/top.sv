module top (
    input  logic clk,          // 100 MHz
    input  logic rst,          // btnC
    output logic mclk, bclk, lrclk, sdin
);
    logic        sreq;
    logic [23:0] saw;

    phase_acc #(.W(24)) nco (
        .clk(clk), .rst(rst),
        .tick(sreq),
        .inc(24'd150_998),     // A4 = 440 Hz
        .phase(saw)
    );

    i2s_tx tx (
        .clk(clk), .rst(rst),
        .left(saw >> 2), .right(saw >> 2),
        .sample_req(sreq),
        .mclk(mclk), .bclk(bclk), .lrclk(lrclk), .sdin(sdin)
    );
endmodule