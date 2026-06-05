module audio_svf (
    input  logic        clk, rst,
    input  logic        sample_tick,
    input  logic signed [23:0] sample_in,
    input  logic signed [15:0] F, Q,
    input  logic [1:0]  filt_sel,
    output logic signed [23:0] sample_out
);
    logic signed [23:0] low, band;

    // ---- Multiply 1 (F*band, Q*band) pipeline ----
    logic signed [15:0] f_a, q_a;         // AREG
    logic signed [23:0] band_b, in_r;     // BREG + held input
    logic signed [39:0] fb_m, qb_m;       // MREG (full width)
    logic signed [23:0] Fb, Qb;           // PREG (after >>15)

    // ---- Multiply 2 (F*high) pipeline ----
    logic signed [15:0] f_a2;             // AREG
    logic signed [23:0] high_b;           // BREG
    logic signed [39:0] fh_m;             // MREG (full width)
    logic signed [23:0] Fh;               // PREG

    logic signed [23:0] low_next, high_c;
    logic v0, v1, v2, v3, v4, v5;

    // Stage 0: capture mult1 inputs on tick (AREG/BREG)
    always_ff @(posedge clk) begin
        if (rst) begin f_a<='0; q_a<='0; band_b<='0; in_r<='0; v0<='0; end
        else begin
            v0 <= sample_tick;
            if (sample_tick) begin
                f_a <= F; q_a <= Q; band_b <= band;
                in_r <= sample_in;
            end
        end
    end

    // Stage 1: MREG — full 40-bit products
    (* use_dsp48 = "yes" *)
    always_ff @(posedge clk) begin
        if (rst) begin fb_m<='0; qb_m<='0; v1<='0; end
        else begin
            v1   <= v0;
            fb_m <= f_a * band_b;
            qb_m <= q_a * band_b;
        end
    end

    // Stage 2: PREG — apply >>>15
    always_ff @(posedge clk) begin
        if (rst) begin Fb<='0; Qb<='0; v2<='0; end
        else begin
            v2 <= v1;
            Fb <= fb_m >>> 15;
            Qb <= qb_m >>> 15;
        end
    end

    // Stage 3: semi-implicit low commit + capture mult2 inputs
    assign low_next = low + Fb;
    assign high_c   = in_r - low_next - Qb;   // uses new low
    always_ff @(posedge clk) begin
        if (rst) begin low<='0; f_a2<='0; high_b<='0; v3<='0; end
        else begin
            v3 <= v2;
            if (v2) begin
                low    <= low_next;
                f_a2   <= F;          // AREG mult2
                high_b <= high_c;     // BREG mult2
            end
        end
    end

    // Stage 4: MREG mult2
    (* use_dsp48 = "yes" *)
    always_ff @(posedge clk) begin
        if (rst) begin fh_m<='0; v4<='0; end
        else begin
            v4   <= v3;
            fh_m <= f_a2 * high_b;
        end
    end

    // Stage 5: PREG mult2
    always_ff @(posedge clk) begin
        if (rst) begin Fh<='0; v5<='0; end
        else begin
            v5 <= v4;
            Fh <= fh_m >>> 15;
        end
    end

    // Stage 6: band commit
    always_ff @(posedge clk) begin
        if (rst)     band <= '0;
        else if (v5) band <= band + Fh;
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