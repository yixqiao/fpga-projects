`timescale 1ns / 1ps

module tb_stopwatch;
    logic clk, rst, pulse_start_stop, pulse_reset;
    logic [3:0] digit3, digit2, digit1, digit0;
    logic [9:0] onehot_display;

    stopwatch #(.DIV(2)) uut (
        .clk, .rst, .pulse_start_stop, .pulse_reset, .digit3, .digit2, .digit1, .digit0, .onehot_display
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/tb_stopwatch.vcd");
        $dumpvars(0, tb_stopwatch);

        rst = 1;
        pulse_start_stop = 0;
        pulse_reset = 0;
        repeat(4) @(posedge clk);
        rst = 0;

        repeat(10) @(posedge clk);

        // Run, stop, run, stop
        pulse_start_stop = 1; @(posedge clk); pulse_start_stop = 0;
        repeat(16) @(posedge clk);
        pulse_start_stop = 1; @(posedge clk); pulse_start_stop = 0;
        repeat(8) @(posedge clk);
        pulse_start_stop = 1; @(posedge clk); pulse_start_stop = 0;
        repeat(8) @(posedge clk);
        pulse_start_stop = 1; @(posedge clk); pulse_start_stop = 0;
        repeat(8) @(posedge clk);

        // Reset, run again (should start running on the correct cycle)
        pulse_reset = 1; @(posedge clk); pulse_reset = 0;
        repeat(5) @(posedge clk);
        pulse_start_stop = 1; @(posedge clk); pulse_start_stop = 0;
        repeat(16) @(posedge clk);
        pulse_start_stop = 1; @(posedge clk); pulse_start_stop = 0;
        repeat(8) @(posedge clk);
        $finish;
    end

endmodule