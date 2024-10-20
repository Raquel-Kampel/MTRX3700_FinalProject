module fft_find_loudness #(
    parameter NSamples = 1024, // 1024 N-points
    parameter W        = 33,   // For 16x2 + 1
    parameter NBits    = $clog2(NSamples)

) (
    input                        clk,
    input                        reset,
    input  [W-1:0]               mag,
    input                        mag_valid,
    output logic [W-1:0]         peak = 0,
    output logic [NBits-1:0]     peak_k = 0,
    output logic                 peak_valid
);
    logic [NBits-1:0] i = 0, k;
    // The FFT k-index is represented by bit-reversing i. This has been done for you.
    always_comb for (integer j=0; j<NBits; j=j+1) k[j] = i[NBits-1-j]; // bit-reversed index

    logic [W-1:0]         peak_temp   = 0;
    logic [NBits-1:0]     peak_k_temp = 0;
    logic                 peak_valid_reg;

    always_ff @(posedge clk) begin : find_peak
        if (reset) begin
            // Reset all registers
            i              <= 0;
            peak           <= 0;
            peak_k         <= 0;
            peak_temp      <= 0;
            peak_k_temp    <= 0;
            peak_valid_reg <= 0;
        end else if (mag_valid) begin
            if (!k[NBits-1] && mag > peak_temp) begin
                peak_temp   <= mag;
                peak_k_temp <= k;
            end
            
            // Increment the sample index
            i <= i + 1;

            if (i == NSamples - 1) begin
                // Set the peak and peak_k when we've processed all samples
                peak       <= peak_temp;
                peak_k     <= peak_k_temp;
                peak_valid_reg <= 1'b1;

                // Reset for the next FFT window
                i          <= 0;
                peak_temp  <= 0;
                peak_k_temp <= 0;
            end else begin
                peak_valid_reg <= 1'b0;  // Peak valid for only one clock cycle
            end
        end else begin
            // Reset if mag_valid goes low (invalid data stream)
            i              <= 0;
            peak_temp      <= 0;
            peak_k_temp    <= 0;
            peak_valid_reg <= 0;
        end
    end

    assign peak_valid = peak_valid_reg;

endmodule
