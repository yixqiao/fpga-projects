`timescale 1ns / 1ps

module tb_io_btn_debouncer;
    logic clk, rst, in, out, pulse;

    io_btn_debouncer #(.LOCKOUT_CYCLES(4)) dut (
        .clk, .rst, .in, .out, .pulse
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/tb_io_btn_debouncer.vcd");
        $dumpvars(0, tb_io_btn_debouncer);

        rst = 1;
        in = 0;
        repeat(4) @(posedge clk);
        rst = 0;

        // Regular switch
        in = 1;
        repeat(10) @(posedge clk);

        // One bounce, switch to 0
        in = 0;
        @(posedge clk);
        in = 1;
        @(posedge clk);
        in = 0;
        repeat(10) @(posedge clk);

        // False press
        in = 1;
        @(posedge clk);
        in = 0;
        repeat(10) @(posedge clk);
        $finish;
    end

endmodule