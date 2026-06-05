module audio_svf (
    input logic clk, rst,
    input logic sample_tick,
    input logic signed [23:0] sample_in,
    input logic signed [15:0] F,
    input logic signed [15:0] Q, // resonance
    input logic [1:0] filt_sel, // low, band, high, notch
    output logic [23:0] sample_out
);
    logic signed [23:0] low, band;
    logic signed [23:0] high;

    logic signed [23:0] F_band_r, Q_band_r, sample_in_r;
    logic sample_tick_r1, sample_tick_r2;
    
    (* use_dsp48 = "yes" *)
    always_ff @(posedge clk) begin
        F_band_r <= (F * band) >>> 15;
        Q_band_r <= (Q * band) >>> 15;
        sample_in_r <= sample_in;
        sample_tick_r1 <= sample_tick;
    end

    logic signed [23:0] F_high_r;
    
    assign high = sample_in_r - low - Q_band_r;
    (* use_dsp48 = "yes" *)
    always_ff @(posedge clk) begin
        F_high_r <= (F * high) >>> 15;
        sample_tick_r2 <= sample_tick_r1;
    end


    always_ff @(posedge clk) begin
        if (rst) begin
            low <= '0;
            band <= '0;
        end else if (sample_tick_r2) begin
            low <= low + F_band_r;
            band <= band + F_high_r;
        end
    end

    always_comb begin
        case (filt_sel)
            2'b00: sample_out = low;
            2'b01: sample_out = band;
            2'b10: sample_out = high;
            2'b11: sample_out = sample_in_r - Q_band_r; // no double register
        endcase
    end
endmodule