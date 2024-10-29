`timescale 1 ps / 1 ps

module ir_controller (
    input  logic clk,               // Clock input
    input  logic rst_n,             // Active-low reset
    input  logic [31:0] ir_data,    // 32-bit IR data
    input  logic data_ready,        // Data ready signal from IR_RECEIVE
    output logic [2:0] state_control, // 3-bit state output for json_to_uart_top
    output logic toggle
);

    typedef enum logic [2:0] {
        STOP   = 3'b000,
        LEFT   = 3'b001,
        RIGHT  = 3'b010,
        FAST   = 3'b011,
        MEDIUM = 3'b100,
        SLOW   = 3'b110
    } state_t;

    state_t next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_control <= STOP;  // Default state
        end else if (data_ready) begin
            case (ir_data[23:16])
                8'h0C: state_control <= STOP;   // Mute button (stop)
                8'h14: state_control <= LEFT;   // Left arrow
                8'h18: state_control <= RIGHT;  // Right arrow
                8'h1B: state_control <= FAST;   // Volume up (increase speed)
                8'h1F: state_control <= SLOW;   // Volume down (decrease speed)
                default: state_control <= STOP; // Default to STOP
            endcase
        end
    end

endmodule


