module tb_waveform_gen;
    logic [23:0] phase;
    logic [1:0]  wave_sel;
    logic [23:0] sample;

    waveform_gen #(.ROM_PATH("data/sine_rom.hex")) dut (.phase, .wave_sel, .sample);

    initial begin
        $dumpfile("sim/tb_waveform_gen.vcd");
        $dumpvars(0, tb_waveform_gen);

        // Sawtooth
        wave_sel = 2'b00;
        for (int i = 0; i < 16; i++) begin
            phase = i * 24'h100000;
            #10;
        end

        // Square
        wave_sel = 2'b01;
        for (int i = 0; i < 16; i++) begin
            phase = i * 24'h100000;
            #10;
        end

        // Triangle
        wave_sel = 2'b10;
        for (int i = 0; i < 16; i++) begin
            phase = i * 24'h100000;
            #10;
        end

        // Sine
        wave_sel = 2'b11;
        for (int i = 0; i < 16; i++) begin
            phase = i * 24'h100000;
            #10;
        end

        $finish;
    end
endmodule