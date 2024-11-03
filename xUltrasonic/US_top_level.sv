module US_top_level(
    input CLOCK_50,          // 50 MHz system clock input
    inout [35:0] GPIO,       // General Purpose I/O pins for external connections
    input [3:0] KEY,         // 4 push buttons (active low)
    output [7:0] LEDR        // 8-bit LED output to display distance
);

logic start, reset;          // Logic signals for start and reset edges
logic echo, trigger;         // Echo and trigger signals for sensor communication

// Assign GPIO[34] as the input echo signal from the sensor
assign echo = GPIO[34];      
// Assign GPIO[35] as the output trigger signal to the sensor
assign GPIO[35] = trigger;

// Instantiate debounce logic for the start button (KEY[3])
// Generates a clean pulse when the button is pressed
debounce start_edge(
    .clk(CLOCK_50), 
    .button(!KEY[3]),    // Active low button input
    .button_edge(start)  // Output pulse on button press
);

// Instantiate debounce logic for the reset button (KEY[2])
// Generates a clean pulse when the button is pressed
debounce reset_edge(
    .clk(CLOCK_50), 
    .button(!KEY[2]),    // Active low button input
    .button_edge(reset)  // Output pulse on button press
);

// Instantiate the sensor driver module
// This module handles triggering, echo reception, and distance calculation
sensor_driver u0(
    .clk(CLOCK_50),      // System clock input
    .rst(reset),         // Reset signal input
    .measure(start),     // Start measurement signal input
    .echo(echo),         // Echo signal input from the sensor
    .trig(LEDR),      // Trigger signal output to the sensor
    .distance()      // Output distance displayed on the LEDs
);

endmodule

