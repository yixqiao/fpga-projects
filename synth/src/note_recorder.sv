module note_recorder (
    input logic clk, rst,
    input logic note_tick,
    input logic sw_clear_note,
    input logic is_playing,
    input logic is_editing,
    input logic [5:0] position,
    input logic new_note,
    input logic [7:0] midi_in,
    output logic [7:0] midi_out,
    output logic [15:0] led
);    
    logic [7:0] note_buf [0:63];

    logic [23:0] inc_raw, inc_latched;

    // LED output
    logic [2:0] flash_counter;
    always_ff @(posedge clk) begin
        if (rst) flash_counter <= '0;
        else if (note_tick) flash_counter <= flash_counter + 1;
    end
    always_comb begin
        for (int j = 0; j < 16; j++) begin
            if (is_playing) begin
                led[j] = (position[3:0] == 4'(15-j))
                    ? !(note_buf[{position[5:4], 4'(15-j)}] != 8'hFF)
                    :  (note_buf[{position[5:4], 4'(15-j)}] != 8'hFF);
            end
            else if (is_editing) begin
                led[j] = (position[3:0] == 4'(15-j))
                    ? flash_counter[0]
                    : (note_buf[{position[5:4], 4'(15-j)}] != 8'hFF);
            end
            else begin
                led[j] = (position[3:0] == 4'(15-j)) // Idle
                    ? flash_counter[2]
                    : (note_buf[{position[5:4], 4'(15-j)}] != 8'hFF);
            end
        end
    end

    // Idle: pass through keyboard
    // Editing: pass through keyboard
    // Playing: read from note_buf

    logic new_different_note;
    assign new_different_note = new_note && note_buf[position - 1] != note_buf[position];

    always_ff @(posedge clk) begin
        if (rst) midi_out <= 8'hFF;
        else if (is_playing) midi_out <= new_different_note ? 8'hFF : note_buf[position];
        else midi_out <= midi_in;
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i=0; i<64; i++) note_buf[i] <= 8'hFF;
        end else begin
            if (is_editing) begin
                if (sw_clear_note) note_buf[position] <= 8'hFF;
                else begin
                    if (midi_in != 8'hFF) note_buf[position] <= midi_in;
                end
            end
        end
    end
    
endmodule