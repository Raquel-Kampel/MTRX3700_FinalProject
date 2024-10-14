module fft_loudness_detect (
    input clk,
    input audio_clk,
    input reset,
    dstream.in  audio_input,
    dstream.out loudness_output
);
    parameter W        = 16;   // Bit-width for FFT input data
    parameter NSamples = 1024; // Number of FFT points

    logic           di_en;  //  Input Data Enable
    logic   [W-1:0] di_re;  //  Input Data (Real)
    logic   [W-1:0] di_im;  //  Input Data (Imag)

    logic           do_en;  //  Output Data Enable
    logic   [W-1:0] do_re;  //  Output Data (Real)
    logic   [W-1:0] do_im;  //  Output Data (Imag)

    initial do_en = 0;
    initial do_re = 0;
    initial do_im = 0;
    
    assign  di_im = 0; // No imaginary parts (audio signal is purely real).

    logic           mag_valid;
    logic   [W*2:0] mag_sq;   // Magnitude squared
    logic   [W*2+9:0] loudness;  // Total loudness value
    logic           loudness_valid; // Valid signal for loudness

    integer decimate_counter = 0;
    
    dstream #(.N(2*W))    conv_input   ();
    dstream #(.N(2*W))    conv_output  ();
    dstream #(.N(W))      audio_input_processed  ();
    
    assign conv_input.valid = audio_input.valid;
    assign conv_input.data  = {audio_input.data, 16'b0}; // Extend audio samples to 32 bits (16-bit fraction).
    assign audio_input.ready = conv_input.ready;
    
    // Low-pass filter and decimation
    low_pass_conv #(.W(2*W), .W_FRAC(W)) u_anti_alias_filter ( // Use 32 bits, 16 bit fraction.
        .clk(audio_clk),
        .x(conv_input),
        .y(conv_output)
    );
    
    always_ff @(posedge audio_clk) if (conv_output.valid) decimate_counter <= decimate_counter == 3 ? 0 : decimate_counter + 1; 
    assign audio_input_processed.data  = conv_output.data[31:16]; // Retrieve the 16-bit integer part for our audio samples.
    assign audio_input_processed.valid = conv_output.valid && decimate_counter == 0; // Down-sample! Use every 4th sample.
    assign conv_output.ready = 1; // No back-pressure needed given 48 kHz << 18.432 MHz.
    
    // FFT Input Buffer
    fft_input_buffer #(.W(W), .NSamples(NSamples)) u_fft_input_buffer (
        .clk(clk), 
        .reset(reset), 
        .audio_clk(audio_clk), 
        .audio_input(audio_input_processed), 
        .fft_input(di_re), 
        .fft_input_valid(di_en)
    );
    
    // FFT Calculation
    FFT #(.WIDTH(W)) u_fft_ip (
        .clock(clk), 
        .reset(reset), 
        .di_en(di_en), 
        .di_re(di_re), 
        .di_im(di_im), 
        .do_en(do_en), 
        .do_re(do_re), 
        .do_im(do_im)
    );
    
    // Magnitude Squared Calculation
    fft_mag_sq #(.W(W)) u_fft_mag_sq (
        .clk(clk), 
        .reset(reset), 
        .fft_valid(do_en), 
        .fft_imag(do_im), 
        .fft_real(do_re), 
        .mag_sq(mag_sq), 
        .mag_valid(mag_valid)
    );

    // Loudness Calculation (Sum of Magnitude Squared Values)
    fft_loudness_calculator #(.W(W*2+1), .NSamples(NSamples)) u_fft_loudness_calculator (
        .clk(clk),
        .reset(reset),
        .fft_valid(mag_valid),
        .fft_imag(do_im),       // Use the output from FFT
        .fft_real(do_re),
        .loudness(loudness),    // Output the total loudness
        .loudness_valid(loudness_valid)
    );

    // Output the loudness value
    assign loudness_output.data = loudness;    // Output loudness to the downstream system
    assign loudness_output.valid = loudness_valid;

endmodule
