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
integer row_count = 0; // Variable to track the row number
integer total_orange_pixels = 0; // Variable to count total orange pixels

// Total number of pixels in a frame
parameter TOTAL_PIXELS = 320 * 240;
parameter THRESHOLD = TOTAL_PIXELS / 50; // % of total pixels

always_ff @(posedge clk) begin

    if (HREF) begin

        pixel_count <= pixel_count + 1;

        // Orange detection
        if (is_orange) begin

			//orangeDetected = 1'b1;
            total_orange_pixels <= total_orange_pixels + 1; // Increment the total orange pixel count

            if (pixel_count < 70) begin
                orange_count_left <= orange_count_left + 1;
            end
            else if (pixel_count >= 70 && pixel_count < 290) begin
                orange_count_center <= orange_count_center + 1;
            end
            else if (pixel_count >= 290 && pixel_count < 320) begin
                orange_count_right <= orange_count_right + 1;
            end

        end

        // End of row processing
        if (pixel_count >= 319) begin
            row_count <= row_count + 1; // Move to the next row

            // If we've completed all 240 rows, check if total orange pixels exceed the threshold
            if (row_count >= 239) begin
                row_count <= 0;
                orange_count <= total_orange_pixels[17:0]; // Output the total count

                if (total_orange_pixels > THRESHOLD) begin
                    orangeDetected <= 1'b1; // More than 25% of the frame is orange

                    // Determine direction based on orange pixel counts
                    if (orange_count_right > orange_count_left) begin
                        direction <= 3'b010; // Right
                    end
                    else if (orange_count_center > orange_count_right && orange_count_center > orange_count_left) begin
                        direction <= 3'b011; // Center
                    end
                    else if (orange_count_left > orange_count_right) begin
                        direction <= 3'b001; // Left
                    end

                end
                else begin
                    orangeDetected <= 1'b0; // Less than 25% of the frame is orange
                    //direction <= 3'b000;
                end

                total_orange_pixels <= 0; // Reset the total orange pixel count for the new frame
                orange_count_left <= 0;
                orange_count_center <= 0;
                orange_count_right <= 0;

            end
        end

    end
    else begin
        // Reset counts when HREF is not active
        pixel_count <= 0;

    end

end

endmodule
