module top (
    input logic clk,
    input logic [15:0] sw,
    input logic btnC, btnU, btnL, btnR, btnD,
    input logic enc_a, enc_b,
    input logic PS2Clk, PS2Data,
    output logic [15:0] led,
    output logic [6:0] seg,
    output logic dp,
    output logic [3:0] an,
    output logic mclk, bclk, lrclk, sdin
);
    // ------------------------------------------------------------
    // Sample_tick is output from the last module

    logic sample_tick;

    logic [23:0] phase;

    logic [23:0] inc;
    logic [23:0] sample_wave, sample_wave_detune, sample_env, sample_svf, sample_vol;

    logic is_editing;
    
    // ------------------------------------------------------------
    // Reset gen

    logic rst;
    rst_gen rg (.clk, .rst);

    // ------------------------------------------------------------
    // PS2 input (output scancode, valid)

    logic [7:0] ps2_scancode;
    logic ps2_valid;
    io_ps2_rx ps2 (.clk, .rst, .ps2_clk(PS2Clk), .ps2_data(PS2Data), .scancode(ps2_scancode), .valid(ps2_valid));
    
    // ------------------------------------------------------------
    // Controls (output various controls)

    logic rotary_pulse_pos, rotary_pulse_neg;
    io_rotary_decoder rot_dec (.clk, .rst, .enc_a, .enc_b, .pulse_pos(rotary_pulse_pos), .pulse_neg(rotary_pulse_neg));

    logic [1:0] wave_sel;
    logic detune_sel;
    logic [2:0] vol_shift;
    logic [4:0] vol_a_shift, vol_d_shift, vol_r_shift;
    logic [11:0] vol_s_level;
    logic [15:0] filter_F_floor;
    logic [15:0] filter_k;
    logic [15:0] filter_F_env_amount;
    logic [4:0] filter_a_shift, filter_d_shift, filter_r_shift;
    logic [11:0] filter_s_level;

    logic [2:0] global_vol_shift;

    logic [3:0] control_digit_value;

    control_params control (
        .clk, .rst,
        .sw,
        .rotary_pulse_pos(!is_editing && rotary_pulse_pos), .rotary_pulse_neg(!is_editing && rotary_pulse_neg),

        .vol_shift, .wave_sel, .detune_sel,
        .vol_a_shift, .vol_d_shift, .vol_r_shift, .vol_s_level,
        .filter_F_floor, .filter_k, .filter_F_env_amount,
        .filter_a_shift, .filter_d_shift, .filter_r_shift, .filter_s_level,
        
        .global_vol_shift,

        .digit_value(control_digit_value)
    );


    // ------------------------------------------------------------
    // Input processing (output buttons, keyboard midi)

    logic adsr_gate;
    logic pulse_play_stop, pulse_edit, pulse_bar_left, pulse_bar_right, btn_clear_reset;
    io_btn_debouncer db_pulse_play_stop(.clk, .rst, .in(btnC), .out(), .pulse_pos(pulse_play_stop), .pulse_neg());
    io_btn_debouncer db_pulse_edit(.clk, .rst, .in(btnU), .out(), .pulse_pos(pulse_edit), .pulse_neg());
    io_btn_debouncer db_pulse_bar_left(.clk, .rst, .in(btnL), .out(), .pulse_pos(pulse_bar_left), .pulse_neg());
    io_btn_debouncer db_pulse_bar_right(.clk, .rst, .in(btnR), .out(), .pulse_pos(pulse_bar_right), .pulse_neg());
    io_btn_debouncer db_btn_clear_reset(.clk, .rst, .in(btnD), .out(btn_clear_reset), .pulse_pos(), .pulse_neg());

    logic [7:0] midi_from_keyboard, midi_from_keyboard_raw;
    note_ps2_midi ps2_to_midi(.clk, .rst, .scancode(ps2_scancode), .valid(ps2_valid), .midi(midi_from_keyboard_raw)); // PS2 to midi
    always_comb begin
        if (midi_from_keyboard_raw == 8'hFF) midi_from_keyboard = 8'hFF;
        else begin 
            case (sw[1:0])
                2'b00: midi_from_keyboard = midi_from_keyboard_raw - 12;
                2'b01: midi_from_keyboard = midi_from_keyboard_raw;
                2'b10: midi_from_keyboard = midi_from_keyboard_raw + 12;
                2'b11: midi_from_keyboard = midi_from_keyboard_raw + 24;
            endcase
        end
    end


    // ------------------------------------------------------------
    // Voices (output sample_out, some display info)

    logic note_tick;
    clk_divider #(.DIV(12_500_000)) note_div (.clk, .rst, .tick(note_tick));
    
    logic [3:0] bar_count;

    voice voice1 (
        .clk, .rst,
        .wave_sel, .detune_sel, .vol_shift,
        .vol_a_shift, .vol_d_shift, .vol_r_shift, .vol_s_level,
        .filter_F_floor, .filter_k, .filter_F_env_amount, .filter_a_shift, .filter_d_shift, .filter_r_shift, .filter_s_level,

        .note_tick, .sample_tick,
        .pulse_play_stop, .pulse_edit, .pulse_bar_left, .pulse_bar_right, .btn_clear_reset,
        .rotary_pulse_pos(is_editing && rotary_pulse_pos), .rotary_pulse_neg(is_editing && rotary_pulse_neg),
        .midi_in(midi_from_keyboard),

        .led, .bar_count,
        .is_editing,
        .sample_out(sample_vol)
    );

    // ------------------------------------------------------------
    // Transmit to I2S

    io_i2s_tx tx (
        .clk, .rst,
        .left(sample_vol), .right(sample_vol),
        .sample_req(sample_tick),
        .mclk, .bclk, .lrclk, .sdin
    );

    // ------------------------------------------------------------
    // Output to 7seg

    seg7_mux4 seg7 (
        .clk, .rst,
        .digit3(4'd10), .digit2(control_digit_value), .digit1(4'd10), .digit0(bar_count + 4'd1), .dps(4'b0011),
        .seg, .dp, .an
    );
    
endmodule