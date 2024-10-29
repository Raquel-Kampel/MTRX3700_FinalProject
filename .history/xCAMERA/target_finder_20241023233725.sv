`timescale 1 ps / 1 ps

module target_finder (
    input  logic clk,                // Clock input
    input  logic rst_n,              // Active-low reset

    input logic [3:0] red_in,           // red pixels
    input logic [3:0] green_in,         // green pixels
    input logic [3:0] blue_in,          // blue pixels

    output logic [7:0] red_out,           // red pixels
    output logic [7:0] green_out,         // green pixels
    output logic [7:0] blue_out,          // blue pixels    
    output logic is_orange
);

    // Thresholds for detecting orange
    parameter logic [3:0] THRESH_R_MIN = 4'd8;
    parameter logic [3:0] THRESH_R_MAX = 4'd15;
    parameter logic [3:0] THRESH_G_MIN = 4'd2;
    parameter logic [3:0] THRESH_G_MAX = 4'd5;
    parameter logic [3:0] THRESH_B_MAX = 4'd5;

    // Detect if the current pixel matches the orange threshold
    assign is_orange = (red_in >= THRESH_R_MIN && red_in <= THRESH_R_MAX &&
                        green_in >= THRESH_G_MIN && green_in <= THRESH_G_MAX &&
                        blue_in <= THRESH_B_MAX);

    // Output logic: Keep only orange pixels, black out the rest
    always_comb begin
        if (1) begin
            red_out = {red_in, red_in};  // Keep the original orange pixel
            green_out = {green_in, green_in};
            blue_out = {blue_in, blue_in};

        end else begin
            red_out = 8'b00000000;  // Force pixels black
            green_out = 8'b00000000;
            blue_out = 8'b00000000;        
        end
    end

endmodule
















