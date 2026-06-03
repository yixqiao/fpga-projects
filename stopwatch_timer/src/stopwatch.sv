module stopwatch(
    input clk,
    input rst,
    input pulseStartStop,
    input pulseReset,
    output logic [3:0] digit3,
    output logic [3:0] digit2,
    output logic [3:0] digit1,
    output logic [3:0] digit0
);
    parameter DIV = 1_000_000; // for 10ms tick

    
    localparam STOPPED=0, RUNNING=1;
    logic state, next_state;
    
    // FSM logic
    always_comb begin
        case (state)
            STOPPED: next_state = pulseStartStop ? RUNNING : STOPPED;
            RUNNING: next_state = pulseStartStop ? STOPPED : RUNNING;
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= STOPPED;
        end
        else begin
            state <= next_state;
        end
    end
    

    logic tick_10ms, tick_100ms, tick_1s, tick_10s, tick_unused;
    clk_divider #(.DIV(DIV)) divider_10ms (.clk, .rst(rst || state==STOPPED), .tick(tick_10ms));

    logic reset_digits;
    assign reset_digits = (state==STOPPED && pulseReset);

    digit_counter count0 (.clk, .rst(rst | reset_digits), .tick(tick_10ms), .digit(digit0), .carry(tick_100ms));
    digit_counter count1 (.clk, .rst(rst | reset_digits), .tick(tick_100ms), .digit(digit1), .carry(tick_1s));
    digit_counter count2 (.clk, .rst(rst | reset_digits), .tick(tick_1s), .digit(digit2), .carry(tick_10s));
    digit_counter #(.MAX_CNT(5)) count3 (.clk, .rst(rst | reset_digits), .tick(tick_10s), .digit(digit3), .carry(tick_unused));
endmodule