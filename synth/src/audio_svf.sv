module audio_svf (
    input  logic        clk, rst,
    input  logic        sample_tick,
    input  logic signed [23:0] sample_in,
    input  logic signed [15:0] F, Q,
    input  logic [1:0]  filt_sel,
    output logic signed [23:0] sample_out
);
    logic signed [23:0] low, band;
    logic signed [23:0] Fb, Qb, Fh, in_r;
    logic v1, v2;

    // Stage 1: capture products from current state, ONLY on tick
    (* use_dsp48 = "yes" *)
    always_ff @(posedge clk) begin
        if (rst) begin Fb<='0; Qb<='0; in_r<='0; v1<='0; end
        else begin
            v1 <= sample_tick;
            if (sample_tick) begin
                Fb   <= (F * band) >>> 15;
                Qb   <= (Q * band) >>> 15;
                in_r <= sample_in;
            end
        end
    end

    // Stage 2: semi-implicit low update, capture F*high consistently
    logic signed [23:0] low_next, high_c;
    assign low_next = low + Fb;
    assign high_c   = in_r - low_next - Qb;   // uses new low

    (* use_dsp48 = "yes" *)
    always_ff @(posedge clk) begin
        if (rst) begin low<='0; Fh<='0; v2<='0; end
        else begin
            v2 <= v1;
            if (v1) begin
                low <= low_next;
                Fh  <= (F * high_c) >>> 15;   // captured once, consistent low
            end
        end
    end

    // Stage 3: band update
    always_ff @(posedge clk) begin
        if (rst)      band <= '0;
        else if (v2)  band <= band + Fh;
    end

    always_comb begin
        case (filt_sel)
            2'b00: sample_out = low;
            2'b01: sample_out = band;
            2'b10: sample_out = high_c;
            2'b11: sample_out = in_r - Qb;
        endcase
    end
endmodule