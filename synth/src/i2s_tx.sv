module i2s_tx (
    input  logic        clk, rst,
    input  logic [23:0] left, right,
    output logic        sample_req,        // strobe — latch new samples now
    output logic        mclk, bclk, lrclk, sdin
);
    logic [10:0] cnt;
    logic [23:0] lat_l, lat_r;

    always_ff @(posedge clk or posedge rst)
        if (rst) cnt <= '0;
        else     cnt <= (cnt == 11'd2047) ? 11'd0 : cnt + 1'd1;

    assign mclk       = cnt[2];
    assign bclk       = cnt[4];
    assign lrclk      = cnt[10];
    assign sample_req = (cnt == 11'd2047);   // fires 1 cycle before frame 0

    always_ff @(posedge clk)
        if (cnt == 11'd2047) begin
            lat_l <= left;
            lat_r <= right;
        end

    // bclk_num = cnt[10:5]: which of the 64 BCLK cycles within the frame
    // Left  channel: bclk_num 1–24  → lat_l[23:0] MSB-first
    // Right channel: bclk_num 33–56 → lat_r[23:0] MSB-first
    logic [5:0] bnum;
    assign bnum = cnt[10:5];

    always_comb begin
        sdin = 1'b0;
        if (!lrclk && bnum >= 6'd1  && bnum <= 6'd24)
            sdin = lat_l[6'd24 - bnum];
        else if (lrclk && bnum >= 6'd33 && bnum <= 6'd56)
            sdin = lat_r[6'd56 - bnum];
    end
endmodule