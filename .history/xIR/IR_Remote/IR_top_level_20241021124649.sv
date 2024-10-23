`timescale 1 ps / 1 ps

module IR_top_level (
    input         resend,              // Keys for reset and control
    input         clk_50,         // 50 MHz clock input
    input         IRDA_RXD,         // IR receiver input
    output [7:0]  IR_button
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

    assign IR_button = ir_data[23:16];


endmodule

