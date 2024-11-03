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
    output logic is_pink,               // Flag for bright pink detection
    output logic is_purple,             // Flag for dark purple detection
    output logic is_blue,               // Flag for bright blue detection
    output logic is_green               // Flag for darker green detection
);

    // Thresholds for detecting orange
    parameter logic [3:0] THRESH_R_MIN_ORANGE = 4'd8;
    parameter logic [3:0] THRESH_R_MAX_ORANGE = 4'd15;
    parameter logic [3:0] THRESH_G_MIN_ORANGE = 4'd2;
    parameter logic [3:0] THRESH_G_MAX_ORANGE = 4'd5;
    parameter logic [3:0] THRESH_B_MAX_ORANGE = 4'd5;

    // Thresholds for detecting bright pink
    parameter logic [3:0] THRESH_R_MIN_PINK = 4'd12;
    parameter logic [3:0] THRESH_G_MAX_PINK = 4'd3;
    parameter logic [3:0] THRESH_B_MIN_PINK = 4'd10;

    // Thresholds for detecting dark purple
    parameter logic [3:0] THRESH_R_MIN_PURPLE = 4'd6;
    parameter logic [3:0] THRESH_R_MAX_PURPLE = 4'd10;
    parameter logic [3:0] THRESH_G_MAX_PURPLE = 4'd3;
    parameter logic [3:0] THRESH_B_MIN_PURPLE = 4'd6;
    parameter logic [3:0] THRESH_B_MAX_PURPLE = 4'd10;

    // Thresholds for detecting bright blue
    parameter logic [3:0] THRESH_R_MAX_BLUE = 4'd3;
    parameter logic [3:0] THRESH_G_MAX_BLUE = 4'd7;
    parameter logic [3:0] THRESH_B_MIN_BLUE = 4'd10;

    // Thresholds for detecting darker green
    parameter logic [3:0] THRESH_R_MAX_GREEN = 4'd3;
    parameter logic [3:0] THRESH_G_MIN_GREEN = 4'd7; // Lowered minimum green threshold for darker tone
    parameter logic [3:0] THRESH_G_MAX_GREEN = 4'd12; // Reduced maximum green threshold for less vibrancy
    parameter logic [3:0] THRESH_B_MAX_GREEN = 4'd3;

    // Detect if the current pixel matches the orange threshold
    assign is_orange = (red_in >= THRESH_R_MIN_ORANGE && red_in <= THRESH_R_MAX_ORANGE &&
                        green_in >= THRESH_G_MIN_ORANGE && green_in <= THRESH_G_MAX_ORANGE &&
                        blue_in <= THRESH_B_MAX_ORANGE);

    // Detect if the current pixel matches the bright pink threshold
    assign is_pink = (red_in >= THRESH_R_MIN_PINK &&
                      green_in <= THRESH_G_MAX_PINK &&
                      blue_in >= THRESH_B_MIN_PINK);

    // Detect if the current pixel matches the dark purple threshold
    assign is_purple = (red_in >= THRESH_R_MIN_PURPLE && red_in <= THRESH_R_MAX_PURPLE &&
                        green_in <= THRESH_G_MAX_PURPLE &&
                        blue_in >= THRESH_B_MIN_PURPLE && blue_in <= THRESH_B_MAX_PURPLE);

    // Detect if the current pixel matches the bright blue threshold
    assign is_blue = (red_in <= THRESH_R_MAX_BLUE &&
                      green_in <= THRESH_G_MAX_BLUE &&
                      blue_in >= THRESH_B_MIN_BLUE);

    // Detect if the current pixel matches the darker green threshold
    assign is_green = (red_in <= THRESH_R_MAX_GREEN &&
                       green_in >= THRESH_G_MIN_GREEN && green_in <= THRESH_G_MAX_GREEN &&
                       blue_in <= THRESH_B_MAX_GREEN);

    // Output logic: Keep only detected pixels, black out the rest
    always_comb begin
        if (is_green) begin
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
