`timescale 1 ps / 1 ps

module ir_controller (
    input  logic clk,                // Clock input
    input  logic rst_n,              // Active-low reset
    input  logic [31:0] ir_data,     // 32-bit IR code from IR_RECEIVE
    input  logic data_ready,         // Data ready signal from IR_RECEIVE

    output logic drive,              // Drive command flag
    output logic stop,               // Stop command flag
    output logic increase_speed,     // Increase speed flag
    output logic decrease_speed,     // Decrease speed flag
    output logic turn_left,          // Turn left flag
    output logic turn_right          // Turn right flag
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all flags
            drive <= 1'b0;
            stop <= 1'b0;
            increase_speed <= 1'b0;
            decrease_speed <= 1'b0;
            turn_left <= 1'b0;
            turn_right <= 1'b0;
        end 
        else if (data_ready) begin
            // Reset flags before setting new ones
            drive <= 1'b0;
            stop <= 1'b0;
            increase_speed <= 1'b0;
            decrease_speed <= 1'b0;
            turn_left <= 1'b0;
            turn_right <= 1'b0;

            // Set the corresponding flag based on the IR key code
            case (ir_data[7:0])  // Correctly check the least significant byte for key code
                8'h12: drive <= 1'b1;         // Power button
                8'h0C: stop <= 1'b1;          // Mute button
                8'h1B: increase_speed <= 1'b1; // Volume up button
                8'h1F: decrease_speed <= 1'b1; // Volume down button
                8'h14: turn_left <= 1'b1;     // Left arrow
                8'h18: turn_right <= 1'b1;    // Right arrow
                default: ; // No action for other codes
            endcase
        end
    end
endmodule

