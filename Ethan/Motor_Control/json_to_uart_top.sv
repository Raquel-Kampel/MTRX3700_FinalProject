module json_to_uart_top(
    input  logic clk,
    input  logic rst,
    input  logic start,                     // Start signal to initiate transmission
    input  [7:0] json_str [0:31],           // JSON string (array of 8-bit chars, max length 32)
    input  [7:0] json_len,                  // Length of the JSON string
    output logic GPIO_5,                    // Transmit UART data on GPIO[5] (robot's RX)
    output logic done                       // Transmission complete signal
);

    // Internal signals for UART interface
    logic uart_out;                         // UART TX line output
    logic uart_ready;                       // UART ready to send new data
    logic [7:0] data_out;                   // Data to send to UART
    logic data_valid;                       // Valid data signal for UART

    // Instantiate the UART transmitter submodule
    uart_tx #(
        .CLKS_PER_BIT(434),  // Baud rate = 115200 (for 50 MHz clock)
        .BITS_N(8),
        .PARITY_TYPE(0)      // No parity bit
    ) uart_tx_inst (
        .clk(clk),
        .rst(rst),
        .data_tx(data_out),      // Data from JSON string
        .uart_out(uart_out),     // TX line output from UART
        .valid(data_valid),      // Data valid signal
        .ready(uart_ready)       // UART ready signal
    );

    // Assign the UART TX output to GPIO[5] (robot's RX)
    assign GPIO_5 = uart_out;

    // FSM for managing the transmission of the JSON string
    logic [7:0] byte_index;  // Index to track JSON bytes
    logic transmitting;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            byte_index <= 0;
            transmitting <= 0;
            data_valid <= 0;
            done <= 0;
        end else if (start && !transmitting) begin
            transmitting <= 1;
            byte_index <= 0;
            data_valid <= 0;
            done <= 0;
        end else if (transmitting) begin
            if (uart_ready && !data_valid) begin
                // Send the next byte when UART is ready
                data_out <= json_str[byte_index];
                data_valid <= 1;
                byte_index <= byte_index + 1;

                // Debugging output
                $display("Time: %0t | Byte Index: %0d | JSON Length: %0d | Data Valid: %0b", 
                         $time, byte_index, json_len, data_valid);
            end else if (data_valid && uart_ready) begin
                // Wait for UART to consume data before continuing
                data_valid <= 0;
            end

            // Check if all bytes have been transmitted
            if (byte_index == json_len && !data_valid) begin
                transmitting <= 0;
                done <= 1;  // Signal transmission completion
                $display("Transmission Complete at Time: %0t", $time);
            end
        end
    end
endmodule

