`timescale 1ns / 1ps

module tb_note_recorder;
    logic clk, rst, note_tick, sample_tick;
    logic pulse_play_stop, pulse_arm, pulse_clear;
    logic [7:0] midi_in;
    logic [23:0] inc;
    logic gate;
    logic [3:0] leds_bar, leds_note, leds_sixteenth;

    // Small RECORD_DELAY so record_tick fits inside the 3-cycle note window
    note_recorder #(.RECORD_DELAY(1)) dut (
        .clk, .rst, .note_tick, .sample_tick,
        .pulse_play_stop, .pulse_arm, .pulse_clear,
        .midi_in, .inc, .gate,
        .leds_bar, .leds_note, .leds_sixteenth
    );

    // Clock
    initial clk = 0;
    always #5 clk = ~clk;

    // note_tick every 3 clock cycles, 1-cycle pulse
    integer tick_div;
    integer tick_count; // counts how many note_ticks have fired
    always_ff @(posedge clk) begin
        if (rst) begin
            tick_div   <= 0;
            note_tick  <= 0;
            tick_count <= 0;
        end else begin
            if (tick_div == 2) begin
                tick_div  <= 0;
                note_tick <= 1;
                tick_count <= tick_count + 1;
            end else begin
                tick_div  <= tick_div + 1;
                note_tick <= 0;
            end
        end
    end

    // Pattern driver: update midi_in on each note_tick.
    // Loop MIDI 36..72, with a rest (0xFF) every 5th step to test gate behavior.
    logic [7:0] pat_idx;
    always_ff @(posedge clk) begin
        if (rst) begin
            pat_idx <= 0;
            midi_in <= 8'hFF;
        end else if (note_tick) begin
            if (pat_idx % 5 == 4)
                midi_in <= 8'hFF;                 // rest
            else
                midi_in <= 8'd36 + (pat_idx % 37); // 36..72
            pat_idx <= pat_idx + 1;
        end
    end

    // Wait for N note_ticks
    task wait_ticks(input integer n);
        integer target;
        begin
            target = tick_count + n;
            while (tick_count < target) @(posedge clk);
        end
    endtask

    initial begin
        $dumpfile("sim/tb_note_recorder.vcd");
        $dumpvars(0, tb_note_recorder);

        rst = 1;
        pulse_play_stop = 0; pulse_arm = 0; pulse_clear = 0;
        repeat(4) @(posedge clk);
        rst = 0;
        repeat(4) @(posedge clk);

        // Start playback (buffer is all rests right now)
        @(posedge clk); pulse_play_stop = 1;
        @(posedge clk); pulse_play_stop = 0;

        // Let it run empty for a few ticks
        wait_ticks(5);

        // Arm — will enter ARMED, then RECORDING when position wraps to 0
        @(posedge clk); pulse_arm = 1;
        @(posedge clk); pulse_arm = 0;

        // Record through the full 4-bar lap (64 steps) plus margin
        // to cover the count-in wait + the 64 recording steps.
        wait_ticks(140);

        // Now in IDLE/PLAYING — let the recorded pattern loop through
        // a couple of times to verify playback + gate retrigger.
        wait_ticks(140);

        // Stop
        @(posedge clk); pulse_play_stop = 1;
        @(posedge clk); pulse_play_stop = 0;
        repeat(20) @(posedge clk);

        $finish;
    end

endmodule