`timescale 1ns / 1ps

module tb_digit_counter;
    logic clk, rst, tick;
    logic [3:0] digit;
    logic carry;

    digit_counter #(.MAX_CNT(5)) uut (
        .clk, .rst, .tick, .digit, .carry
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/tb_digit_counter.vcd");
        $dumpvars(0, tb_digit_counter);

        rst = 1;
        repeat(4) @(posedge clk);
        rst = 0;

        tick = 1;
        repeat(100) @(posedge clk);
        tick = 0;

        repeat(10) @(posedge clk);
        tick = 1;
        repeat(4) @(posedge clk);

        $finish;
    end

endmodule