module digit_counter(
    input clk,
    input rst,
    input tick,
    output logic [3:0] digit,
    output logic carry
);

    parameter MAX_CNT = 4'd9;

    always @(posedge clk) begin
        if (rst) begin
            digit <= '0;
            carry <= 0;
        end
        else if (tick) begin
            if (digit == MAX_CNT) begin
                digit <= 0;
                carry <= 1;
            end
            else begin
                digit <= digit + 1;
                carry <= 0;
            end
        end
        else carry <= 0;
    end


endmodule