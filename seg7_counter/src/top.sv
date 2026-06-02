module top (
    input clk,
    input rst,
    output [6:0] seg,
    output [3:0] an
);

    assign an = 4'b1110;

    parameter DIV = 100_000_000;

    logic [$clog2(DIV)-1:0] div_cnt;
    logic tick;

    always @(posedge clk) begin
        if (rst) begin
            div_cnt <= 0;
            tick <= 0;
        end else if (div_cnt == DIV - 1) begin
            div_cnt <= 0;
            tick <= 1;
        end else begin
            div_cnt <= div_cnt + 1;
            tick <= 0;
        end
    end

    logic [3:0] digit;

    counter cnt(.clk, .rst, .en(tick), .digit);
    seg7_dec dec(.digit, .seg);

endmodule