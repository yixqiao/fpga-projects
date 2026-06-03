module top (
    input clk,
    input sw,
    input btnC,
    input btnD,
    input enc_a,
    input enc_b,
    input enc_btn,
    output logic [15:0] led,
    output logic [6:0] seg,
    output logic dp,
    output logic [3:0] an
);

    // LED: 15 for stopwatch/timer, 13-10 for done, 9-0 for stopwatch

    logic rst;
    rst_gen rg (.clk, .rst);

    logic [3:0] sw_digit3, sw_digit2, sw_digit1, sw_digit0;
    logic [3:0] t_digit3, t_digit2, t_digit1, t_digit0;
    logic t_dp;


    logic pulse_start_stop, pulse_reset;
    io_btn_debouncer db_btnC (.clk, .rst, .in(btnC), .out(), .pulse(pulse_start_stop));
    io_btn_debouncer db_btnD (.clk, .rst, .in(btnD), .out(), .pulse(pulse_reset));

    logic pulse_pos, pulse_neg, pulse_rot_enc;
    io_rotary_decoder rot_dec (.clk, .rst, .enc_a, .enc_b, .pulse_pos, .pulse_neg);
    io_btn_debouncer db_enc_btn (.clk, .rst, .in(enc_btn), .out(), .pulse(pulse_rot_enc));

    logic timer_mode;
    
    assign timer_mode = sw;
    assign led[15] = timer_mode;
    assign led[14] = '0;
    assign led[10] = '0;

    // Stopwatch logic
    stopwatch sw_main (
        .clk, .rst,
        .pulse_start_stop(!timer_mode && pulse_start_stop), .pulse_reset(!timer_mode && pulse_reset),
        .digit3(sw_digit3), .digit2(sw_digit2), .digit1(sw_digit1), .digit0(sw_digit0), .onehot_display(led[9:0])
    );

    // Timer logic
    timer timer_main (
        .clk, .rst,
        .pulse_start_stop(timer_mode && pulse_start_stop), .pulse_reset(timer_mode && pulse_reset),
        .pulse_pos(timer_mode && pulse_pos), .pulse_neg(timer_mode && pulse_neg), .pulse_min_sec(timer_mode && pulse_rot_enc),
        .digit3(t_digit3), .digit2(t_digit2), .digit1(t_digit1), .digit0(t_digit0), .dp(t_dp), .leds_done(led[13:11])
    );
    
    // Muxed controller
    seg7_mux4 seg7_controller (
        .clk, .rst,
        .digit3(timer_mode ? t_digit3 : sw_digit3),
        .digit2(timer_mode ? t_digit2 : sw_digit2),
        .digit1(timer_mode ? t_digit1 : sw_digit1),
        .digit0(timer_mode ? t_digit0 : sw_digit0),
        .dps({1'b1, timer_mode ? t_dp : 1'b0, 1'b1, 1'b1}),
        .seg, .dp, .an
    );


    
endmodule