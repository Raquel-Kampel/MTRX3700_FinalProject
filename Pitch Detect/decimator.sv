module decimator (
    input logic clk,                // System clock
    input logic reset_n,            // Reset signal (active low)
    input logic [15:0] signal_in,   // 16-bit input signal (e.g., filtered audio)
    output logic [15:0] signal_out, // 16-bit decimated output signal
    output logic valid_out          // Output valid flag
);
    integer counter;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            counter <= 0;
            valid_out <= 1'b0;
        end else begin
            if (counter == 3) begin    // For decimation factor of 4
                counter <= 0;
                signal_out <= signal_in;
                valid_out <= 1'b1;
            end else begin
                counter <= counter + 1;
                valid_out <= 1'b0;
            end
        end
    end
endmodule
