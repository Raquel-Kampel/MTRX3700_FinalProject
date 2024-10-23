module json_to_uart(
    input logic clk,
    input logic rst,
    input logic start,                     // Start signal to initiate conversion and transmission
    input [7:0] json_str [0:31],           // JSON string as an array of 8-bit characters (maximum length 32)
    input [7:0] json_len,                  // Length of the JSON string
    output logic uart_out,                 // UART transmission line output
    output logic done                      // Signals when the entire string has been transmitted
);

    // Internal state variables
    logic [7:0] byte_index;                // Index to track which byte in the JSON string is being transmitted
    logic transmitting;
    logic [7:0] data_out;                  // 8-bit data to send to UART
    logic data_valid;                      // Signal when data_out is valid
    logic uart_ready;                      // Ready signal from UART transmitter

    // FSM for sending JSON string byte by byte
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            byte_index <= 0;
            transmitting <= 0;
            data_valid <= 0;
            done <= 0;
        end else if (start && !transmitting) begin
            transmitting <= 1;               // Start transmission
            byte_index <= 0;
            data_valid <= 0;
            done <= 0;
        end else if (transmitting) begin
            if (uart_ready && !data_valid) begin
                // Send the next byte when UART is ready and data_valid is low
                data_out <= json_str[byte_index];
                data_valid <= 1;
                byte_index <= byte_index + 1;

                // Debugging information
                $display("Time: %0t | Byte Index: %0d | JSON Length: %0d | Data Valid: %0b", 
                          $time, byte_index, json_len, data_valid);
            end else if (data_valid && uart_ready) begin
                // Wait for UART to consume data before moving on
                data_valid <= 0;
            end

            // Check if we are done transmitting the whole JSON string
            if (byte_index == json_len && !data_valid) begin
                transmitting <= 0;
                done <= 1;  // Signal transmission completion
                $display("Transmission Complete at Time: %0t", $time);
            end
        end
    end

    // Instantiate the UART transmitter module
    uart_tx #(
        .CLKS_PER_BIT(434),  // Baud rate = 115200 (with 50 MHz clock)
        .BITS_N(8),
        .PARITY_TYPE(0)      // No parity bit
    ) uart_inst (
        .clk(clk),
        .rst(rst),
        .data_tx(data_out),      // Data to transmit
        .uart_out(uart_out),     // UART output pin
        .valid(data_valid),      // Data valid signal to UART
        .ready(uart_ready)       // UART ready to accept new data
    );

endmodule



