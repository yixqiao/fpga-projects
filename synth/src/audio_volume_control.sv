module audio_volume_control (
    input logic [2:0] vol_shift,
    input logic [23:0] sample_in,
    output logic [23:0] sample_out
);
    assign sample_out = $signed(sample_in) >>> vol_shift;
endmodule