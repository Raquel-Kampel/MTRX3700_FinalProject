module fft_loudness_calculator #(
    parameter W = 16, // Bit-width of the real and imaginary FFT inputs
    parameter NSamples = 1024  // Number of FFT points
) (
    input                clk,       // Clock signal
    input                reset,     // Reset signal
    input                fft_valid, // Valid input data signal
    input        [W-1:0] fft_imag,  // FFT imaginary part
    input        [W-1:0] fft_real,  // FFT real part
    output logic [W*2:0] mag_sq,    // Magnitude squared output
    output logic         mag_valid, // Output valid signal
    output logic [W*2+NBits:0] loudness, // Total loudness over FFT window
    output logic         loudness_valid  // Loudness valid signal
);

    localparam NBits = $clog2(NSamples); // Number of bits needed to count samples

    // Intermediate signals
    logic signed [W*2-1:0] multiply_stage_real, multiply_stage_imag; // Results of multiplication
    logic signed [W*2:0]   add_stage; // Sum of squares (magnitude squared)
    
    // Accumulator for total loudness
    logic [W*2+NBits:0] loudness_accum;
    logic [NBits-1:0]   sample_counter; // To keep track of number of samples
    logic [1:0] valid_shift_reg; // Shift register to delay valid signal

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Resetting all values on reset
            multiply_stage_real <= 0;
            multiply_stage_imag <= 0;
            add_stage           <= 0;
            valid_shift_reg     <= 2'b00;
            loudness_accum      <= 0;
            sample_counter      <= 0;
        end else if (fft_valid) begin
            // Pipeline stage 1: Multiply real and imaginary parts with themselves
            multiply_stage_real <= signed'(fft_real) * signed'(fft_real);
            multiply_stage_imag <= signed'(fft_imag) * signed'(fft_imag);

            // Pipeline stage 2: Add the squares to get magnitude squared
            add_stage <= signed'(multiply_stage_real) + signed'(multiply_stage_imag);

            // Accumulate the magnitude squared to compute loudness
            loudness_accum <= loudness_accum + add_stage;

            // Increment the sample counter
            sample_counter <= sample_counter + 1;

            // If we've processed all samples in this FFT window
            if (sample_counter == NSamples - 1) begin
                loudness <= loudness_accum;  // Store total loudness
                loudness_valid <= 1'b1;      // Signal that loudness is valid

                // Reset accumulator and counter for the next FFT window
                loudness_accum <= 0;
                sample_counter <= 0;
            end else begin
                loudness_valid <= 1'b0;  // Loudness valid for only one clock cycle
            end

            // Shift register to delay the valid signal by 2 clock cycles
            valid_shift_reg <= {valid_shift_reg[0], fft_valid};
        end else begin
            // Reset all values when fft_valid goes low
            sample_counter <= 0;
            loudness_accum <= 0;
            loudness_valid <= 0;
        end
    end

    // Output assignments
    assign mag_sq    = add_stage;            // Output magnitude squared
    assign mag_valid = valid_shift_reg[1];   // Delay mag_valid by 2 cycles

endmodule
