`timescale 1ns / 1ps

module tb_rst_gen;
    logic clk, rst;

    rst_gen #(.RST_CYCLES(4)) dut (
        .clk, .rst
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/tb_rst_gen.vcd");
        $dumpvars(0, tb_rst_gen);

        repeat(20) @(posedge clk);
        $finish;
    end

endmodule