module top_level(
    input CLOCK_50,
    inout [35:0] GPIO,
    input [3:0] KEY,
    output [17:0] LEDR  // LED outputs
);

logic reset;
logic echo, trigger;
logic [11:0] distance;
logic [4:0] debug_leds;  // LEDs for debugging states
logic [9:0] counter_debug; // Counter value for debugging

// GPIO connections
assign GPIO[35] = trigger;

// Debounce reset button only
debounce reset_edge(
    .clk(CLOCK_50),
    .button(!KEY[2]),
    .button_edge(reset)
);

// Set measure to high for continuous readings
logic measure = 1'b1;

// Force echo high for testing
assign echo = 1'b1;  // Force echo high to check if WAIT transitions

// Instantiate the sensor driver with debug LEDs
sensor_driver u0(
    .clk(CLOCK_50),
    .rst(reset),
    .measure(measure),
    .echo(echo),
    .trig(trigger),
    .distance(distance),
    .debug_leds(debug_leds),    // Connect state debug LEDs
    .counter_debug(counter_debug)  // Connect counter debug
);

// Map debug LEDs to LEDR[4:0] to observe each state
assign LEDR[4:0] = debug_leds;

// Use LEDR[5] to display the trigger signal for additional debugging
assign LEDR[5] = trigger;

// Display `counter_debug` on LEDR[15:6] for testing
assign LEDR[15:6] = counter_debug;

endmodule
