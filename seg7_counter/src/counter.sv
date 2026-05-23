module counter(
    input clk,
    input rst,
    input en,
    output logic [3:0] digit
);

    always @(posedge clk) begin
        if (rst) digit <= '0;
        else if (en) digit <= (digit == 4'd9) ? 0 : digit + 1;
    end


endmodule