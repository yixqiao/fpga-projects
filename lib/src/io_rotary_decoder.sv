module io_rotary_decoder #(
    parameter ROTARY_LOCKOUT_CYCLES = 500_000  // default 5ms from 100 MHz
)(
    input clk,
    input rst,
    input logic enc_a, // active-low
    input logic enc_b,
    output logic pulse_pos,
    output logic pulse_neg
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
            pulse_pos = 0;
            pulse_neg = 0;
        end
        else begin
            prev <= cur;
            case ({prev, cur})
                4'b10_00: begin  // last step of CW cycle
                    pulse_pos <= 1;
                    pulse_neg <= 0;
                end
                4'b01_00: begin  // last step of CCW cycle
                    pulse_pos <= 0;
                    pulse_neg <= 1;
                end
                default: begin
                    pulse_pos <= 0;
                    pulse_neg <= 0;
                end
            endcase
        end
    end
endmodule