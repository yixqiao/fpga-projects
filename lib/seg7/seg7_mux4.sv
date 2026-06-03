module seg7_mux4 #(parameter DIV=100_000)(
    input clk,
    input rst,
    input [3:0] digit3,
    input [3:0] digit2,
    input [3:0] digit1,
    input [3:0] digit0,
    input [3:0] dps,
    output logic [6:0] seg,
    output logic dp,
    output logic [3:0] an
);

    localparam D3=3, D2=2, D1=1, D0=0;
    logic[1:0] state, next_state;
    logic[3:0] active_digit;
    logic digit_tick;

    // Transitions
    always_comb begin
        case (state)
            D3: next_state = D2;
            D2: next_state = D1;
            D1: next_state = D0;
            D0: next_state = D3;
        endcase
    end

    // FF
    clk_divider #(.DIV(DIV)) digit_clk (.clk, .rst, .tick(digit_tick));
    always_ff @(posedge clk) begin
        state <= rst ? D3 : (digit_tick ? next_state : state);
    end

    // Output
    always_comb begin
        case (state)
            D3: active_digit = digit3;
            D2: active_digit = digit2;
            D1: active_digit = digit1;
            D0: active_digit = digit0;
        endcase
        an[3] = (state != D3);
        an[2] = (state != D2);
        an[1] = (state != D1);
        an[0] = (state != D0);
        dp = dps[state];
    end

    seg7_decoder dec(.digit(active_digit), .seg);

endmodule