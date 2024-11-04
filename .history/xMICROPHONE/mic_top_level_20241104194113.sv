module mic_top_level (
    // Pins
    input        CLOCK_50,
    input        resend,
    output 	     I2C_SCLK,
    inout        I2C_SDAT,
    input  	     AUD_ADCDAT,
    input        AUD_BCLK,
    output       AUD_XCK,
    input        AUD_ADCLRCK,
    output [3:0] mapped_value,
    output [1:0] speed
);
	// Set Params
	localparam W        = 16;   
	localparam NSamples = 1024;

    // Generate Clocks
	logic adc_clk; 
	adc_pll adc_pll_u (.areset(1'b0),.inclk0(CLOCK_50),.c0(adc_clk)); // generate 18.432 MHz clock
	logic i2c_clk; 
	i2c_pll i2c_pll_u (.areset(1'b0),.inclk0(CLOCK_50),.c0(i2c_clk)); // generate 20 kHz clock
	assign AUD_XCK = adc_clk;

	// Encode
	set_audio_encoder set_codec_u (.i2c_clk(i2c_clk), .I2C_SCLK(I2C_SCLK), .I2C_SDAT(I2C_SDAT));

    // Declare structs
	dstream #(.N(W))                audio_input ();
    dstream #(.N($clog2(NSamples))) pitch_output ();
	
    // Processing and ADC conversion
	mic_load #(.N(W)) u_mic_load (
        .adclrc(AUD_ADCLRCK),
        .bclk(AUD_BCLK),
        .adcdat(AUD_ADCDAT),
        .sample_data(audio_input.data),
        .valid(audio_input.valid));

    // Calculate numeric pitch value (0-1024) for each audio timestep	
    fft_pitch_detect #(.W(W), .NSamples(NSamples)) DUT (
        .clk(adc_clk),
        .audio_clk(AUD_BCLK),
        .reset(resend),
        .audio_input(audio_input),
        .pitch_output(pitch_output));

	logic [$clog2(NSamples)-1:0] display_value;

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

        // Set speed according to pitch range. 3 speed drive.
        if (mapped_value < 4 ) begin
            speed <= 2'b00;
        end else if (mapped_value >= 4 && mapped_value < 8) begin
            speed <= 2'b01;
        end else if (mapped_value >= 8 && mapped_value < 12) begin
            speed <= 2'b10;
        end else begin
            speed <= 2'b11;
        end 
    
	end


	
endmodule
