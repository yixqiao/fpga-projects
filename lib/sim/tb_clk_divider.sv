`timescale 1ns / 1ps

module tb_clk_divider;
    logic clk, rst, tick;

    clk_divider #(.DIV(4)) dut (
        .clk, .rst, .tick
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/tb_clk_divider.vcd");
        $dumpvars(0, tb_clk_divider);

        rst = 1;
        repeat(4) @(posedge clk);
        rst = 0;

        repeat(100) @(posedge clk);

        rst = 1;
        repeat(2) @(posedge clk);
        rst = 0;

        repeat(32) @(posedge clk);
        $finish;
    end

endmodule