module note_seq_master (
    input logic clk, rst,
    input logic note_tick, sample_tick,
    input logic pulse_edit, pulse_play_stop,
    input logic pulse_left, pulse_right,
    input logic pulse_bar_left, pulse_bar_right,
    input logic pulse_reset_position,
    output logic is_playing, is_editing,
    output logic [5:0] position,
    output logic new_note,
    output logic [3:0] bar_count
);
    localparam IDLE=0, PLAYING=1, EDITING=2;
    logic [1:0] state, next_state;
    
    assign is_playing = state == PLAYING;
    assign is_editing = state == EDITING;

    // Transitions
    always_comb begin
        case (state)
            IDLE: next_state = pulse_edit ? EDITING : (pulse_play_stop ? PLAYING : IDLE);
            EDITING: next_state = pulse_edit ? IDLE : (pulse_play_stop ? PLAYING : EDITING);
            PLAYING: next_state = pulse_edit ? EDITING : (pulse_play_stop ? IDLE : PLAYING);
            default: next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            position <= 0;
            new_note <= 0;
        end
        else begin
            state <= next_state;
            if (sample_tick) new_note <= 0;

            if (pulse_bar_left) position <= position - 16;
            else if (pulse_bar_right) position <= position + 16;
            else if (pulse_reset_position) position <= '0;
            else begin
                if (state == EDITING) begin
                    if (pulse_left) position <= position - 1;
                    else if (pulse_right) position <= position + 1;
                end else if (state == PLAYING) begin
                    if (note_tick) begin
                        new_note <= 1;
                        position <= position + 1;
                    end
                end
            end
        end
    end

    assign bar_count = position[5:4];
endmodule