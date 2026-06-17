module control_params(
    input logic clk, rst,
    input logic [15:0] sw,
    input logic rotary_pulse_pos, rotary_pulse_neg,

    output logic [2:0] vol_shift,
    output logic [1:0] wave_sel,
    output logic detune_sel,
    output logic [4:0] vol_a_shift, vol_d_shift, vol_r_shift,
    output logic [11:0] vol_s_level,
    output logic signed [15:0] filter_F_floor,
    output logic signed [15:0] filter_k,
    output logic signed [15:0] filter_F_env_amount,
    output logic [4:0] filter_a_shift, filter_d_shift, filter_r_shift,
    output logic [11:0] filter_s_level,

    output logic [2:0] global_vol_shift,
    output logic [3:0] digit_value
);
    localparam INVALID_P=0, VOL_SHIFT_P=1, WAVE_SEL_P=2, DETUNE_SEL_P=3, VOL_A_SHIFT_P=4, VOL_D_SHIFT_P=5, VOL_R_SHIFT_P=6, VOL_S_LEVEL_P=7;
    localparam FILTER_F_FLOOR_P=8, FILTER_K_P=9, FILTER_F_ENV_AMOUNT_P=10, FILTER_A_SHIFT_P=11, FILTER_D_SHIFT_P=12, FILTER_R_SHIFT_P=13, FILTER_S_LEVEL_P=14;
    localparam GLOBAL_VOL_SHIFT_P = 15;
    logic [4:0] current_param;

    logic mode_sw;
    logic [1:0] category_sw;
    logic [3:0] param_sw;
    assign mode_sw = sw[14];
    assign category_sw = sw[11:10];
    assign param_sw = sw[9:6];

    always_comb begin
        case ({mode_sw, category_sw, param_sw})
            7'b0_00_0000: current_param = VOL_SHIFT_P;
            7'b0_00_0001: current_param = WAVE_SEL_P;
            7'b0_00_0010: current_param = DETUNE_SEL_P;
            7'b0_00_0100: current_param = VOL_A_SHIFT_P;
            7'b0_00_0101: current_param = VOL_D_SHIFT_P;
            7'b0_00_0110: current_param = VOL_R_SHIFT_P;
            7'b0_00_0111: current_param = VOL_S_LEVEL_P;
            7'b0_01_0000: current_param = FILTER_F_FLOOR_P;
            7'b0_01_0001: current_param = FILTER_K_P;
            7'b0_01_0010: current_param = FILTER_F_ENV_AMOUNT_P;
            7'b0_01_0100: current_param = FILTER_A_SHIFT_P;
            7'b0_01_0101: current_param = FILTER_D_SHIFT_P;
            7'b0_01_0110: current_param = FILTER_R_SHIFT_P;
            7'b0_01_0111: current_param = FILTER_S_LEVEL_P;
            7'b1_00_0000: current_param = GLOBAL_VOL_SHIFT_P;
            default: current_param = INVALID_P;
        endcase
    end

    // ------------------------------------------------------------
    // Voice volume
    logic [2:0] vol_shift_c;
    lib_saturating_counter #(.WIDTH(3), .MAX_CNT(7), .DEFAULT(5)) vol_shift_cnt (
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

    // ------------------------------------------------------------
    // Waveform selection
    logic [1:0] wave_sel_c;
    lib_saturating_counter #(.WIDTH(2), .MAX_CNT(3), .DEFAULT(0)) wave_sel_cnt (
        .clk, .rst,
        .tick_pos(rotary_pulse_pos && current_param==WAVE_SEL_P), .tick_neg(rotary_pulse_neg && current_param==WAVE_SEL_P),
        .digit(wave_sel_c)
    );
    assign wave_sel = wave_sel_c;

    // ------------------------------------------------------------
    // Detune selection
    logic [1:0] detune_sel_c;
    lib_saturating_counter #(.WIDTH(1), .MAX_CNT(1), .DEFAULT(0)) detune_sel_cnt (
        .clk, .rst,
        .tick_pos(rotary_pulse_pos && current_param==DETUNE_SEL_P), .tick_neg(rotary_pulse_neg && current_param==DETUNE_SEL_P),
        .digit(detune_sel_c)
    );
    assign detune_sel = detune_sel_c;
    
    // ------------------------------------------------------------
    // Envelope attack
    logic [2:0] vol_a_shift_c;
    lib_saturating_counter #(.WIDTH(3), .MAX_CNT(7), .DEFAULT(3)) vol_a_shift_cnt (
        .clk, .rst,
        .tick_pos(rotary_pulse_pos && current_param==VOL_A_SHIFT_P), .tick_neg(rotary_pulse_neg && current_param==VOL_A_SHIFT_P),
        .digit(vol_a_shift_c)
    );
    always_comb begin
        case (vol_a_shift_c)
            3'd0: vol_a_shift = 5'd2;
            3'd1: vol_a_shift = 5'd4;
            3'd2: vol_a_shift = 5'd5;
            3'd3: vol_a_shift = 5'd6;
            3'd4: vol_a_shift = 5'd7;
            3'd5: vol_a_shift = 5'd8;
            3'd6: vol_a_shift = 5'd10;
            3'd7: vol_a_shift = 5'd11;
        endcase
    end

    // ------------------------------------------------------------
    // Envelope decay
    logic [2:0] vol_d_shift_c;
    lib_saturating_counter #(.WIDTH(3), .MAX_CNT(7), .DEFAULT(3)) vol_d_shift_cnt (
        .clk, .rst,
        .tick_pos(rotary_pulse_pos && current_param==VOL_D_SHIFT_P), .tick_neg(rotary_pulse_neg && current_param==VOL_D_SHIFT_P),
        .digit(vol_d_shift_c)
    );
    always_comb begin
        case (vol_d_shift_c)
            3'd0: vol_d_shift = 5'd4;
            3'd1: vol_d_shift = 5'd5;
            3'd2: vol_d_shift = 5'd6;
            3'd3: vol_d_shift = 5'd7;
            3'd4: vol_d_shift = 5'd8;
            3'd5: vol_d_shift = 5'd9;
            3'd6: vol_d_shift = 5'd10;
            3'd7: vol_d_shift = 5'd11;
        endcase
    end

    // ------------------------------------------------------------
    // Envelope release
    logic [2:0] vol_r_shift_c;
    lib_saturating_counter #(.WIDTH(3), .MAX_CNT(7), .DEFAULT(3)) vol_r_shift_cnt (
        .clk, .rst,
        .tick_pos(rotary_pulse_pos && current_param==VOL_R_SHIFT_P), .tick_neg(rotary_pulse_neg && current_param==VOL_R_SHIFT_P),
        .digit(vol_r_shift_c)
    );
    always_comb begin
        case (vol_r_shift_c)
            3'd0: vol_r_shift = 5'd4;
            3'd1: vol_r_shift = 5'd5;
            3'd2: vol_r_shift = 5'd6;
            3'd3: vol_r_shift = 5'd7;
            3'd4: vol_r_shift = 5'd8;
            3'd5: vol_r_shift = 5'd9;
            3'd6: vol_r_shift = 5'd10;
            3'd7: vol_r_shift = 5'd11;
        endcase
    end

    // ------------------------------------------------------------
    // Envelope sustain
    logic [2:0] vol_s_level_c;
    lib_saturating_counter #(.WIDTH(3), .MAX_CNT(7), .DEFAULT(3)) vol_s_level_cnt (
        .clk, .rst,
        .tick_pos(rotary_pulse_pos && current_param==VOL_S_LEVEL_P), .tick_neg(rotary_pulse_neg && current_param==VOL_S_LEVEL_P),
        .digit(vol_s_level_c)
    );
    always_comb begin
        case (vol_s_level_c)
            3'd0: vol_s_level = 12'h000;
            3'd1: vol_s_level = 12'h100;
            3'd2: vol_s_level = 12'h200;
            3'd3: vol_s_level = 12'h400;
            3'd4: vol_s_level = 12'h600;
            3'd5: vol_s_level = 12'h800;
            3'd6: vol_s_level = 12'hC00;
            3'd7: vol_s_level = 12'hF00;
        endcase
    end

    // ------------------------------------------------------------
    // Filter F floor
    logic [2:0] filter_F_floor_c;
    lib_saturating_counter #(.WIDTH(3), .MAX_CNT(7), .DEFAULT(2)) filter_F_floor_cnt (
        .clk, .rst,
        .tick_pos(rotary_pulse_pos && current_param==FILTER_F_FLOOR_P), .tick_neg(rotary_pulse_neg && current_param==FILTER_F_FLOOR_P),
        .digit(filter_F_floor_c)
    );
    always_comb begin
        case (filter_F_floor_c)
            3'd0: filter_F_floor = 16'sh0200;
            3'd1: filter_F_floor = 16'sh0800;
            3'd2: filter_F_floor = 16'sh1000;
            3'd3: filter_F_floor = 16'sh2000;
            3'd4: filter_F_floor = 16'sh3000;
            3'd5: filter_F_floor = 16'sh4000;
            3'd6: filter_F_floor = 16'sh5000;
            3'd7: filter_F_floor = 16'sh7000;
        endcase
    end

    // ------------------------------------------------------------
    // Filter k (Q)
    logic [2:0] filter_k_c;
    lib_saturating_counter #(.WIDTH(3), .MAX_CNT(7), .DEFAULT(3)) filter_k_cnt (
        .clk, .rst,
        .tick_pos(rotary_pulse_pos && current_param==FILTER_K_P), .tick_neg(rotary_pulse_neg && current_param==FILTER_K_P),
        .digit(filter_k_c)
    );
    always_comb begin
        case (filter_k_c)
            3'd0: filter_k = 16'sh6000;
            3'd1: filter_k = 16'sh5000;
            3'd2: filter_k = 16'sh4800;
            3'd3: filter_k = 16'sh4200;
            3'd4: filter_k = 16'sh3C00;
            3'd5: filter_k = 16'sh3600;
            3'd6: filter_k = 16'sh3000;
            3'd7: filter_k = 16'sh2800;
        endcase
    end

    // ------------------------------------------------------------
    // Filter envelope mod amount
    logic [2:0] filter_F_env_amount_c;
    lib_saturating_counter #(.WIDTH(3), .MAX_CNT(7), .DEFAULT(3)) filter_F_env_amount_cnt (
        .clk, .rst,
        .tick_pos(rotary_pulse_pos && current_param==FILTER_F_ENV_AMOUNT_P), .tick_neg(rotary_pulse_neg && current_param==FILTER_F_ENV_AMOUNT_P),
        .digit(filter_F_env_amount_c)
    );
    always_comb begin
        case (filter_F_env_amount_c)
            3'd0: filter_F_env_amount = 16'sh0000;
            3'd1: filter_F_env_amount = 16'sh0800;
            3'd2: filter_F_env_amount = 16'sh1000;
            3'd3: filter_F_env_amount = 16'sh2000;
            3'd4: filter_F_env_amount = 16'sh3000;
            3'd5: filter_F_env_amount = 16'sh4000;
            3'd6: filter_F_env_amount = 16'sh5000;
            3'd7: filter_F_env_amount = 16'sh7000;
        endcase
    end

    // ------------------------------------------------------------
    // Filter attack
    logic [2:0] filter_a_shift_c;
    lib_saturating_counter #(.WIDTH(3), .MAX_CNT(7), .DEFAULT(3)) filter_a_shift_cnt (
        .clk, .rst,
        .tick_pos(rotary_pulse_pos && current_param==FILTER_A_SHIFT_P), .tick_neg(rotary_pulse_neg && current_param==FILTER_A_SHIFT_P),
        .digit(filter_a_shift_c)
    );
    always_comb begin
        case (filter_a_shift_c)
            3'd0: filter_a_shift = 5'd2;
            3'd1: filter_a_shift = 5'd4;
            3'd2: filter_a_shift = 5'd5;
            3'd3: filter_a_shift = 5'd6;
            3'd4: filter_a_shift = 5'd7;
            3'd5: filter_a_shift = 5'd8;
            3'd6: filter_a_shift = 5'd10;
            3'd7: filter_a_shift = 5'd12;
        endcase
    end

    // ------------------------------------------------------------
    // Filter decay
    logic [2:0] filter_d_shift_c;
    lib_saturating_counter #(.WIDTH(3), .MAX_CNT(7), .DEFAULT(3)) filter_d_shift_cnt (
        .clk, .rst,
        .tick_pos(rotary_pulse_pos && current_param==FILTER_D_SHIFT_P), .tick_neg(rotary_pulse_neg && current_param==FILTER_D_SHIFT_P),
        .digit(filter_d_shift_c)
    );
    always_comb begin
        case (filter_d_shift_c)
            3'd0: filter_d_shift = 5'd4;
            3'd1: filter_d_shift = 5'd6;
            3'd2: filter_d_shift = 5'd7;
            3'd3: filter_d_shift = 5'd8;
            3'd4: filter_d_shift = 5'd9;
            3'd5: filter_d_shift = 5'd10;
            3'd6: filter_d_shift = 5'd11;
            3'd7: filter_d_shift = 5'd12;
        endcase
    end

    // ------------------------------------------------------------
    // Filter release
    logic [2:0] filter_r_shift_c;
    lib_saturating_counter #(.WIDTH(3), .MAX_CNT(7), .DEFAULT(3)) filter_r_shift_cnt (
        .clk, .rst,
        .tick_pos(rotary_pulse_pos && current_param==FILTER_R_SHIFT_P), .tick_neg(rotary_pulse_neg && current_param==FILTER_R_SHIFT_P),
        .digit(filter_r_shift_c)
    );
    always_comb begin
        case (filter_r_shift_c)
            3'd0: filter_r_shift = 5'd3;
            3'd1: filter_r_shift = 5'd5;
            3'd2: filter_r_shift = 5'd7;
            3'd3: filter_r_shift = 5'd8;
            3'd4: filter_r_shift = 5'd9;
            3'd5: filter_r_shift = 5'd10;
            3'd6: filter_r_shift = 5'd11;
            3'd7: filter_r_shift = 5'd12;
        endcase
    end

    // ------------------------------------------------------------
    // Filter sustain
    logic [2:0] filter_s_level_c;
    lib_saturating_counter #(.WIDTH(3), .MAX_CNT(7), .DEFAULT(3)) filter_s_level_cnt (
        .clk, .rst,
        .tick_pos(rotary_pulse_pos && current_param==FILTER_S_LEVEL_P), .tick_neg(rotary_pulse_neg && current_param==FILTER_S_LEVEL_P),
        .digit(filter_s_level_c)
    );
    always_comb begin
        case (filter_s_level_c)
            3'd0: filter_s_level = 12'h000;
            3'd1: filter_s_level = 12'h100;
            3'd2: filter_s_level = 12'h200;
            3'd3: filter_s_level = 12'h400;
            3'd4: filter_s_level = 12'h600;
            3'd5: filter_s_level = 12'h800;
            3'd6: filter_s_level = 12'hC00;
            3'd7: filter_s_level = 12'hF00;
        endcase
    end

    // ------------------------------------------------------------
    // Global volume
    logic [2:0] global_vol_shift_c;
    lib_saturating_counter #(.WIDTH(3), .MAX_CNT(7), .DEFAULT(6)) global_vol_shift_cnt (
        .clk, .rst,
        .tick_pos(rotary_pulse_pos && current_param==GLOBAL_VOL_SHIFT_P), .tick_neg(rotary_pulse_neg && current_param==GLOBAL_VOL_SHIFT_P),
        .digit(global_vol_shift_c)
    );
    always_comb begin
        case (global_vol_shift_c)
            3'd0: global_vol_shift = 7;
            3'd1: global_vol_shift = 6;
            3'd2: global_vol_shift = 5;
            3'd3: global_vol_shift = 4;
            3'd4: global_vol_shift = 3;
            3'd5: global_vol_shift = 2;
            3'd6: global_vol_shift = 1;
            3'd7: global_vol_shift = 0;
        endcase
    end

    // ------------------------------------------------------------
    // 7seg display
    always_comb begin
        case (current_param)
            VOL_SHIFT_P: digit_value = {1'b0, vol_shift_c};
            WAVE_SEL_P: digit_value = {2'b0, wave_sel_c};
            DETUNE_SEL_P: digit_value = {3'b0, detune_sel_c};
            VOL_A_SHIFT_P: digit_value = {1'b0, vol_a_shift_c};
            VOL_D_SHIFT_P: digit_value = {1'b0, vol_d_shift_c};
            VOL_R_SHIFT_P: digit_value = {1'b0, vol_r_shift_c};
            VOL_S_LEVEL_P: digit_value = {1'b0, vol_s_level_c};
            FILTER_F_FLOOR_P: digit_value = {1'b0, filter_F_floor_c};
            FILTER_K_P: digit_value = {1'b0, filter_k_c};
            FILTER_F_ENV_AMOUNT_P: digit_value = {1'b0, filter_F_env_amount_c};
            FILTER_A_SHIFT_P: digit_value = {1'b0, filter_a_shift_c};
            FILTER_D_SHIFT_P: digit_value = {1'b0, filter_d_shift_c};
            FILTER_R_SHIFT_P: digit_value = {1'b0, filter_r_shift_c};
            FILTER_S_LEVEL_P: digit_value = {1'b0, filter_s_level_c};
            GLOBAL_VOL_SHIFT_P: digit_value = {1'b0, global_vol_shift_c};
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