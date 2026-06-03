module rst_gen (
    input clk,
    output rst
);

    parameter RST_CYCLES = 100; // Tunable

    logic [$clog2(RST_CYCLES+1)-1:0] rst_cnt = '0;
    
    always_ff @(posedge clk) begin
        if (rst_cnt < RST_CYCLES) rst_cnt <= rst_cnt + 1;
    end

    assign rst = (rst_cnt < RST_CYCLES);
endmodule