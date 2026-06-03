module stopwatch(
    input clk,
    input rst,
    input tick_10ms,
    output logic [3:0] digit3,
    output logic [3:0] digit2,
    output logic [3:0] digit1,
    output logic [3:0] digit0
);

    logic tick_100ms, tick_1s, tick_10s, tick_unused;

    digit_counter count0 (.clk, .rst, .tick(tick_10ms), .digit(digit0), .carry(tick_100ms));
    digit_counter count1 (.clk, .rst, .tick(tick_100ms), .digit(digit1), .carry(tick_1s));
    digit_counter count2 (.clk, .rst, .tick(tick_1s), .digit(digit2), .carry(tick_10s));
    digit_counter #(.MAX_CNT(5)) count3 (.clk, .rst, .tick(tick_10s), .digit(digit3), .carry(tick_unused));


endmodule