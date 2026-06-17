module note_recorder (
    input logic clk, rst,
    input logic note_tick,
    input logic sample_tick,
    input logic pulse_play_stop, pulse_edit, pulse_left, pulse_right, sw_clear_reset,
    input logic pulse_bar_left, pulse_bar_right,
    input logic [7:0] midi_in,
    output logic [7:0] midi_out,
    output logic [15:0] led,
    output logic [3:0] bar_count,
    output logic is_editing
);    
    localparam IDLE=0, EDITING=1, PLAYING=2;

    logic [1:0] state, next_state;

    logic [5:0] current_position; // Bar/4, 16th note
    logic [7:0] note_buf [0:63];

    logic new_note;

    logic [23:0] inc_raw, inc_latched;

    assign bar_count = current_position[5:4];
    logic [2:0] flash_counter;
    always_ff @(posedge clk) begin
        if (rst) flash_counter <= '0;
        else if (note_tick) flash_counter <= flash_counter + 1;
    end
    always_comb begin
        for (int j = 0; j < 16; j++) begin
            unique case (state)
                PLAYING: led[j] = (current_position[3:0] == 4'(15-j))
                                ? !(note_buf[{current_position[5:4], 4'(15-j)}] != 8'hFF)
                                :  (note_buf[{current_position[5:4], 4'(15-j)}] != 8'hFF);
                EDITING: led[j] = (current_position[3:0] == 4'(15-j))
                                ? flash_counter[0]
                                : (note_buf[{current_position[5:4], 4'(15-j)}] != 8'hFF);
                default: led[j] = (current_position[3:0] == 4'(15-j)) // Idle
                                ? flash_counter[2]
                                : (note_buf[{current_position[5:4], 4'(15-j)}] != 8'hFF);
            endcase
        end
    end

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

    // Idle: pass through keyboard
    // Editing: pass through keyboard
    // Playing: read from note_buf

    always_ff @(posedge clk) begin
        if (rst) midi_out <= 8'hFF;
        else if (state==PLAYING) midi_out <= new_note ? 8'hFF : note_buf[current_position];
        else midi_out <= midi_in;
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            current_position <= 0;
            for (int i=0; i<64; i++) note_buf[i] <= 8'hFF;
        end
        else begin
            state <= next_state;
            if (sample_tick) new_note <= 0;

            if (pulse_bar_left) current_position <= current_position - 16;
            else if (pulse_bar_right) current_position <= current_position + 16;
            else begin
                if (state == EDITING) begin
                    if (pulse_left) current_position <= current_position - 1;
                    else if (pulse_right) current_position <= current_position + 1;
                    else if (sw_clear_reset) note_buf[current_position] <= 8'hFF;
                    else begin
                        if (midi_in != 8'hFF) note_buf[current_position] <= midi_in;
                    end
                end
                else if (state == PLAYING) begin
                    if (sw_clear_reset) current_position <= '0;
                    if (note_tick) begin
                        if (note_buf[current_position + 1] != note_buf[current_position]) new_note <= 1;
                        current_position <= current_position + 1;
                    end
                end
                else begin // Idle
                    if (sw_clear_reset) current_position <= '0;
                end
            end
        end
    end
    
endmodule