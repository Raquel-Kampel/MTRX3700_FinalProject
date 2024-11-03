module filter_select(
    input clk,
    input reset,  // From KEY[3]
    input select_button,
    input right_button,  // From KEY[1]
    input left_button,   // From KEY[0]
    output reg [2:0] current_filter,  // 3 bits to support 5 filters
    output reg [2:0] selected_filter   // 3 bits for the selected filter
);

    // Registers to store the previous states of the buttons
    reg button1_d, button2_d, button3_d;

    // Always block to detect button state changes and set filter
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset the latch and filter on reset
            button1_d <= 1'b0;
            button2_d <= 1'b0;
            button3_d <= 1'b0;
            current_filter <= 3'b000;  // Reset to first filter (No Filter)

        end else begin
            // Check for changes in each button and set filter
            if (select_button != button1_d) begin
                if (select_button) begin
                    selected_filter <= current_filter; 
                end
            end
            if (right_button != button2_d) begin
                if (right_button) begin
                    current_filter <= (current_filter == 3'b100) ? 3'b000 : current_filter + 1;  // Rotate forward
                end
            end
            if (left_button != button3_d) begin
                if (left_button) begin
                    current_filter <= (current_filter == 3'b000) ? 3'b100 : current_filter - 1;  // Rotate backward
					 end
            end else begin
                current_filter <= current_filter;
            end

            // Update the previous button states
            button1_d <= select_button;
            button2_d <= right_button;
            button3_d <= left_button;
        end
    end
endmodule
