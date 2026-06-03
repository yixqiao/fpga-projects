`timescale 1ns / 1ps

module tb_stopwatch;
    logic clk, rst, switchRunning, btnReset;
    logic [3:0] digit3, digit2, digit1, digit0;
    logic [3:0] an;

    stopwatch #(.DIV(2)) uut (
        .clk, .rst, .switchRunning, .btnReset, .digit3, .digit2, .digit1, .digit0
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/tb_stopwatch.vcd");
        $dumpvars(0, tb_stopwatch);

        rst = 1;
        switchRunning = 0;
        btnReset = 0;
        repeat(4) @(posedge clk);
        rst = 0;

        repeat(10) @(posedge clk);

        // Run, stop, run, stop
        switchRunning = 1;
        repeat(96) @(posedge clk);
        switchRunning = 0;
        repeat(10) @(posedge clk);
        switchRunning = 1;
        repeat(10) @(posedge clk);
        switchRunning = 0;
        repeat(5) @(posedge clk);

        // Reset, run again (should start running on the correct cycle)
        btnReset = 1;
        repeat(4) @(posedge clk);
        btnReset = 0;
        repeat(4) @(posedge clk);
        switchRunning = 1;
        repeat(16) @(posedge clk);
        switchRunning = 0;
        repeat(4) @(posedge clk);
        $finish;
    end

endmodule