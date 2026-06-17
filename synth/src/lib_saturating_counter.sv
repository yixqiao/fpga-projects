module lib_saturating_counter #(
    parameter WIDTH = 4,
    parameter MIN_CNT = 0,
    parameter MAX_CNT = 9,
    parameter DEFAULT = 0
)(
    input  logic clk, rst,
    input  logic tick_pos, tick_neg,
    output logic [WIDTH-1:0] digit
);
    logic at_max, at_min;
    assign at_max = (digit == WIDTH'(MAX_CNT));
    assign at_min = (digit == WIDTH'(MIN_CNT));

    always_ff @(posedge clk) begin
        if (rst) digit <= WIDTH'(DEFAULT);
        else if (tick_pos && !at_max) digit <= digit + 1;
        else if (tick_neg && !at_min) digit <= digit - 1;
    end

endmodule