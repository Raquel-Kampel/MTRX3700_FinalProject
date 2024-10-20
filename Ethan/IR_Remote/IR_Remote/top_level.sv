`timescale 1 ps / 1 ps

module top_level (
    input  [17:0] SW,               // Switches for input control
    input  [3:0]  KEY,              // Keys for reset and control
    input         CLOCK_50,         // 50 MHz clock input
    input         IRDA_RXD,         // IR receiver input
    output [17:0] LEDR,             // Red LEDs for status and data
    output [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7, // HEX display
    output        GPIO_5            // UART TX output
);

    // Internal signals
    logic rst_n, done, data_ready;
    logic [31:0] ir_data;           // Decoded IR data
    logic [2:0] state_control;      // State control from ir_controller
    logic [17:0] led_data;          // LED status data

    // Assign reset signal (active-low)
    assign rst_n = ~KEY[0];  // KEY[0] used for reset

    // Instantiate IR_RECEIVE module to decode IR signals
    IR_RECEIVE ir_receiver (
        .iCLK(CLOCK_50),         // 50 MHz clock input
        .iRST_n(rst_n),          // Reset signal (active-low)
        .iIRDA(IRDA_RXD),        // IR input signal
        .oDATA_READY(data_ready),// Data ready signal
        .oDATA(ir_data)          // Decoded 32-bit IR data
    );

    // Instantiate ir_controller module to interpret IR commands
    ir_controller ir_ctrl (
        .clk(CLOCK_50),           // Clock input
        .rst_n(rst_n),            // Reset signal (active-low)
        .ir_data(ir_data),        // 32-bit IR data from IR_RECEIVE
        .data_ready(data_ready),  // Data ready signal
        .state_control(state_control) // 3-bit state control signal
    );

    // Instantiate json_to_uart_top module to send commands via UART
    json_to_uart_top uart_module (
        .clk(CLOCK_50),           // 50 MHz clock input
        .rst(~rst_n),             // Reset signal
        .state_control(state_control), // State control signal
        .GPIO_5(GPIO_5),          // UART TX output on GPIO pin
        .LEDR(led_data),          // LED data output
        .done(done)               // Transmission complete signal
    );

    // Assign LED output to LEDR
    assign LEDR = led_data;

    // Display the received IR code on the 7-segment displays
    SEG_HEX hex0 (.iDIG(ir_data[31:28]), .oHEX_D(HEX0));
    SEG_HEX hex1 (.iDIG(ir_data[27:24]), .oHEX_D(HEX1));
    SEG_HEX hex2 (.iDIG(ir_data[23:20]), .oHEX_D(HEX2));
    SEG_HEX hex3 (.iDIG(ir_data[19:16]), .oHEX_D(HEX3));
    SEG_HEX hex4 (.iDIG(ir_data[15:12]), .oHEX_D(HEX4));
    SEG_HEX hex5 (.iDIG(ir_data[11:8]),  .oHEX_D(HEX5));
    SEG_HEX hex6 (.iDIG(ir_data[7:4]),   .oHEX_D(HEX6));
    SEG_HEX hex7 (.iDIG(ir_data[3:0]),   .oHEX_D(HEX7));

endmodule

