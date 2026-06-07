`timescale 1ns / 1ps

module tb_io_ps2_rx;
    logic clk, rst;
    logic ps2_clk, ps2_data;
    logic [7:0] scancode;
    logic valid;

    io_ps2_rx dut (
        .clk, .rst,
        .ps2_clk, .ps2_data,
        .scancode, .valid
    );

    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz

    // ~20 kHz PS/2 CLK (faster than real ~10 kHz, fine for sim)
    localparam PS2_HALF = 25000; // ns

    // Send one PS/2 frame: start(0), D0..D7, odd parity, stop(1)
    task automatic send_byte(input [7:0] data);
        logic        parity;
        logic [10:0] frame;
        parity = ~^data; // odd parity: flips XOR so total 1s is odd
        frame  = {1'b1, parity, data, 1'b0}; // [10]=stop [9]=parity [8:1]=data [0]=start

        for (int i = 0; i < 11; i++) begin
            ps2_data = frame[i];   // set data before falling edge
            #(PS2_HALF);
            ps2_clk = 0;           // falling edge — receiver latches here
            #(PS2_HALF);
            ps2_clk = 1;
        end
        #(PS2_HALF);
    endtask

    // Print every received byte
    always @(posedge clk)
        if (valid)
            $display("[%0t ns] scancode = 0x%02X", $time, scancode);

    initial begin
        $dumpfile("sim/tb_io_ps2_rx.vcd");
        $dumpvars(0, tb_io_ps2_rx);

        ps2_clk  = 1;
        ps2_data = 1;
        rst = 1;
        repeat(4) @(posedge clk);
        rst = 0;
        repeat(4) @(posedge clk);

        send_byte(8'h1C);          // 'A' make code
        repeat(20) @(posedge clk);

        send_byte(8'hF0);          // break prefix
        repeat(20) @(posedge clk);

        send_byte(8'h1C);          // 'A' break code
        repeat(20) @(posedge clk);

        // Send a byte with all 0s to stress parity (parity bit = 1)
        send_byte(8'h00);
        repeat(20) @(posedge clk);

        $finish;
    end
endmodule