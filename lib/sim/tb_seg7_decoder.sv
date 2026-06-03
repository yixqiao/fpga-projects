`timescale 1ns / 1ps

module tb_seg7_decoder;

    logic [3:0] digit;
    logic [6:0] seg;

    seg7_decoder dut (.digit, .seg);

    initial begin
        $dumpfile("sim/tb_seg7_decoder.vcd");
        $dumpvars(0, tb_seg7_decoder);

        for (int i = 0; i < 16; i++) begin
            digit = i;
            #10;
            $display("digit=%0d | seg=%07b", i, seg);
        end

        $finish;
    end

endmodule