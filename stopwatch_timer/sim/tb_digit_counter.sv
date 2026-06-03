`timescale 1ns / 1ps

module tb_digit_counter;
    logic clk, rst, tick_pos, tick_neg;
    logic [3:0] digit;
    logic carry_pos, carry_neg;

    digit_counter #(.MIN_CNT(1), .MAX_CNT(5)) uut (
        .clk, .rst, .tick_pos, .tick_neg, .digit, .carry_pos, .carry_neg
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/tb_digit_counter.vcd");
        $dumpvars(0, tb_digit_counter);

        rst = 1;
        tick_pos = 0;
        tick_neg = 0;
        repeat(4) @(posedge clk);
        rst = 0;

        repeat(2) @(posedge clk);

        tick_pos = 1;
        repeat(17) @(posedge clk);
        tick_pos = 0;

        repeat(4) @(posedge clk);

        tick_neg = 1;
        repeat(31) @(posedge clk);
        tick_neg = 0;

        repeat(4) @(posedge clk);

        $finish;
    end

endmodule