module classification(
    input logic clk,
    input logic [3:0] red,
    input logic [3:0] green,
    input logic [3:0] blue,
    input wire HREF,
    input wire fast,
    input logic is_orange,
    output logic orangeDetected,
    output logic [2:0] direction
);

integer orange_count_left = 0;
integer orange_count_center = 0;
integer orange_count_right = 0;
integer pixel_count = 0;
integer row_count = 0; // New variable to track the row number
integer total_orange_pixels = 0; // New variable to count total orange pixels

always_ff @(posedge clk) begin

    if (HREF) begin

        pixel_count <= pixel_count + 1;

        // Orange detection
        if (is_orange) begin

            //
            total_orange_pixels <= total_orange_pixels + 1; // Increment the total orange pixel count

            //
            if (pixel_count < 100) begin

                orange_count_left = orange_count_left + 1;

            end
            else if (pixel_count >= 100 && pixel_count < 295) begin

                orange_count_center = orange_count_center + 1;

            end
            else if (pixel_count >= 295 && pixel_count <= 320) begin

                orange_count_right = orange_count_right +1;

            end

            //
            if (orange_count_right > orange_count_left) begin

                direction <= 3'b010;

            end
            else if (orange_count_center > orange_count_right && orange_count_center > orange_count_left) begin

                direction <= 3'b011;

            end
            else if (orange_count_left > orange_count_right) begin

                direction <= 3'b001;

            end

            //
            if (pixel_count >= 320) begin

                orange_count_center <= 0;
                orange_count_right <= 0;
                orange_count_left <= 0;

                pixel_count <= 0; // Reset pixel_count for the next row
                row_count <= row_count + 1; // Move to the next row

                // If we've completed all 240 rows, reset everything for the next frame
                if (row_count >= 240) begin
                    row_count <= 0;
                    total_orange_pixels <= 0; // Reset the total orange pixel count for the new frame
                end
            end

        end
        else begin

            //
            orangeDetected <= 1'b0;

        end
    end
    else begin

        pixel_count <= 0;
        orange_count_center <= 0;
        orange_count_right <= 0;
        orange_count_left <= 0;

    end

end

endmodule
