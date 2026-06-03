module top (
    input clk,
    input rst,
    input sw,
    input btnD,
    output [6:0] seg,
    output dp,
    output [3:0] an
);

    logic [3:0] digit3, digit2, digit1, digit0;

    stopwatch sw_main (.clk, .rst, .switchRunning(sw), .btnReset(btnD), .digit3, .digit2, .digit1, .digit0);
    seg7_mux4 seg7_controller (.clk, .rst, .digit3, .digit2, .digit1, .digit0, .dps(4'b0100), .seg, .dp, .an);
endmodule