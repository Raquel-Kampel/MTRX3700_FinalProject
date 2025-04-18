`timescale 1ps/1ps
module mic_load #(parameter N=16) (
	input bclk, // Assume a 18.432 MHz clock
    input adclrc,
	input adcdat,
    // No ready signal nor handshake: as this module streams live audio data, it cannot be stalled, therefore we only have the valid signal.
    output logic valid,
    output logic [N-1:0] sample_data
);
    // Assume that i2c has already configured the CODEC for LJ data, MSB-first and N-bit samples.

    // Rising edge detect on ADCLRC to sense left channel
    logic           redge_adclrc, adclrc_q; 
    logic [N-1:0]   temp_rx_data;
    logic [N-1:0]   temp_sample_data;
    logic [31:0]    bit_index;
    
    always_ff @(posedge  bclk) begin : adclrc_rising_edge_ff
        adclrc_q <= adclrc;
    end
    assign redge_adclrc = ~adclrc_q & adclrc; // rising edge detected!

    /*
     * Implement the Timing diagram.
     * -----------------------------
     * You should use a temporary N-bit RX register to store the ADCDAT bitstream from MSB to LSB.
     * Remember that MSB is first, LSB is last.
     * Use `temp_rx_data[(N-1)-bit_index] <= adcdat;`
     * BCLK rising is your trigger to sample the value of ADCDAT into the register at the appropriate bit index.
     * ADCLRC rising (see `redge_adclrc`) signals that the MSB should be sampled on the next rising edge of BCLK.
     * With the above, think about when and how you would reset your bit_index counter.
     */
      always_ff @(*) begin
        if (valid) begin
            sample_data <= temp_rx_data;
        end
      end

     always_ff @(posedge bclk) begin
        if (redge_adclrc) begin
            bit_index <= 1;
            temp_rx_data[N-1] <= adcdat;
        end 
        else if (bit_index > 0 && bit_index < N) begin
            bit_index <= bit_index + 1;
            temp_rx_data[(N-1)-bit_index] <= adcdat;

            if (bit_index == N-1) begin
                bit_index <= bit_index + 1;
                valid <= 1;
            end
        end
        else if (bit_index == N) begin
            bit_index <= bit_index + 1;
            valid <= 0;
        end

    
     end

endmodule

