module stopwatch(
    input clk,
    input rst,
    input pulse_start_stop,
    input pulse_reset,
    output logic [3:0] digit3,
    output logic [3:0] digit2,
    output logic [3:0] digit1,
    output logic [3:0] digit0,
    output logic [9:0] onehot_display
);
    parameter DIV = 1_000_000; // for 10ms tick

    
    localparam STOPPED=0, RUNNING=1;
    logic state, next_state;
    
    // FSM logic
    always_comb begin
        case (state)
            STOPPED: next_state = pulse_start_stop ? RUNNING : STOPPED;
            RUNNING: next_state = pulse_start_stop ? STOPPED : RUNNING;
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
    

    logic tick_10ms, tick_100ms, tick_1s, tick_10s;
    clk_divider #(.DIV(DIV)) divider_10ms (.clk, .rst(rst || state==STOPPED), .tick(tick_10ms));

    logic reset_digits;
    assign reset_digits = (state==STOPPED && pulse_reset);

    digit_counter count0 (
        .clk, .rst(rst | reset_digits),
        .tick_pos(tick_10ms), .tick_neg('0),
        .digit(digit0), .carry_pos(tick_100ms), .carry_neg()
    );
    digit_counter count1 (
        .clk, .rst(rst | reset_digits),
        .tick_pos(tick_100ms), .tick_neg('0),
        .digit(digit1), .carry_pos(tick_1s), .carry_neg()
    );
    digit_counter count2 (
        .clk, .rst(rst | reset_digits),
        .tick_pos(tick_1s), .tick_neg('0),
        .digit(digit2), .carry_pos(tick_10s), .carry_neg()
    );
    digit_counter #(.MAX_CNT(5)) count3 (
        .clk, .rst(rst | reset_digits),
        .tick_pos(tick_10s), .tick_neg('0),
        .digit(digit3), .carry_pos(), .carry_neg()
    );
    
    always_comb begin
        for (int i=0; i<10; i++) begin
            onehot_display[9-i] = (i==digit1);
        end
    end
endmodule