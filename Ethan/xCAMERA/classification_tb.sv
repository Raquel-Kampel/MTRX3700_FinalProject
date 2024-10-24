`timescale 1ns/1ps

module classification_tb;

    // Inputs
    logic clk;
    logic [3:0] red;
    logic [3:0] green;
    logic [3:0] blue;
    logic HREF;
    logic fast;
    logic is_orange;

    // Outputs
    logic orangeDetected;
    logic [2:0] direction;
    logic [17:0] orange_count;

    // Instantiate the classification module
    classification uut (
        .clk(clk),
        .red(red),
        .green(green),
        .blue(blue),
        .HREF(HREF),
        .fast(fast),
        .is_orange(is_orange),
        .orangeDetected(orangeDetected),
        .direction(direction),
        .orange_count(orange_count)
    );

    // Clock generation: 50 MHz clock (20 ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        // Initialize signals
        clk = 0;
        red = 4'b0;
        green = 4'b0;
        blue = 4'b0;
        HREF = 0;
        fast = 0;
        is_orange = 0;

        // Initialize outputs to avoid 'x' states
        orangeDetected = 1'b0;
        direction = 3'b000;
        orange_count = 18'b0;

        // Display header
        $display("Running Tests...");
    end

    // Task to simulate a frame with pixel data
    task automatic send_frame(input integer orange_pixels);
        // Declare local variables as automatic to avoid static scoping issues
        automatic integer row, col;
        automatic integer total_pixels = 320 * 240;
        automatic integer pixels_sent = 0;

        HREF = 1;
        for (row = 0; row < 240; row = row + 1) begin
            for (col = 0; col < 320; col = col + 1) begin
                is_orange = (pixels_sent < orange_pixels);
                pixels_sent = pixels_sent + 1;
                @(posedge clk);
            end
        end
        HREF = 0;
        @(posedge clk);
    endtask

    // Testbench procedure
    initial begin
        // Initialize signals
        red = 4'b0;
        green = 4'b0;
        blue = 4'b0;
        HREF = 0;
        fast = 0;
        is_orange = 0;

        // Test 1: Less than 25% orange pixels
        send_frame(320 * 240 / 5); // 20% orange pixels
        $display("Test 1 - Orange Detected: %b, Direction: %0d, Orange Count: %0d", 
                 orangeDetected, direction, orange_count);

        // Test 2: Exactly 25% orange pixels
        send_frame(320 * 240 / 4); // 25% orange pixels
        $display("Test 2 - Orange Detected: %b, Direction: %0d, Orange Count: %0d", 
                 orangeDetected, direction, orange_count);

        // Test 3: More than 25% orange pixels
        send_frame(320 * 240 / 3); // 33% orange pixels
        $display("Test 3 - Orange Detected: %b, Direction: %0d, Orange Count: %0d", 
                 orangeDetected, direction, orange_count);

        // End of simulation
        $stop;
    end
endmodule

