`timescale 1 ps / 1 ps

module target_finder (
    input  logic clk,                // Clock input
    input  logic rst_n,              // Active-low reset

    input logic [3:0] red_in,           // red pixels
    input logic [3:0] green_in,         // green pixels
    input logic [3:0] blue_in,          // blue pixels

    output logic [7:0] red_out,         // red pixels
    output logic [7:0] green_out,       // green pixels
    output logic [7:0] blue_out,        // blue pixels    
    output logic is_orange,             // Flag for orange detection
    output logic is_turquoise           // Flag for turquoise detection
);

    // Thresholds for detecting orange
    parameter logic [3:0] THRESH_R_MIN_ORANGE = 4'd8;
    parameter logic [3:0] THRESH_R_MAX_ORANGE = 4'd15;
    parameter logic [3:0] THRESH_G_MIN_ORANGE = 4'd2;
    parameter logic [3:0] THRESH_G_MAX_ORANGE = 4'd5;
    parameter logic [3:0] THRESH_B_MAX_ORANGE = 4'd5;

    // Thresholds for detecting bright turquoise
    parameter logic [3:0] THRESH_R_MAX_TURQUOISE = 4'd6;  // Low to medium red
    parameter logic [3:0] THRESH_G_MIN_TURQUOISE = 4'd9;  // High green
    parameter logic [3:0] THRESH_G_MAX_TURQUOISE = 4'd15;
    parameter logic [3:0] THRESH_B_MIN_TURQUOISE = 4'd9;  // High blue
    parameter logic [3:0] THRESH_B_MAX_TURQUOISE = 4'd15;

    // Detect if the current pixel matches the orange threshold
    assign is_orange = (red_in >= THRESH_R_MIN_ORANGE && red_in <= THRESH_R_MAX_ORANGE &&
                        green_in >= THRESH_G_MIN_ORANGE && green_in <= THRESH_G_MAX_ORANGE &&
                        blue_in <= THRESH_B_MAX_ORANGE);

    // Detect if the current pixel matches the turquoise threshold
    assign is_turquoise = (red_in <= THRESH_R_MAX_TURQUOISE &&
                           green_in >= THRESH_G_MIN_TURQUOISE && green_in <= THRESH_G_MAX_TURQUOISE &&
                           blue_in >= THRESH_B_MIN_TURQUOISE && blue_in <= THRESH_B_MAX_TURQUOISE);

    // Output logic: Keep only detected pixels, black out the rest
    always_comb begin
        if (is_orange || is_turquoise) begin
            red_out = {red_in, red_in};   // Keep the original detected pixel
            green_out = {green_in, green_in};
            blue_out = {blue_in, blue_in};
        end else begin
            red_out = 8'b00000000;        // Force non-detected pixels to black
            green_out = 8'b00000000;
            blue_out = 8'b00000000;        
        end
    end

endmodule
