`timescale 1 ps / 1 ps

module target_finder (
    input  logic clk,                // Clock input
    input  logic rst_n,              // Active-low reset
    input  logic [16:0] addr,        // Address for BRAM (320x240 image)
    output logic [11:0] pixel_out    // Output pixel (orange pixels only)
);

    // Internal signals
    logic [11:0] pixel_in;           // Pixel data from BRAM
    logic [3:0] red_in, green_in, blue_in;

    // BRAM Instance to fetch pixel data
    BRAM_IP bram_inst (
        .clock(clk),
        .rdaddress(addr),
        .wraddress(17'd0),
        .wren(1'b0),
        .data(12'b0),
        .q(pixel_in)
    );

    // Split 12-bit pixel into RGB components
    assign red_in   = pixel_in[11:8];
    assign green_in = pixel_in[7:4];
    assign blue_in  = pixel_in[3:0];

    // Thresholds for detecting orange
    parameter logic [3:0] THRESH_R_MIN = 4'd8;
    parameter logic [3:0] THRESH_R_MAX = 4'd15;
    parameter logic [3:0] THRESH_G_MIN = 4'd2;
    parameter logic [3:0] THRESH_G_MAX = 4'd5;
    parameter logic [3:0] THRESH_B_MAX = 4'd5;

    // Detect if the current pixel matches the orange threshold
    logic is_orange;
    assign is_orange = (red_in >= THRESH_R_MIN && red_in <= THRESH_R_MAX &&
                        green_in >= THRESH_G_MIN && green_in <= THRESH_G_MAX &&
                        blue_in <= THRESH_B_MAX);

    // Output logic: Keep only orange pixels, black out the rest
    always_comb begin
        if (is_orange) begin
            pixel_out = pixel_in;  // Keep the original orange pixel
        end else begin
            pixel_out = 12'h000;   // Black out non-orange pixels
        end
    end

endmodule

















