module audio_volume_control (
    input logic signed [3:0] vol_shift,
    input logic [23:0] sample_in,
    output logic [23:0] sample_out
);
    logic signed [31:0] sample_shifted;
    always_comb begin
        if ($signed(vol_shift) < 0) sample_shifted = $signed(sample_in) >>> (-vol_shift);
        else sample_shifted = $signed(sample_in) <<< (vol_shift);
    end
    assign sample_out = sample_shifted[23:0];
endmodule