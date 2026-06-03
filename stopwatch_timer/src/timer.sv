module timer(
    input clk,
    input rst,
    input pulse_start_stop,
    input pulse_reset, // Need to add counter logic: conuter can load, every pulse_pos or pulse_neg will save the current digits
    input pulse_pos,
    input pulse_neg,
    input pulse_min_sec,
    output logic [3:0] digit3,
    output logic [3:0] digit2,
    output logic [3:0] digit1,
    output logic [3:0] digit0,
    output logic dp,
    output logic [2:0] leds_done
);
    parameter DIV = 100_000_000; // for 1s tick

    
    localparam STOPPED_SEC=0, STOPPED_MIN=1, RUNNING=2, DONE=3;
    logic [1:0] state, next_state;

    logic tick_1s;
    logic carry_pos_d0, carry_pos_d1, carry_pos_d2;
    logic carry_neg_d0, carry_neg_d1, carry_neg_d2, carry_neg_d3;

    logic pulse_save_d;
    logic [3:0] digit3_s='0, digit2_s='0, digit1_s='0, digit0_s='0;
    
    
    logic nonzero;
    assign nonzero = digit0 != 0 || digit1 != 0 || digit2 != 0 || digit3 != 0;
    
    // FSM logic
    always_comb begin
        case (state)
            STOPPED_SEC: next_state = (pulse_start_stop && nonzero) ? RUNNING : (pulse_min_sec ? STOPPED_MIN : STOPPED_SEC);
            STOPPED_MIN: next_state = (pulse_start_stop && nonzero) ? RUNNING : (pulse_min_sec ? STOPPED_SEC : STOPPED_MIN);
            RUNNING: next_state = carry_neg_d3 ? DONE : ((pulse_start_stop && nonzero) ? STOPPED_SEC : RUNNING);
            DONE: next_state = pulse_reset ? STOPPED_SEC : DONE;
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= STOPPED_SEC;

            pulse_save_d <= 0;
            digit3_s <= '0;
            digit2_s <= '0;
            digit1_s <= '0;
            digit0_s <= '0;
        end
        else begin
            state <= next_state;
            
            pulse_save_d <= (state == STOPPED_SEC || state == STOPPED_MIN) && (pulse_pos || pulse_neg);
            if (pulse_save_d) begin
                digit3_s <= digit3;
                digit2_s <= digit2;
                digit1_s <= digit1;
                digit0_s <= digit0;
            end 
        end
    end
    
    logic reset_digits;
    assign reset_digits = state==DONE && !pulse_reset;


    assign load = (state==DONE || state==STOPPED_SEC || state==STOPPED_MIN) && pulse_reset;

    clk_divider #(.DIV(DIV)) divider_1s (.clk, .rst(rst || state==STOPPED_SEC || state==STOPPED_MIN), .tick(tick_1s));

    // Seconds
    digit_counter count0 (
        .clk, .rst(rst | reset_digits),
        .load, .digit_in(digit0_s),
        .tick_pos((state==STOPPED_SEC && pulse_pos)), .tick_neg(tick_1s || (state==STOPPED_SEC && pulse_neg)),
        .digit(digit0), .carry_pos(carry_pos_d0), .carry_neg(carry_neg_d0)
    );
    digit_counter #(.MAX_CNT(5)) count1 (
        .clk, .rst(rst | reset_digits),
        .load, .digit_in(digit1_s),
        .tick_pos(carry_pos_d0), .tick_neg(carry_neg_d0),
        .digit(digit1), .carry_pos(carry_pos_d1), .carry_neg(carry_neg_d1)
    );

    // Minutes
    digit_counter count2 (
        .clk, .rst(rst | reset_digits),
        .load, .digit_in(digit2_s),
        .tick_pos(carry_pos_d1|| (state==STOPPED_MIN && pulse_pos)), .tick_neg(carry_neg_d1|| (state==STOPPED_MIN && pulse_neg)),
        .digit(digit2), .carry_pos(carry_pos_d2), .carry_neg(carry_neg_d2)
    );
    digit_counter #(.MAX_CNT(5)) count3 (
        .clk, .rst(rst | reset_digits),
        .load, .digit_in(digit3_s),
        .tick_pos(carry_pos_d2), .tick_neg(carry_neg_d2),
        .digit(digit3), .carry_pos(), .carry_neg(carry_neg_d3)
    );

    // Active low
    assign dp = !(state==RUNNING ? (digit0[0]==0) : 1);


    logic tick_1s_done;
    clk_divider #(.DIV(DIV)) divider_done (.clk, .rst(rst || state == RUNNING), .tick(tick_1s_done));
    
    assign leds_done = (state==DONE && tick_1s_done) ? '1 : '0;
endmodule