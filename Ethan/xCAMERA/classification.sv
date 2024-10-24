module classification(
    input logic clk,
    input logic [3:0] red,
    input logic [3:0] green,
    input logic [3:0] blue,
    input wire HREF,
    input wire fast,
    input logic is_orange,
    output logic orangeDetected,
    output logic [2:0] direction,
    output logic [17:0] orange_count
);

integer orange_count_left = 0;
integer orange_count_center = 0;
integer orange_count_right = 0;
integer pixel_count = 0;
integer row_count = 0; // Tracks the row number
integer total_orange_pixels = 0; // Total orange pixel count for the frame

// Total number of pixels in a frame
parameter TOTAL_PIXELS = 320 * 240;
parameter THRESHOLD = TOTAL_PIXELS / 4; // 25% threshold

always_ff @(posedge clk) begin
    if (HREF) begin
        // Increment pixel count within the row
        pixel_count <= pixel_count + 1;

        // Detect if the current pixel is orange
        if (is_orange) begin
            total_orange_pixels <= total_orange_pixels + 1; // Total frame orange pixels

            // Accumulate orange pixel counts for left, center, and right regions
            if (pixel_count < 100) begin
                orange_count_left <= orange_count_left + 1;
            end
            else if (pixel_count < 295) begin
                orange_count_center <= orange_count_center + 1;
            end
            else begin
                orange_count_right <= orange_count_right + 1;
            end
        end

        // End of row processing
        if (pixel_count >= 320) begin
            pixel_count <= 0; // Reset pixel count for the next row
            row_count <= row_count + 1; // Move to the next row
        end

        // End of frame processing (after 240 rows)
        if (row_count >= 240) begin
            row_count <= 0; // Reset row count for the next frame
            orange_count <= total_orange_pixels[17:0]; // Output total orange pixel count

            // Set orangeDetected flag based on total orange pixels
            if (total_orange_pixels > THRESHOLD) begin
                orangeDetected <= 1'b1; // More than 25% of frame is orange
            end
            else begin
                orangeDetected <= 1'b0; // Less than 25% of frame is orange
            end

            // Compute direction based on orange pixel counts
            if (orange_count_right > orange_count_left) begin
                direction <= 3'b010; // Right
            end
            else if (orange_count_center > orange_count_right && 
                     orange_count_center > orange_count_left) begin
                direction <= 3'b011; // Center
            end
            else begin
                direction <= 3'b001; // Left
            end

            // Reset all counts for the next frame
            total_orange_pixels <= 0;
            orange_count_left <= 0;
            orange_count_center <= 0;
            orange_count_right <= 0;
        end

    end else begin
        // Reset pixel count when HREF is inactive (no active pixel data)
        pixel_count <= 0;
    end
end

endmodule

