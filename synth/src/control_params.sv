module control_params(
    input logic clk, rst,
    input logic [15:0] sw,
    input logic rotary_pulse_pos, rotary_pulse_neg,

    output logic [1:0] wave_sel,
    output logic [2:0] vol_shift,
    output logic [4:0] vol_a_shift, vol_d_shift, vol_r_shift,
    output logic [11:0] vol_s_level,
    output logic [15:0] filter_F_floor,
    output logic [15:0] filter_k,
    output logic [15:0] filter_F_env_amount,
    output logic [4:0] filter_a_shift, filter_d_shift, filter_r_shift,
    output logic [11:0] filter_s_level,

    output logic [2:0] global_vol_shift
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
            default: curremt_param = INVALID_P;
        endcase
    end

    
    logic [1:0] wave_sel_c;
    lib_saturating_counter #(.WIDTH(2), .MAX_CNT(3)) wave_sel_cnt (
        .clk, .rst,
        .tick_pos(rotary_pulse_pos && current_param==WAVE_SEL_P), .tick_neg(rotary_pulse_neg && current_param==WAVE_SEL_P),
        .digit(wave_sel_c)
    );
    assign wave_sel = wave_sel_c;



endmodule

// 15 - reserved
// 14 - mode (voice/global)
// 13:12 - voice select
// 11:10 - mode select (oscillator, amplitude, filter, FX) or (master, effects, reserved)
// 9:6 - param select
// 5:0 - reserved

// Maybe: 1 for LED mode, 2 for octave