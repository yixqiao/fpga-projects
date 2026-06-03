module io_btn_debouncer #(
    parameter LOCKOUT_CYCLES = 100_000  // default 1ms from 100 MHz
)(
    input clk,
    input rst,
    input in,
    output logic out,
    output logic pulse
);
    logic [$clog2(LOCKOUT_CYCLES+1)-1:0] cnt = '0;

    localparam I0=0, I1=1, L0=2, L1=3;
    logic [1:0] state=I0, next_state;

    always_comb begin
        case (state)
            I0: next_state = in ? L1 : I0;
            I1: next_state = !in ? L0 : I1;
            L0: next_state = cnt==LOCKOUT_CYCLES ? I0 : L0;
            L1: next_state = cnt==LOCKOUT_CYCLES ? I1 : L1;
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            cnt <= '0;
            state <= I0;
            pulse <= '0;
        end
        else begin
            state <= next_state;
            pulse <= (next_state==L1 && state==I0); // negedge should be easy to add

            if (state==I0 || state==I1) cnt <= '0;
            else begin
                cnt <= (cnt==LOCKOUT_CYCLES) ? LOCKOUT_CYCLES : cnt+1;
            end

        end
    end

    assign out = (state==I1 || state==L1);
endmodule