module top (
    input clk,
    input rst,
    output [6:0] seg,
    output [3:0] an
);

    parameter DIV = 1_000_000; // for 10ms tick

    logic tick_10ms;
    clk_divider #(.DIV(DIV)) divider_10ms (.clk, .rst, .tick(tick_10ms));

    logic [3:0] digit3, digit2, digit1, digit0;

    stopwatch sw_main (.clk, .rst, .tick_10ms, .digit3, .digit2, .digit1, .digit0);
    seg7_mux4 seg7_controller (.clk, .rst, .digit3, .digit2, .digit1, .digit0, .dps('1), .seg, .an, .dp());
endmodule