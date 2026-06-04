module phase_acc #(parameter W = 24) (
    input  logic         clk, rst, tick,
    input  logic [W-1:0] inc,
    output logic [W-1:0] phase
);
    always_ff @(posedge clk) begin
        if (rst)       phase <= '0;
        else if (tick) phase <= phase + inc;
    end
endmodule