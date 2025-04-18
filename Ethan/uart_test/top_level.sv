module top_level (
    input  [17:0] SW,               // Switches for input control
    input  [3:0]  KEY,              // Keys for reset and control
    input         CLOCK_50,         // 50 MHz clock input
    output [17:0] LEDR,             // Red LEDs for status and data
    output [35:0] GPIO              // Single GPIO pin for UART TX
);

    // Internal signals
    logic rst, start;
    logic start_latched, done;
    logic [17:0] led_data;
    logic sw_prev;
    
    // Detect control signals
    logic [7:0] current_loudness;   // Loudness signal input (for example, from SW or another source)
    logic [2:0] state_control;      // Control signal output from detect_control
    logic stop_detect;              // Stop detection signal from detect_control

    // Assign KEY[0] to reset signal
    assign rst = ~KEY[0];  // Active-low reset

    // Edge detection for SW[0] (rising edge detection)
    always_ff @(posedge CLOCK_50 or posedge rst) begin
        if (rst) begin
            sw_prev <= 1'b0;
            start_latched <= 1'b0;
        end else begin
            sw_prev <= SW[0];  // Store the previous value of SW[0]

            // Detect rising edge: when SW[0] goes from 0 to 1
            if (SW[0] && !sw_prev) begin
                start_latched <= 1'b1;
            end
            
            // Clear the latched start signal when transmission is done
            if (done) begin
                start_latched <= 1'b0;
            end
        end
    end

    // Instantiate the `json_to_uart_top` module
    json_to_uart_top uart_module (
        .clk(CLOCK_50),        // 50 MHz clock input
        .rst(rst),             // Reset signal from KEY[0]
        .GPIO_5(GPIO[5]),      // UART TX output to GPIO[5]
        .LEDR(led_data),       // LED data to LEDR
        .done(done)            // Transmission complete signal
    );

    // Connect LED outputs
    assign LEDR = led_data;

    // Loudness signal for testing (assign from switches or another input)
    assign current_loudness = SW[7:0];  // Example: map switches SW[7:0] to current loudness

    // Instantiate the `detect_control` module
    detect_control detect_ctrl (
        .clk(CLOCK_50),             // Clock input
        .rst(rst),                  // Reset input
        .current_loudness(current_loudness), // Incoming loudness value
        .state_control(state_control), // Control signal output (3-bit state)
        .stop_detect(stop_detect)    // Stop detection signal
    );

endmodule
