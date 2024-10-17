module top_level (
    input  [17:0] SW,              // Switches for input control
    input  [3:0]  KEY,             // Keys for reset and control
    input         CLOCK_50,        // 50 MHz clock input
    output [17:0] LEDR             // Red LEDs for status and data
);

    // Internal signals
    logic rst, start;
    logic GPIO_5, done;
    logic [17:0] led_data;

    // Assign SW[0] to start signal and KEY[0] to reset signal
    assign start = SW[0];  
    assign rst = ~KEY[0];  // Active-low reset

    // Instantiate the `json_to_uart_top` module
    json_to_uart_top uart_module (
        .clk(CLOCK_50),   // 50 MHz clock input
        .rst(rst),        // Reset signal from KEY[0]
        .start(start),    // Start signal from SW[0]
        .GPIO_5(GPIO_5),  // UART TX output to GPIO_5
        .LEDR(led_data),  // LED data to LEDR
        .done(done)       // Transmission complete signal
    );

    // Connect LED outputs
    assign LEDR = led_data;

endmodule


