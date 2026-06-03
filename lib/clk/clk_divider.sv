module clk_divider #(
    parameter DIV = 100_000_000  // default 1 Hz from 100 MHz
)(
    input clk,
    input rst,
    output logic tick
);
    logic [$clog2(DIV)-1:0] cnt = '0;

    always_ff @(posedge clk) begin
        if (rst) begin
            cnt  <= '0;
            tick <= 0;
        end else if (cnt == DIV - 1) begin
            cnt  <= '0;
            tick <= 1;
        end else begin
            cnt  <= cnt + 1;
            tick <= 0;
        end
    end
endmodule