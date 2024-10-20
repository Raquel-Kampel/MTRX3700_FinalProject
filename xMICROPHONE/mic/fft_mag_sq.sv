module fft_mag_sq #(
    parameter W = 16 // Bit-width of the real and imaginary FFT inputs
) (
    input                clk,       // Clock signal
    input                reset,     // Reset signal
    input                fft_valid, // Valid input data signal
    input        [W-1:0] fft_imag,  // FFT imaginary part
    input        [W-1:0] fft_real,  // FFT real part
    output logic [W*2:0] mag_sq,    // Magnitude squared output
    output logic         mag_valid  // Output valid signal
);

    // Intermediate signals
    logic signed [W*2-1:0] multiply_stage_real, multiply_stage_imag; // Results of multiplication
    logic signed [W*2:0]   add_stage; // Sum of squares (magnitude squared)
    
    // Shift register to delay valid signal by 2 clock cycles
    logic [1:0] valid_shift_reg;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Resetting all values on reset
            multiply_stage_real <= 0;
            multiply_stage_imag <= 0;
            add_stage           <= 0;
            valid_shift_reg      <= 2'b00;
        end else if (fft_valid || mag_valid) begin
            // Pipleline 1: Mulitply
            multiply_stage_real <= signed'(fft_real) * signed'(fft_real);
            multiply_stage_imag <= signed'(fft_imag) * signed'(fft_imag);

            // Pipleline 2: Add
            add_stage <= signed'(multiply_stage_real) + signed'(multiply_stage_imag);

            // Shift register to delay the valid signal by 2 clock cycles
            valid_shift_reg <= {valid_shift_reg[0], fft_valid};
        end 
    end

    // Output assignments
    assign mag_sq    = add_stage;
    assign mag_valid = valid_shift_reg[1]; // mag_sq becomes valid 2 cycles after fft_valid

endmodule
