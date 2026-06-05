`timescale 1ns / 1ps

module tb_audio_svf;
    logic clk, rst, sample_tick;
    logic signed [23:0] sample_in, sample_out;

    audio_svf dut (
        .clk, .rst, .sample_tick,
        .sample_in,
        .F(16'sh0041), .Q(16'sh5A82),
        .filt_sel(2'b00),
        .sample_out
    );

    initial clk = 0;
    always #5 clk = ~clk;

    always begin
        sample_tick = 0;
        repeat(9) @(posedge clk);
        @(negedge clk);
        sample_tick = 1;
        @(negedge clk);
    end

    // Sawtooth: increment phase each sample tick, sample_in = phase[23:0]
    logic [23:0] phase;
    initial phase = 0;
    always @(posedge clk) begin
        if (sample_tick)
            phase <= phase + 24'h008000; // pitch: adjust increment as needed
    end
    assign sample_in = {~phase[23], phase[22:0]}; // sawtooth is just the phase

    initial begin
        $dumpfile("sim/tb_audio_svf.vcd");
        $dumpvars(0, tb_audio_svf);

        rst = 1;
        repeat(4) @(posedge clk);
        rst = 0;

        repeat(200000) @(posedge clk);
        $finish;
    end
endmodule