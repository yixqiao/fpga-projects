module top (
    input clk,
    input rst,
    output [6:0] seg,
    output [3:0] an
);

    assign an = 4'b1110;

    parameter DIV = 1_000_000; // for 10ms tick

    logic [$clog2(DIV)-1:0] div_cnt;
    logic tick_10ms;

    always @(posedge clk) begin
        if (rst) begin
            div_cnt <= 0;
            tick_10ms <= 0;
        end else if (div_cnt == DIV - 1) begin
            div_cnt <= 0;
            tick_10ms <= 1;
        end else begin
            div_cnt <= div_cnt + 1;
            tick_10ms <= 0;
        end
    end


    logic [3:0] digit3, digit2, digit1, digit0;

    stopwatch sw_main (.clk, .rst, .tick_10ms, .digit3, .digit2, .digit1, .digit0);
endmodule