module note_select (
    input logic [1:0] note_sel,
    output logic [23:0] inc
);
    // inc = f / f_sample * 2^24
    // f_sample = 48828
    always_comb begin
        case (note_sel)
            2'b00: inc = 24'd151_183; // A4
            2'b01: inc = 24'd89_896; // C4
            2'b10: inc = 24'd113_260; // E4
            2'b11: inc = 24'd134_691; // G4
        endcase
    end
endmodule