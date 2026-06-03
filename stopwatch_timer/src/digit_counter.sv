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
        if (rst) begin
            digit <= MIN_CNT;
            carry_pos <= 0;
            carry_neg <= 0;
        end
        else if (load) begin
            digit <= digit_in;
            carry_pos <= 0;
            carry_neg <= 0;
        end
        else if (tick_pos) begin
            if (digit == MAX_CNT) begin
                digit <= MIN_CNT;
                carry_pos <= 1;
            end
            else begin
                digit <= digit + 1;
                carry_pos <= 0;
            end
            carry_neg <= 0;
        end
        else if (tick_neg) begin
            if (digit == MIN_CNT) begin
                digit <= MAX_CNT;
                carry_neg <= 1;
            end
            else begin
                digit <= digit - 1;
                carry_neg <= 0;
            end
            carry_pos <= 0;
        end
        else begin
            carry_pos <= 0;
            carry_neg <= 0;
        end
    end


endmodule