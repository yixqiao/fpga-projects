module note_recorder #(
    parameter RECORD_DELAY = 5_000_000
) (
    input logic clk, rst,
    input logic note_tick,
    input logic sample_tick,
    input logic pulse_play_stop, pulse_arm, pulse_clear,
    input logic [7:0] midi_in,
    output logic [23:0] inc,
    output logic gate,
    output logic [3:0] leds_bar, leds_note, leds_sixteenth,
    output logic led_state_record
);    
    localparam STOPPED=0, PLAYING=1;
    localparam IDLE=0, ARMED=1, RECORDING=2;

    logic state_play, next_state_play;
    logic [1:0] state_record, next_state_record; // TODO just one state

    logic [5:0] current_position; // Bar/4, 16th note
    logic [7:0] note_buf [0:63];

    logic [23:0] inc_raw, inc_latched;

    logic new_note;

    assign leds_bar = {2'b00, current_position[5:4]};
    assign leds_note = 4'b0001 << current_position[3:2];
    assign leds_sixteenth = 4'b0001 << current_position[1:0];

    assign led_state_record = state_record==ARMED ? 1 : (state_record==RECORDING ? !current_position[0] : 0);

    logic [$clog2(RECORD_DELAY)-1:0] record_cnt;
    logic record_tick;
    always_ff @(posedge clk) begin
        record_tick <= 0;
        if (note_tick) record_cnt <= 0;
        else if (record_cnt < RECORD_DELAY) record_cnt <= record_cnt + 1;
        else if (record_cnt == RECORD_DELAY) begin
            record_tick <= 1;
            record_cnt <= record_cnt + 1;
        end
    end

    // Transitions
    always_comb begin
        case (state_play)
            STOPPED: next_state_play = pulse_play_stop ? PLAYING : STOPPED;
            PLAYING: next_state_play = pulse_play_stop ? STOPPED : PLAYING;
        endcase

        case (state_record)
            IDLE: next_state_record = (state_play==PLAYING && pulse_arm) ? ARMED : IDLE;
            ARMED: next_state_record = (note_tick && current_position=='1 && state_play==PLAYING) ? RECORDING : ARMED;
            RECORDING: next_state_record = (record_tick && current_position=='1 && state_play==PLAYING) ? IDLE : RECORDING;
            default: next_state_record = IDLE;
        endcase
    end

    

    note_midi_inc midi_lut (.midi((state_play==STOPPED || state_record==RECORDING) ? midi_in : note_buf[current_position]), .inc(inc_raw));
    always_ff @(posedge clk) begin
        if (rst) inc_latched <= '0;
        else if (gate) inc_latched <= inc_raw;
    end
    assign inc = gate ? inc_raw : inc_latched;

    integer i;
    always_ff @(posedge clk) begin
        if (rst) begin
            state_play <= STOPPED;
            state_record <= IDLE;

            new_note <= 0;
            gate <= 0;
            current_position <= 0;
            for (i=0; i<64; i++) note_buf[i] <= 8'hFF;
        end
        else begin
            state_play <= next_state_play;
            state_record <= next_state_record;

            if (sample_tick) new_note <= 0;

            if (pulse_clear) begin
                for (i=0; i<64; i++) note_buf[i] <= 8'hFF;
            end

            if (state_play == PLAYING) begin
                if (state_record==RECORDING) begin
                    gate <= midi_in != 8'hFF;
                    if (record_tick) begin 
                        note_buf[current_position] <= midi_in;
                        current_position <= current_position + 1;
                    end
                end
                else begin
                    gate <= note_buf[current_position] != 8'hFF && !new_note;
                    if (note_tick) begin
                        if (note_buf[current_position + 1] != note_buf[current_position]) new_note <= 1;
                        current_position <= current_position + 1;
                    end
                end                
            end
            
            else begin
                // Not playing
                current_position <= '0;
                gate <= midi_in != 8'hFF;
            end
        end
    end
    
endmodule