module io_ps2_rx (
    input logic clk, rst,
    input logic ps2_clk, ps2_data,
    output logic [7:0] scancode,
    output logic valid
);
    logic ps2_clk_s0, ps2_clk_s1, ps2_clk_prev;
    // 2FF synchronizer
    always_ff @(posedge clk) begin
        ps2_clk_s0 <= ps2_clk;
        ps2_clk_s1 <= ps2_clk_s0;
        ps2_clk_prev <= ps2_clk_s1;
    end

    logic ps2_data_s;
    always_ff @(posedge clk) ps2_data_s <= ps2_data;

    logic falling_edge;
    assign falling_edge = !ps2_clk_s1 & ps2_clk_prev;

    logic [10:0] shift;
    logic [3:0] bit_count;

    always_ff @(posedge clk) begin
        if (rst) begin
            bit_count <= 0;
            valid <= 0;
        end
        else begin
            valid <= 0;
            if (falling_edge) begin
                shift <= {ps2_data_s, shift[10:1]};
                bit_count <= bit_count + 1;
                if (bit_count == 10) begin
                    bit_count <= 0;
                    if (shift[1] == 1'b0      &&           // start bit valid
                        ps2_data_s == 1'b1    &&           // stop bit valid
                        ^{shift[10], shift[9:2]} == 1'b1)  // odd parity: XOR of parity+data = 1
                    begin
                        scancode <= shift[9:2];
                        valid    <= 1;
                    end

                end
            end
        end
    end

endmodule