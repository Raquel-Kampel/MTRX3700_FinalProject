module fft_find_loudness #(
    parameter NSamples = 1024, // 1024 N-points
    parameter W        = 33,   // For 16x2 + 1
    parameter NBits    = $clog2(NSamples)
) (
    input                        clk,
    input                        reset,
    input  [W-1:0]               mag,          // Magnitude input from FFT
    input                        mag_valid,    // Indicates when mag is valid
    output logic [W+NBits-1:0]   loudness = 0, // Output total loudness
    output logic                 loudness_valid // Indicates valid loudness
);

    logic [NBits-1:0] i = 0;               // Sample counter
    logic [W+NBits-1:0] loudness_accum = 0;  // Accumulator for loudness
    logic loudness_valid_reg;

    always_ff @(posedge clk) begin : find_loudness
        if (reset) begin
            // Reset all registers
            i                <= 0;
            loudness         <= 0;
            loudness_accum   <= 0;
            loudness_valid_reg <= 0;
        end else if (mag_valid) begin
            // Accumulate the magnitude to calculate loudness
            loudness_accum <= loudness_accum + mag;
            
            // Increment the sample index
            i <= i + 1;

            if (i == NSamples - 1) begin
                // Set the loudness when all samples are processed
                loudness       <= loudness_accum;
                loudness_valid_reg <= 1'b1;

                // Reset for the next FFT window
                i              <= 0;
                loudness_accum <= 0;
            end else begin
                loudness_valid_reg <= 1'b0;  // Loudness valid for only one clock cycle
            end
        end else begin
            // Reset if mag_valid goes low (invalid data stream)
            i                <= 0;
            loudness_accum   <= 0;
            loudness_valid_reg <= 0;
        end
    end

    assign loudness_valid = loudness_valid_reg;

endmodule
