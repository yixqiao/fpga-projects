module envelope_adsr (
    input logic clk, rst,
    input logic gate,
    input logic sample_tick,
    // input logic sel_a, sel_d, sel_s, sel_r,
    output logic [23:0] env_level
);
    localparam [23:0] MAX_THRESH = 24'hFF0000;
    localparam [23:0] ZERO_THRESH = 24'h008000;
    localparam [23:0] SUS_DELTA_THRESH = 24'h002000;
    localparam [23:0] ENV_MAX = 24'hFFFFFF;

    localparam IDLE=0, ATTACK=1, DECAY=2, SUSTAIN=3, RELEASE=4;
    logic [2:0] state, next_state;
    logic pulse_start, pulse_end, gate_prev;

    logic [4:0] a_shift, d_shift, r_shift;
    logic [23:0] s_level;
    assign a_shift = 5'd12;
    assign d_shift = 5'd12;
    assign s_level = 24'h3FFFFF;
    assign r_shift = 5'd13;

    // Combinational state transitions
    always_comb begin
        pulse_start = gate & !gate_prev;
        pulse_end = !gate & gate_prev;
        case (state)
            IDLE: next_state = pulse_start ? ATTACK : IDLE;
            ATTACK: next_state = pulse_end ? RELEASE : (env_level >= MAX_THRESH ? DECAY : ATTACK);
            DECAY: next_state = pulse_end ? RELEASE : (env_level <= s_level + SUS_DELTA_THRESH ? SUSTAIN : DECAY);
            SUSTAIN: next_state = pulse_end ? RELEASE : SUSTAIN;
            RELEASE: next_state = pulse_start ? ATTACK : (env_level <= ZERO_THRESH ? IDLE : RELEASE);
        endcase 
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            gate_prev <= '0;
            env_level <= '0;
        end
        else if (sample_tick) begin
            state <= next_state;
            gate_prev <= gate;

            case (state)
                IDLE: env_level <= '0;
                ATTACK: env_level <= env_level + ((ENV_MAX - env_level) >> a_shift);
                DECAY: env_level <= env_level - ((env_level - s_level) >> d_shift);
                SUSTAIN: env_level <= s_level;
                RELEASE: env_level <= env_level - (env_level >> r_shift);
            endcase
        end
    end
endmodule