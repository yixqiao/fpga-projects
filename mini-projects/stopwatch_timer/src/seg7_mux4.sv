module seg7_mux4(
    input clk,
    input rst,
    input [3:0] digit3,
    input [3:0] digit2,
    input [3:0] digit1,
    input [3:0] digit0,
    input [3:0] dps,
    output logic [6:0] seg,
    output logic [3:0] an,
    output logic dp
);

    localparam D3=3, D2=2, D1=1, D0=0;
    logic[1:0] state, next_state;

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
    always_ff @(posedge clk) begin
        state = rst ? D3 : next_state;
    end

    // Output
    always_comb begin
        case (state)
            D3: seg = digit3;
            D2: seg = digit2;
            D1: seg = digit1;
            D0: seg = digit0;
        endcase
        an[3] = (state == D3);
        an[2] = (state == D2);
        an[1] = (state == D1);
        an[0] = (state == D0);
        dp = dps[state];
    end

endmodule