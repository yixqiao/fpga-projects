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
    logic [3:0] digit3_t, digit2_t, digit1_t, digit0_t;
    logic [3:0] digit3_s='0, digit2_s='0, digit1_s='0, digit0_s='0;


    logic tick_500ms;
    logic ff_500ms;
    
    
    logic nonzero;
    assign nonzero = digit0_t != 0 || digit1_t != 0 || digit2_t != 0 || digit3_t != 0;
    
    // FSM logic
    always_comb begin
        case (state)
            STOPPED_SEC: next_state = (pulse_start_stop && nonzero) ? RUNNING : (pulse_min_sec ? STOPPED_MIN : STOPPED_SEC);
            STOPPED_MIN: next_state = (pulse_start_stop && nonzero) ? RUNNING : (pulse_min_sec ? STOPPED_SEC : STOPPED_MIN);
            RUNNING: next_state = carry_neg_d3 ? DONE : ((pulse_start_stop && nonzero) ? STOPPED_SEC : RUNNING);
            DONE: next_state = (pulse_reset || pulse_start_stop) ? STOPPED_SEC : DONE;
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
                digit3_s <= digit3_t;
                digit2_s <= digit2_t;
                digit1_s <= digit1_t;
                digit0_s <= digit0_t;
            end 
        end
    end
    
    logic reset_digits;
    assign reset_digits = state==DONE && !pulse_reset;

    logic divider_500ms_rst;
    clk_divider #(.DIV(DIV/2)) divider_500ms (.clk, .rst(divider_500ms_rst), .tick(tick_500ms));
    always_ff @(posedge clk) begin
        if (rst) begin
            divider_500ms_rst <= 1;
            ff_500ms <= 0;
        end 
        else if (state != next_state) begin // Switch mins/secs, timer started, timer done, timer reset
            divider_500ms_rst <= 1;
            ff_500ms <= 1;
        end
        else begin
            divider_500ms_rst <= 0;
            if (tick_500ms) ff_500ms <= !ff_500ms;
        end
    end
    
    assign leds_done = (state==DONE && ff_500ms) ? '1 : '0;


    assign load = (state==DONE || state==STOPPED_SEC || state==STOPPED_MIN) && pulse_reset;

    clk_divider #(.DIV(DIV)) divider_1s (.clk, .rst(rst || state==STOPPED_SEC || state==STOPPED_MIN), .tick(tick_1s));

    // Seconds
    digit_counter count0 (
        .clk, .rst(rst | reset_digits),
        .load, .digit_in(digit0_s),
        .tick_pos((state==STOPPED_SEC && pulse_pos)), .tick_neg(tick_1s || (state==STOPPED_SEC && pulse_neg)),
        .digit(digit0_t), .carry_pos(carry_pos_d0), .carry_neg(carry_neg_d0)
    );
    digit_counter #(.MAX_CNT(5)) count1 (
        .clk, .rst(rst | reset_digits),
        .load, .digit_in(digit1_s),
        .tick_pos(carry_pos_d0), .tick_neg(carry_neg_d0),
        .digit(digit1_t), .carry_pos(carry_pos_d1), .carry_neg(carry_neg_d1)
    );

    // Minutes
    digit_counter count2 (
        .clk, .rst(rst | reset_digits),
        .load, .digit_in(digit2_s),
        .tick_pos(carry_pos_d1|| (state==STOPPED_MIN && pulse_pos)), .tick_neg(carry_neg_d1|| (state==STOPPED_MIN && pulse_neg)),
        .digit(digit2_t), .carry_pos(carry_pos_d2), .carry_neg(carry_neg_d2)
    );
    digit_counter #(.MAX_CNT(5)) count3 (
        .clk, .rst(rst | reset_digits),
        .load, .digit_in(digit3_s),
        .tick_pos(carry_pos_d2), .tick_neg(carry_neg_d2),
        .digit(digit3_t), .carry_pos(), .carry_neg(carry_neg_d3)
    );

    assign digit0 = (state==STOPPED_SEC&&!ff_500ms) ? 4'hA : digit0_t;
    assign digit1 = (state==STOPPED_SEC&&!ff_500ms) ? 4'hA : digit1_t;
    assign digit2 = (state==STOPPED_MIN&&!ff_500ms) ? 4'hA : digit2_t;
    assign digit3 = (state==STOPPED_MIN&&!ff_500ms) ? 4'hA : digit3_t;

    // Active low
    assign dp = !(state==RUNNING ? (ff_500ms) : 1);
endmodule