module top_level (
    input    CLOCK_50,
    output   I2C_SCLK,
    inout    I2C_SDAT,
    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
    input  [3:0] KEY,
    input    AUD_ADCDAT,
    input    AUD_BCLK,
    output   AUD_XCK,
    input    AUD_ADCLRCK,
    output logic [17:0] LEDR
);
   localparam W        = 16;   // Bit-width for FFT input data
   localparam NSamples = 1024; // Number of FFT points

    // Internal signals
    logic adc_clk;    // Clock for ADC
    logic i2c_clk;    // Clock for I2C interface
    logic [8:0] angle_index;  // Current angle being scanned (0 to 359)
    logic [W-1:0] fft_input_data;   // FFT input data (from the microphone)
    logic fft_input_valid;          // FFT input valid signal
    logic [W*2:0] loudness;         // Calculated loudness
    logic loudness_valid;           // Valid signal for loudness
    logic [W-1:0] loudness_array [0:359]; // Array to store loudness values for each angle
    logic done;                     // Signal indicating when the scan is complete

    // PLL and clock generation
    adc_pll adc_pll_u (
        .areset(1'b0),
        .inclk0(CLOCK_50),
        .c0(adc_clk)    // Generate 18.432 MHz clock for ADC
    );

    i2c_pll i2c_pll_u (
        .areset(1'b0),
        .inclk0(CLOCK_50),
        .c0(i2c_clk)    // Generate 20 kHz clock for I2C interface
    );

    // Set up audio encoder (codec)
    set_audio_encoder set_codec_u (
        .i2c_clk(i2c_clk),
        .I2C_SCLK(I2C_SCLK),
        .I2C_SDAT(I2C_SDAT)
    );

    // Stream interface for audio input data
    dstream #(.N(W)) audio_input ();

    // Load microphone data (sample data from ADC)
    mic_load #(.N(W)) u_mic_load (
        .adclrc(AUD_ADCLRCK),
        .bclk(AUD_BCLK),
        .adcdat(AUD_ADCDAT),
        .sample_data(audio_input.data),
        .valid(audio_input.valid)
    );

    // Assign the ADC clock to the output for AUD_XCK
    assign AUD_XCK = adc_clk;

    // Instantiate FFT loudness detection module
    fft_mag_sq #(.W(W), .NSamples(NSamples)) u_fft_mag_sq (
        .clk(adc_clk),
        .reset(~KEY[0]),
        .fft_valid(audio_input.valid),
        .fft_imag(audio_input.data),  // For simplicity, using the same audio input for both real and imaginary
        .fft_real(audio_input.data),
        .loudness(loudness),
        .loudness_valid(loudness_valid)
    );

    // Store loudness by angle (for a 360-degree scan)
    store_loudness_by_angle_360 #(.W(W*2+9), .NAngles(360)) u_store_loudness_by_angle (
        .clk(adc_clk),
        .reset(~KEY[0]),
        .loudness_valid(loudness_valid),
        .loudness(loudness),
        .angle_index(angle_index),  // This would typically come from a control module
        .loudness_array(loudness_array),
        .done(done)
    );

    // Display loudness value on HEX displays (example: display loudness for the current angle)
    display u_display (
        .clk(adc_clk),
        .value(loudness),  // Displaying the current loudness value
        .display0(HEX0),
        .display1(HEX1),
        .display2(HEX2),
        .display3(HEX3)
    );

endmodule
