`timescale 1 ps / 1 ps

module IR_top_level (
    input         resend,              // Keys for reset and control
    input         clk_50,         // 50 MHz clock input
    input         IRDA_RXD,         // IR receiver input
    output        GPIO_5,            // UART TX output
    output [2:0]  state_control
);
    // Internal signals
    logic data_ready;
    logic [31:0] ir_data;           // Decoded IR data

    // Instantiate IR_RECEIVE module to decode IR signals
    IR_RECEIVE ir_receiver (
        .iCLK(clk_50),         // 50 MHz clock input
        .iRST_n(resend),          // Reset signal (active-low)
        .iIRDA(IRDA_RXD),        // IR input signal
        .oDATA_READY(data_ready),// Data ready signal
        .oDATA(ir_data)          // Decoded 32-bit IR data
    );



    // // Instantiate ir_controller module to interpret IR commands
    // ir_controller ir_ctrl (
    //     .clk(CLOCK_50),           // Clock input
    //     .rst_n(1),            // Reset signal (active-low)
    //     .ir_data(ir_data),        // 32-bit IR data from IR_RECEIVE
    //     .data_ready(data_ready),  // Data ready signal
    //     .state_control(state_control), // 3-bit state control signal
    //     .toggle(toggle)
    // );


    // // Instantiate json_to_uart_top module to send commands via UART
    // json_to_uart_top uart_module (
    //     .clk(CLOCK_50),           // 50 MHz clock input
    //     .rst(~rst_n),             // Reset signal
    //     .state_control(state_control), // State control signal
    //     .GPIO_5(GPIO_5),          // UART TX output on GPIO pin
    //     .LEDR(led_data),          // LED data output
    //     .done(done)               // Transmission complete signal
    // );

    // Assign LED output to LEDR
    //assign LEDR = led_data;

    // Display the received IR code on the 7-segment displays
    // SEG_HEX hex0 (.iDIG(ir_data[31:28]), .oHEX_D(HEX0));
    // SEG_HEX hex1 (.iDIG(ir_data[27:24]), .oHEX_D(HEX1));
    // SEG_HEX hex2 (.iDIG(ir_data[23:20]), .oHEX_D(HEX2));
    // SEG_HEX hex3 (.iDIG(ir_data[19:16]), .oHEX_D(HEX3));
    // SEG_HEX hex4 (.iDIG(ir_data[15:12]), .oHEX_D(HEX4));
    // SEG_HEX hex5 (.iDIG(ir_data[11:8]),  .oHEX_D(HEX5));
    // SEG_HEX hex6 (.iDIG(ir_data[7:4]),   .oHEX_D(HEX6));
    // SEG_HEX hex7 (.iDIG(ir_data[3:0]),   .oHEX_D(HEX7));

endmodule

