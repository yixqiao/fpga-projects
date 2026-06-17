module control_params(
    input logic clk, rst,
    input logic [15:0] sw,
    input logic rotary_pulse_pos, rotary_pulse_neg,

    output logic [1:0] wave_sel,
    output logic [2:0] vol_shift,
    output logic [4:0] vol_a_shift, vol_d_shift, vol_r_shift,
    output logic [11:0] vol_s_level,
    // output logic [15:0] filter_F_floor,
    // output logic [15:0] filter_k,
    // output logic [15:0] filter_F_env_amount,
    // output logic [4:0] filter_a_shift, filter_d_shift, filter_r_shift,
    // output logic [11:0] filter_s_level,

    output logic [2:0] global_vol_shift,
    output logic [3:0] digit_value
);
    localparam INVALID_P=0, WAVE_SEL_P=1, VOL_SHIFT_P=2, VOL_A_SHIFT_P=3, VOL_D_SHIFT_P=4, VOL_R_SHIFT_P=5, VOL_S_LEVEL_P=6;

    logic [4:0] current_param;

    logic mode_sw;
    logic [1:0] category_sw;
    logic [3:0] param_sw;
    assign mode_sw = sw[14];
    assign category_sw = sw[11:10];
    assign param_sw = sw[9:6];

    always_comb begin
        case ({mode_sw, category_sw, param_sw})
            6'b0_00_000: current_param = WAVE_SEL_P;
            6'b0_00_001: current_param = VOL_SHIFT_P;
            6'b0_00_100: current_param = VOL_A_SHIFT_P;
            6'b0_00_101: current_param = VOL_D_SHIFT_P;
            6'b0_00_110: current_param = VOL_R_SHIFT_P;
            6'b0_00_111: current_param = VOL_S_LEVEL_P;
            default: current_param = INVALID_P;
        endcase
    end

    
    logic [1:0] wave_sel_c;
    lib_saturating_counter #(.WIDTH(2), .MAX_CNT(3)) wave_sel_cnt (
        .clk, .rst,
        .tick_pos(rotary_pulse_pos && current_param==WAVE_SEL_P), .tick_neg(rotary_pulse_neg && current_param==WAVE_SEL_P),
        .digit(wave_sel_c)
    );
    assign wave_sel = wave_sel_c;

    logic [2:0] vol_shift_c;
    lib_saturating_counter #(.WIDTH(3), .MAX_CNT(7)) vol_shift_cnt (
        .clk, .rst,
        .tick_pos(rotary_pulse_pos && current_param==VOL_SHIFT_P), .tick_neg(rotary_pulse_neg && current_param==VOL_SHIFT_P),
        .digit(vol_shift_c)
    );
    always_comb begin
        case (vol_shift_c)
            3'd0: vol_shift = 7;
            3'd1: vol_shift = 6;
            3'd2: vol_shift = 5;
            3'd3: vol_shift = 4;
            3'd4: vol_shift = 3;
            3'd5: vol_shift = 2;
            3'd6: vol_shift = 1;
            3'd7: vol_shift = 0;
        endcase
    end
    
    logic [2:0] vol_a_shift_c;
    lib_saturating_counter #(.WIDTH(3), .MAX_CNT(7)) vol_a_shift_cnt (
        .clk, .rst,
        .tick_pos(rotary_pulse_pos && current_param==VOL_A_SHIFT_P), .tick_neg(rotary_pulse_neg && current_param==VOL_A_SHIFT_P),
        .digit(vol_a_shift_c)
    );
    always_comb begin
        case (vol_a_shift_c)
            3'd0: vol_a_shift = 5'd3;
            3'd1: vol_a_shift = 5'd4;
            3'd2: vol_a_shift = 5'd5;
            3'd3: vol_a_shift = 5'd6;
            3'd4: vol_a_shift = 5'd8;
            3'd5: vol_a_shift = 5'd9;
            3'd6: vol_a_shift = 5'd10;
            3'd7: vol_a_shift = 5'd11;
        endcase
    end

    assign vol_d_shift = 5'd10;
    assign vol_r_shift = 5'd8;
    assign vol_s_level = 12'h600;

    always_comb begin
        case (current_param)
            WAVE_SEL_P: digit_value = {2'b0, wave_sel_c};
            VOL_SHIFT_P: digit_value = {1'b0, vol_shift_c};
            VOL_A_SHIFT_P: digit_value = {1'b0, vol_a_shift_c};
            default: digit_value = 4'd10;
        endcase
    end


endmodule

// 15 - reserved
// 14 - mode (voice/global)
// 13:12 - voice select
// 11:10 - mode select (oscillator, amplitude, filter, FX) or (master, effects, reserved)
// 9:6 - param select
// 5:0 - reserved

// Maybe: 1 for LED mode, 2 for octave