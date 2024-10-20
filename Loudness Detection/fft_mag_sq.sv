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
    logic fft_read;
    logic full, wr_full;
    logic [$clog2(NSamples):0] n = NSamples;

    async_fifo u_fifo (.aclr(reset),
                        .data(audio_input.data),.wrclk(audio_clk),.wrreq(audio_input.valid),.wrfull(wr_full),
                        .q(fft_input),          .rdclk(clk),      .rdreq(fft_read),         .rdfull(full)    );
    assign audio_input.ready = !wr_full;

    assign fft_input_valid = fft_read; // The Async FIFO is set such that valid data is read out whenever the rdreq flag is high.
    
    //TODO implement a counter n to set fft_read to 1 when the FIFO becomes full (use full, not wr_full).
    // Then, keep fft_read set to 1 until 1024 (NSamples) samples in total have been read out from the FIFO.
    //assign fft_read = (full) ? 1'b1 : 1'b0; 
    always_ff @(posedge clk) begin : fifo_flush
        if (reset) begin
            n <= 1024;
        end
        else if (full) begin
            fft_read <= 1'b1;
            n <= 1'b1;
        end
        else if (fft_read) begin
            if (n == NSamples-1) begin
                fft_read <= 1'b0;
            end
            else begin
                n <= n+1'b1;
            end
        end
    end

endmodule
