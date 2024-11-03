module sensor_driver_tb();

parameter CLK_PERIOD = 20;

logic clk;
logic echo;
logic trigger;
logic start;
logic reset;
logic [7:0] LEDR;

sensor_driver u0 (
    .clk(clk),
    .echo(echo),
    .measure(start),
    .rst(reset),
    .trig(trigger),
    .distance(LEDR)
);

// Clock generation (20ns period, same as original)
initial clk = 1'b0;
always begin
    #10 clk = ~clk;  // 50% duty cycle (20ns period)
end

// Test sequence
initial begin
    // Initialize inputs
    #(1 * CLK_PERIOD);
    reset = 1;
    start = 0;
    LEDR = 0;

    // Apply reset
    #(1 * CLK_PERIOD);
    reset = 0;
    start = 1;

    #(1 * CLK_PERIOD);
    start = 0;

    // Simulate echo pulse
    #(500 * CLK_PERIOD);
    echo = 1;
    #(1000000 * CLK_PERIOD);  // Echo stays high for a while

    echo = 0;

    // Allow some time for the final state transition
    #(10 * CLK_PERIOD);

    // Print the final measured distance
    $display("Time: %0t | Final Measured Distance: %d cm", $time, LEDR);

    // Finish simulation
    $finish();
end

endmodule










