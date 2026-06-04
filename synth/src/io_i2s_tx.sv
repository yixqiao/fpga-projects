module io_i2s_tx (
    input logic clk, rst,
    input logic [23:0] left, right,
    output logic sample_req,
    output logic mclk, bclk, lrclk, sdin
);
    logic [10:0] cnt; // Clock counter
    logic [23:0] lat_l, lat_r; // Latches

    always_ff @(posedge clk)
        if (rst) cnt <= '0;
        else cnt <= (cnt == 11'd2047) ? '0 : cnt + 1'd1;

    assign mclk       = cnt[2];
    assign bclk       = cnt[4];
    assign lrclk      = cnt[10];

    assign sample_req = (cnt == 11'd2047);

    always_ff @(posedge clk)
        if (cnt == 11'd2047) begin
            lat_l <= left;
            lat_r <= right;
        end


    // Left: 1-24, right: 33-36, MSB first
    logic [5:0] bnum;
    assign bnum = cnt[10:5];

    always_comb begin
        if (!lrclk && bnum >= 6'd1  && bnum <= 6'd24)
            sdin = lat_l[6'd24 - bnum];
        else if (lrclk && bnum >= 6'd33 && bnum <= 6'd56)
            sdin = lat_r[6'd56 - bnum];
        else sdin = 1'b0;
    end
endmodule