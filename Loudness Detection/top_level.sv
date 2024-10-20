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

    
	dstream #(.N(W))                audio_input ();
   dstream #(.N($clog2(NSamples))) pitch_output ();
	 
	 // Define as input for loudness data output from FFT
	// Assign the ADC clock to the output for AUD_XCK
  
	 
    mic_load #(.N(W)) u_mic_load (
    .adclrc(AUD_ADCLRCK),
	 .bclk(AUD_BCLK),
	 .adcdat(AUD_ADCDAT),
    .sample_data(audio_input.data),
	 .valid(audio_input.valid)
   );
	
	assign AUD_XCK = adc_clk;
	
    fft_loudness_detect #(.W(W), .NSamples(NSamples)) DUT (
	    .clk(adc_clk),
		 .audio_clk(AUD_BCLK),
		 .reset(resend),
		 .audio_input(audio_input),
		 .pitch_output(pitch_output)
    );

	logic [$clog2(NSamples)-1:0] display_value;
	logic [3:0] mapped_value;  // 4-bit value between 1 and 16

	// Linear Mapping from pitch_output.data to 1-16 range
	always_ff @(posedge adc_clk) begin
		if (pitch_output.valid) begin
			display_value <= pitch_output.data;
			// Mapped value calculation (from peak pitch range 0-300 to 1-16)
			if (pitch_output.data >= 300) begin
				mapped_value <= 4'd16;
			end else begin
				mapped_value <= ((pitch_output.data * 15) / 300) + 1;
			end
		end
	end
	
	// Display the mapped value on HEX displays
	display u_display (
		.clk(adc_clk),
		.value(mapped_value),  // Show mapped value (1-16) on the display
		.display0(HEX0),
		.display1(HEX1),
		.display2(HEX2),
		.display3(HEX3)
	);


endmodule
