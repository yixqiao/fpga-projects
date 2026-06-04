module digit_counter(
    input clk,
    input rst,
    input tick_pos,
    input tick_neg,
    input load,
    input [3:0] digit_in,
    output logic [3:0] digit,
    output logic carry_pos,
    output logic carry_neg
);

    parameter MIN_CNT = 4'd0;
    parameter MAX_CNT = 4'd9;

    always @(posedge clk) begin
        if (rst) digit <= MIN_CNT;
        else if (load) digit <= digit_in;
        else if (tick_pos) begin
            if (digit == MAX_CNT) digit <= MIN_CNT;
            else digit <= digit + 1;
        end
        else if (tick_neg) begin
            if (digit == MIN_CNT) digit <= MAX_CNT;
            else digit <= digit - 1;
        end
    end
    
    assign carry_pos = !rst && tick_pos && (digit == MAX_CNT);
    assign carry_neg = !rst && tick_neg && (digit == MIN_CNT);


endmodule