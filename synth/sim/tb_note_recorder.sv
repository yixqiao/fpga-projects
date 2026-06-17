`timescale 1ns / 1ps

module tb_note_recorder;
    logic clk, rst, note_tick, sample_tick;
    logic pulse_play_stop, pulse_edit, pulse_left, pulse_right, pulse_clear_note;
    logic [7:0] midi_in;
    logic [23:0] inc;
    logic gate;
    logic [15:0] led;
    logic [3:0] bar_count;

    note_recorder dut (
        .clk, .rst, .note_tick, .sample_tick,
        .pulse_play_stop, .pulse_edit, .pulse_left, .pulse_right,
        .midi_in, .inc, .gate,
        .led, .bar_count
    );

    // Clock
    initial clk = 0;
    always #5 clk = ~clk;

    assign sample_tick = 1;

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

    // Pulse one signal high for a single cycle
    task pulse_right_step;
        begin
            @(posedge clk); pulse_right = 1;
            @(posedge clk); pulse_right = 0;
        end
    endtask

    task pulse_clear_step;
        begin
            @(posedge clk); pulse_clear_note = 1;
            @(posedge clk); pulse_clear_note = 0;
        end
    endtask

    integer i;
    initial begin
        $dumpfile("sim/tb_note_recorder.vcd");
        $dumpvars(0, tb_note_recorder);

        rst = 1;
        pulse_play_stop = 0; pulse_edit = 0;
        pulse_left = 0; pulse_right = 0; pulse_clear_note = 0;
        repeat(4) @(posedge clk);
        rst = 0;
        repeat(4) @(posedge clk);

        // Enter EDITING (starts at position 0)
        @(posedge clk); pulse_edit = 1;
        @(posedge clk); pulse_edit = 0;

        // Write ~10 steps. Held midi_in gets written to the current position
        // automatically while in EDITING; clear a couple of steps to make rests.
        for (i = 0; i < 10; i++) begin
            wait_ticks(1);              // new pattern value now present + written
            if (i == 3 || i == 7)       // every so often, clear -> rest
                pulse_clear_step;
            pulse_right_step;           // advance to next 16th
        end

        // Switch to IDLE
        @(posedge clk); pulse_edit = 1;
        @(posedge clk); pulse_edit = 0;
        repeat(10) @(posedge clk);

        // Play back the recorded pattern, loop through twice
        @(posedge clk); pulse_play_stop = 1;
        @(posedge clk); pulse_play_stop = 0;
        wait_ticks(140);

        // Stop
        @(posedge clk); pulse_play_stop = 1;
        @(posedge clk); pulse_play_stop = 0;
        repeat(20) @(posedge clk);

        $finish;
    end

endmodule