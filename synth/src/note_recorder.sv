module note_recorder (
    input logic clk, rst,
    input logic note_tick,
    input logic sample_tick,
    input logic pulse_play_stop, pulse_edit, pulse_left, pulse_right, pulse_clear_note,
    input logic [7:0] midi_in,
    output logic [23:0] inc,
    output logic gate,
    output logic [15:0] led,
    output logic [3:0] bar_count
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

    note_midi_inc midi_lut (.midi((state==PLAYING) ? note_buf[current_position] : midi_in), .inc(inc_raw));
    always_ff @(posedge clk) begin
        if (rst) inc_latched <= '0;
        else if (inc_raw != 24'h000000) inc_latched <= inc_raw;
    end
    assign inc = gate ? inc_raw : inc_latched;
    
    always_ff @(posedge clk) begin
        if (rst) gate <= 0;
        else gate <= (state==PLAYING) ? (note_buf[current_position]!=8'hFF && !new_note) : (midi_in!=8'hFF);
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

            if (state == EDITING) begin
                if (pulse_left) current_position <= current_position - 1;
                else if (pulse_right) current_position <= current_position + 1;
                else if (pulse_clear_note) note_buf[current_position] <= 8'hFF;
                else begin
                    if (midi_in != 8'hFF) note_buf[current_position] <= midi_in;
                end
            end
            else if (state == PLAYING) begin
                if (pulse_clear_note) current_position <= '0;
                if (note_tick) begin
                    if (note_buf[current_position + 1] != note_buf[current_position]) new_note <= 1;
                    current_position <= current_position + 1;
                end
            end
            else begin // Idle
                if (pulse_clear_note) current_position <= '0;
            end
        end
    end
    
endmodule