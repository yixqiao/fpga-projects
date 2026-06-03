module top (
    input clk,
    input btnC,
    input btnD,
    output led,
    output [6:0] seg,
    output dp,
    output [3:0] an
);

    logic rst;
    rst_gen rg (.clk, .rst);

    logic [3:0] digit3, digit2, digit1, digit0;

    logic pulseStartStop, pulseReset;
    io_btn_debouncer db_btnC (.clk, .rst, .in(btnC), .pulse(pulseStartStop));
    io_btn_debouncer db_btnD (.clk, .rst, .in(btnD), .pulse(pulseReset));

    stopwatch sw_main (.clk, .rst, .pulseStartStop, .pulseReset, .digit3, .digit2, .digit1, .digit0);
    seg7_mux4 seg7_controller (.clk, .rst, .digit3, .digit2, .digit1, .digit0, .dps(~4'b0100), .seg, .dp, .an);
    
    assign led = '1;
endmodule