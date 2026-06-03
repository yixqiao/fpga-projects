`timescale 1ns / 1ps

module tb_seg7_mux4;
    logic clk, rst;
    logic [3:0] digit3, digit2, digit1, digit0;
    logic [3:0] dps;
    logic [6:0] seg;
    logic [3:0] an;
    logic dp;

    seg7_mux4 #(.DIV(4)) dut (.clk, .rst, .digit3, .digit2, .digit1, .digit0, .dps, .seg, .an, .dp);

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/tb_seg7_mux4.vcd");
        $dumpvars(0, tb_seg7_mux4);

        digit3 = 4'd3;
        digit2 = 4'd2;
        digit1 = 4'd1;
        digit0 = 4'd0;
        dps = 4'b0010;

        rst = 1;

        rst = 1;
        repeat(4) @(posedge clk);
        rst = 0;

        repeat(100) @(posedge clk);

        $finish;
    end

endmodule