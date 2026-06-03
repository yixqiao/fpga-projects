`timescale 1ns / 1ps

module tb_timer;
    logic clk, rst, pulse_start_stop, pulse_reset, pulse_pos, pulse_neg, pulse_min_sec;
    
    logic [3:0] digit3, digit2, digit1, digit0;
    logic dp;
    logic [2:0] leds_done;

    timer #(.DIV(2)) uut (
        .clk, .rst, .pulse_start_stop, .pulse_reset, .pulse_pos, .pulse_neg, .pulse_min_sec,
        .digit3, .digit2, .digit1, .digit0, .dp, .leds_done
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/tb_timer.vcd");
        $dumpvars(0, tb_timer);

        rst = 1;
        pulse_start_stop = 0;
        pulse_reset = 0;
        pulse_pos = 0;
        pulse_neg = 0;
        pulse_min_sec = 0;
        repeat(4) @(posedge clk);
        rst = 0;
        repeat(4) @(posedge clk);

        // Set seconds
        pulse_pos = 1; @(posedge clk); pulse_pos = 0;
        repeat(4) @(posedge clk);
        pulse_pos = 1; @(posedge clk); pulse_pos = 0;
        repeat(4) @(posedge clk);
        pulse_pos = 1; @(posedge clk); pulse_pos = 0;
        repeat(4) @(posedge clk);

        // Set mins
        pulse_min_sec = 1; @(posedge clk); pulse_min_sec = 0;
        repeat(4) @(posedge clk);
        pulse_pos = 1; @(posedge clk); pulse_pos = 0;
        repeat(4) @(posedge clk);
        pulse_neg = 1; @(posedge clk); pulse_neg = 0;
        repeat(4) @(posedge clk);

        // Run until done, with reset
        pulse_start_stop = 1; @(posedge clk); pulse_start_stop = 0;
        repeat(24) @(posedge clk);
        pulse_reset = 1; @(posedge clk); pulse_reset = 0;
        repeat(10) @(posedge clk);


        // Set seconds
        pulse_pos = 1; @(posedge clk); pulse_pos = 0;
        repeat(4) @(posedge clk);
        pulse_pos = 1; @(posedge clk); pulse_pos = 0;
        repeat(4) @(posedge clk);
        pulse_pos = 1; @(posedge clk); pulse_pos = 0;
        repeat(16) @(posedge clk);

        // Start, stop, reset
        pulse_start_stop = 1; @(posedge clk); pulse_start_stop = 0;
        repeat(4) @(posedge clk);
        pulse_start_stop = 1; @(posedge clk); pulse_start_stop = 0;
        repeat(4) @(posedge clk);
        pulse_reset = 1; @(posedge clk); pulse_reset = 0;
        repeat(4) @(posedge clk);
        
        // Set and run again
        pulse_min_sec = 1; @(posedge clk); pulse_min_sec = 0;
        repeat(2) @(posedge clk);
        pulse_pos = 1; @(posedge clk); pulse_pos = 0;
        repeat(2) @(posedge clk);
        pulse_pos = 1; @(posedge clk); pulse_pos = 0;
        repeat(2) @(posedge clk);

        pulse_start_stop = 1; @(posedge clk); pulse_start_stop = 0;
        repeat(32) @(posedge clk);
        $finish;
    end

endmodule