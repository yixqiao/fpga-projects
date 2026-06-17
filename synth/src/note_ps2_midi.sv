module note_ps2_midi (
    input logic clk, rst,
    input logic [7:0] scancode,
    input logic valid,
    output logic [7:0] midi
);
    logic break_pending;
    logic [7:0] current_key;

    always_ff @(posedge clk) begin
        if (rst) begin
            break_pending <= 0;
            midi <= 8'hFF;
            current_key <= '0;
        end else if (valid) begin
            if (scancode == 8'hF0) begin
                break_pending <= 1;         // next byte is a release
            end else begin
                break_pending <= 0;
                if (break_pending) begin
                    if (scancode == current_key)
                        midi <= 8'hFF; // Released
                end else begin
                    case (scancode)
                        8'h12: midi <= 8'd36; // C2
                        8'h1C: midi <= 8'd37; // C#2
                        8'h1A: midi <= 8'd38; // D2
                        8'h1B: midi <= 8'd39; // D#2
                        8'h22: midi <= 8'd40; // E2
                        8'h21: midi <= 8'd41; // F2
                        8'h2B: midi <= 8'd42; // F#2
                        8'h2A: midi <= 8'd43; // G2
                        8'h34: midi <= 8'd44; // G#2
                        8'h32: midi <= 8'd45; // A2
                        8'h33: midi <= 8'd46; // A#2
                        8'h31: midi <= 8'd47; // B2
                        8'h3A: midi <= 8'd48; // C3
                        8'h42: midi <= 8'd49; // C#3
                        8'h41: midi <= 8'd50; // D3
                        8'h4B: midi <= 8'd51; // D#3
                        8'h49: midi <= 8'd52; // E3
                        8'h4A: midi <= 8'd53; // F3
                        8'h52: midi <= 8'd54; // F#3
                        8'h15: midi <= 8'd55; // G3
                        8'h1E: midi <= 8'd56; // G#3
                        8'h1D: midi <= 8'd57; // A3
                        8'h26: midi <= 8'd58; // A#3
                        8'h24: midi <= 8'd59; // B3
                        8'h2D: midi <= 8'd60; // C4
                        8'h2E: midi <= 8'd61; // C#4
                        8'h2C: midi <= 8'd62; // D4
                        8'h36: midi <= 8'd63; // D#4
                        8'h35: midi <= 8'd64; // E4
                        8'h3C: midi <= 8'd65; // F4
                        8'h3E: midi <= 8'd66; // F#4
                        8'h43: midi <= 8'd67; // G4
                        8'h46: midi <= 8'd68; // G#4
                        8'h44: midi <= 8'd69; // A4
                        8'h45: midi <= 8'd70; // A#4
                        8'h4D: midi <= 8'd71; // B4
                        8'h54: midi <= 8'd72; // C5
                        default: midi <= 8'hFF; // unknown key = rest
                    endcase
                    current_key <= scancode;
                end
            end
        end
    end
endmodule