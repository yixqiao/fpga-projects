`timescale 1ns / 1ps

module tb_stopwatch;
    logic clk, rst, pulseStartStop, pulseReset;
    logic [3:0] digit3, digit2, digit1, digit0;
    logic [3:0] an;

    stopwatch #(.DIV(2)) uut (
        .clk, .rst, .pulseStartStop, .pulseReset, .digit3, .digit2, .digit1, .digit0
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/tb_stopwatch.vcd");
        $dumpvars(0, tb_stopwatch);

        rst = 1;
        pulseStartStop = 0;
        pulseReset = 0;
        repeat(4) @(posedge clk);
        rst = 0;

        repeat(10) @(posedge clk);

        // Run, stop, run, stop
        pulseStartStop = 1; @(posedge clk); pulseStartStop = 0;
        repeat(16) @(posedge clk);
        pulseStartStop = 1; @(posedge clk); pulseStartStop = 0;
        repeat(8) @(posedge clk);
        pulseStartStop = 1; @(posedge clk); pulseStartStop = 0;
        repeat(8) @(posedge clk);
        pulseStartStop = 1; @(posedge clk); pulseStartStop = 0;
        repeat(8) @(posedge clk);

        // Reset, run again (should start running on the correct cycle)
        pulseReset = 1; @(posedge clk); pulseReset = 0;
        repeat(5) @(posedge clk);
        pulseStartStop = 1; @(posedge clk); pulseStartStop = 0;
        repeat(16) @(posedge clk);
        pulseStartStop = 1; @(posedge clk); pulseStartStop = 0;
        repeat(8) @(posedge clk);
        $finish;
    end

endmodule