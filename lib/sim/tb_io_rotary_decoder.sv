`timescale 1ns / 1ps

module tb_io_rotary_decoder;
    logic clk, rst, a, b;
    logic pos_pulse, neg_pulse;

    io_rotary_decoder #(.ROTARY_LOCKOUT_CYCLES(1)) dut (
        .clk, .rst, .enc_a(a), .enc_b(b), .pos_pulse, .neg_pulse
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/tb_io_rotary_decoder.vcd");
        $dumpvars(0, tb_io_rotary_decoder);

        rst = 1;
        a = 1;
        b = 1;
        repeat(4) @(posedge clk);
        rst = 0;
        repeat(10) @(posedge clk);

        // CW
        b = 0;
        repeat(4) @(posedge clk);
        a = 0;
        repeat(4) @(posedge clk);
        b = 1;
        repeat(4) @(posedge clk);
        a = 1;
        repeat(4) @(posedge clk);


        // CCW        
        a = 0;
        repeat(4) @(posedge clk);
        b = 0;
        repeat(4) @(posedge clk);
        a = 1;
        repeat(4) @(posedge clk);
        b = 1;
        repeat(10) @(posedge clk);

        

        repeat(10) @(posedge clk);
        $finish;
    end

endmodule