module waveform_gen #(
    parameter ROM_PATH = "data/sine_rom.hex"
)(
    input  logic [23:0] phase,
    input  logic [1:0]  wave_sel,
    output logic [23:0] sample
);
    logic [23:0] sine_rom [0:255];
    initial $readmemh(ROM_PATH, sine_rom);

    logic [21:0] tri_fold;
    logic [23:0] saw, square, triangle, sine;

    assign saw      = phase;
    assign square   = phase[23] ? 24'h800000 : 24'h7FFFFF;
    assign tri_fold = phase[22] ? ~phase[21:0] : phase[21:0];
    assign triangle = {phase[23], phase[23] ? ~tri_fold : tri_fold, 1'b0};
    assign sine     = sine_rom[phase[23:16]];

    always_comb begin
        case (wave_sel)
            2'b00: sample = saw;
            2'b01: sample = square;
            2'b10: sample = triangle;
            2'b11: sample = sine;
        endcase
    end
endmodule