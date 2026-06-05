`timescale 1ns / 1ps

module tb_audio_svf;
    logic clk, rst, sample_tick;
    logic signed [23:0] sample_in, sample_out;

    audio_svf dut (
        .clk, .rst, .sample_tick,
        .sample_in,
        .F(16'sh2183), .Q(16'sh5A82),
        .filt_sel(2'b00),
        .sample_out
    );

    initial clk = 0;
    always #5 clk = ~clk;

    logic [3:0] tick_ctr;
    always_ff @(posedge clk) begin
        if (rst) begin
            tick_ctr    <= 0;
            sample_tick <= 0;
        end else begin
            sample_tick <= 0;
            if (tick_ctr == 9) begin
                tick_ctr    <= 0;
                sample_tick <= 1;
            end else begin
                tick_ctr <= tick_ctr + 1;
            end
        end
    end

    // Sawtooth: increment phase each sample tick, sample_in = phase[23:0]
    logic [23:0] phase;
    initial phase = 0;
    always @(posedge clk) begin
        if (sample_tick)
            phase <= phase + 24'h105590; // pitch: adjust increment as needed
    end
    assign sample_in = {~phase[23], phase[22:0]};

    initial begin
        $dumpfile("sim/tb_audio_svf.vcd");
        $dumpvars(0, tb_audio_svf);

        rst = 1;
        repeat(4) @(posedge clk);
        rst = 0;

        repeat(20000) @(posedge clk);
        $finish;
    end
endmodule