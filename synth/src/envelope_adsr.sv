module envelope_adsr (
    input logic clk, rst,
    input logic gate,
    input logic sample_tick,
    input logic sel_a, sel_d, sel_s, sel_r,
    output logic [11:0] env_level
);
    localparam [11:0] ENV_MAX = 12'hFFF;
    localparam [11:0] LEAK_DELTA = 12'h001;

    localparam IDLE=0, ATTACK=1, DECAY=2, SUSTAIN=3, RELEASE=4;
    logic [2:0] state, next_state;
    logic pulse_start, pulse_end, gate_prev;
    logic [3:0] tick_cnt;

    logic [4:0] a_shift, d_shift, r_shift;
    logic [11:0] s_level;
    assign a_shift = sel_a ? 5'd10 : 5'd6;
    assign d_shift = sel_d ? 5'd10 : 5'd6;
    assign s_level = sel_s ? 12'h600: 12'h100;
    assign r_shift = sel_r ? 5'd10 : 5'd8;

    logic [11:0] attack_delta, decay_delta, release_delta;
    assign attack_delta  = (ENV_MAX - env_level) >> a_shift;
    assign decay_delta   = (env_level > s_level) ? ((env_level - s_level) >> d_shift) : 0;
    assign release_delta = env_level >> r_shift;

    // Combinational state transitions
    always_comb begin
        pulse_start = gate & !gate_prev;
        pulse_end = !gate & gate_prev;
        case (state)
            IDLE: next_state = pulse_start ? ATTACK : IDLE;
            ATTACK: next_state = pulse_end ? RELEASE : (attack_delta==0 ? DECAY : ATTACK);
            DECAY: next_state = pulse_end ? RELEASE : (decay_delta==0 ? SUSTAIN : DECAY);
            SUSTAIN: next_state = pulse_end ? RELEASE : SUSTAIN;
            RELEASE: next_state = pulse_start ? ATTACK : (release_delta==0 ? IDLE : RELEASE);
            default: next_state = IDLE;
        endcase 
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            gate_prev <= '0;
            env_level <= '0;
            tick_cnt <= '0;
        end
        else if (sample_tick) begin
            state <= next_state;
            gate_prev <= gate;
            tick_cnt <= tick_cnt + 1;

            if (tick_cnt == 0) begin
                case (state)
                    IDLE: env_level <= (env_level <= LEAK_DELTA) ? '0 : env_level - LEAK_DELTA;
                    ATTACK: env_level <= env_level + attack_delta;
                    DECAY: env_level <= env_level - decay_delta;
                    SUSTAIN: env_level <= (env_level <= s_level || env_level-s_level <= LEAK_DELTA) ? s_level : env_level - LEAK_DELTA;
                    RELEASE: env_level <= env_level - release_delta;
                endcase
            end
        end
    end
endmodule