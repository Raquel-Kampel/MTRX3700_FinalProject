module fft_loudness_input_buffer #(
    parameter W = 16,
    parameter NSamples = 1024
) (
    input                clk,
    input                reset,
    input                audio_clk,
    dstream.in           audio_input,
    output logic [W-1:0] fft_input,
    output logic         fft_input_valid
);

    // Signals
    logic fft_read;                            // Signal to trigger FIFO read
    logic full, wr_full;                       // Flags for FIFO full and write full status
    logic [$clog2(NSamples):0] n = NSamples;   // Counter for reading 1024 samples

    // Instantiate async FIFO to buffer audio input data for FFT processing
    async_fifo u_fifo (
        .aclr(reset),
        .data(audio_input.data), .wrclk(audio_clk), .wrreq(audio_input.valid), .wrfull(wr_full),
        .q(fft_input),           .rdclk(clk),        .rdreq(fft_read),          .rdfull(full)
    );

    // Ready signal for audio input when FIFO is not full
    assign audio_input.ready = !wr_full;

    // Valid signal for FFT input when reading from FIFO
    assign fft_input_valid = fft_read;

    // FSM to control reading from FIFO once it's full, for 1024 samples
    always_ff @(posedge clk or posedge reset) begin : fifo_flush
        if (reset) begin
            // Reset the counter and stop reading
            n <= 1024;
            fft_read <= 1'b0;
        end
        else if (full) begin
            // Start reading when the FIFO is full
            fft_read <= 1'b1;
            n <= 1'b1;
        end
        else if (fft_read) begin
            // Continue reading until all 1024 samples have been read
            if (n == NSamples - 1) begin
                fft_read <= 1'b0;  // Stop reading after 1024 samples
            end
            else begin
                n <= n + 1'b1;  // Increment the counter
            end
        end
    end

endmodule
