module io_rotary_decoder #(
    parameter ROTARY_LOCKOUT_CYCLES = 200_000  // default 2ms from 100 MHz
)(
    input clk,
    input rst,
    input logic enc_a, // active-low
    input logic enc_b,
    output logic pos_pulse,
    output logic neg_pulse
    );

    logic a_db, b_db;
    io_btn_debouncer #(.LOCKOUT_CYCLES(ROTARY_LOCKOUT_CYCLES)) deb_a (.clk, .rst, .in(~enc_a), .out(a_db), .pulse());
    io_btn_debouncer #(.LOCKOUT_CYCLES(ROTARY_LOCKOUT_CYCLES)) deb_b (.clk, .rst, .in(~enc_b), .out(b_db), .pulse());

    // Quadrature decoder

    logic [1:0] prev, cur;
    assign cur = {a_db, b_db};
    always_ff @(posedge clk) begin
        if (rst) begin
            prev <= cur;
            pos_pulse = 0;
            neg_pulse = 0;
        end
        else begin
            prev <= cur;
            case ({prev, cur})
                4'b00_01, 4'b01_11, 4'b11_10, 4'b10_00: begin
                    pos_pulse <= 1;
                    neg_pulse <= 0;
                end
                4'b00_10, 4'b10_11, 4'b11_01, 4'b01_00: begin
                    pos_pulse <= 0;
                    neg_pulse <= 1;
                end
                default: begin
                    pos_pulse <= 0;
                    neg_pulse <= 0;
                end
            endcase
        end
    end
endmodule