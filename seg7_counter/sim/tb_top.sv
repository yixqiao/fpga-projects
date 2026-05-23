`timescale 1ns / 1ps

module tb_top;
    logic clk, rst;
    logic [6:0] segs;
    logic [3:0] an;

    top #(.DIV(10)) uut (
        .clk, .rst, .segs, .an
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/tb_top.vcd");
        $dumpvars(0, tb_top);

        rst = 1; #150;
        rst = 0;

        #2500;
        $finish;
    end

endmodule