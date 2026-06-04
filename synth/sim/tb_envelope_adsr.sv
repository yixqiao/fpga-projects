`timescale 1ns / 1ps

module tb_envelope_adsr;
    logic clk, rst, gate, sample_tick;
    logic sel_a, sel_d, sel_s, sel_r;
    logic [11:0] env_level;

    envelope_adsr dut (
        .clk, .rst, .gate, .sample_tick,
        .sel_a, .sel_d, .sel_s, .sel_r,
        .env_level
    );

    initial clk = 0;
    always #5 clk = ~clk;
    initial begin
        $dumpfile("sim/tb_envelope_adsr.vcd");
        $dumpvars(0, tb_envelope_adsr);

        rst = 1; gate = 0;
        sel_a=0; sel_d=0; sel_s=0; sel_r=0;
        repeat(4) @(posedge clk);
        rst = 0; sample_tick = 1;
        repeat(4) @(posedge clk);

        // Full ADSR cycle: hold gate through attack+decay, then release
        gate = 1;
        repeat(50000) @(posedge clk);
        gate = 0;
        repeat(10000) @(posedge clk);

        // Short press (staccato): release during attack
        gate = 1;
        repeat(2000) @(posedge clk);
        gate = 0;
        repeat(10000) @(posedge clk);

        // Retrigger during release
        sel_a=1; sel_d=1; sel_s=1; sel_r=1;
        gate = 1;
        repeat(10000) @(posedge clk);
        gate = 0;
        repeat(2000) @(posedge clk);
        
        gate = 1;
        repeat(2000) @(posedge clk);
        gate = 0;
        repeat(10000) @(posedge clk);

        $finish;
    end

endmodule