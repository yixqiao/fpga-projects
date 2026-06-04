module audio_volume_control (
    input logic [1:0] volume,
    input logic [23:0] sample_in,
    output logic [23:0] sample_out
);
    always_comb begin
        case (volume)
            2'b00: sample_out = $signed(sample_in) >>> 4;
            2'b01: sample_out = $signed(sample_in) >>> 3;
            2'b10: sample_out = $signed(sample_in) >>> 2;
            2'b11: sample_out = $signed(sample_in) >>> 1;
        endcase
    end
endmodule