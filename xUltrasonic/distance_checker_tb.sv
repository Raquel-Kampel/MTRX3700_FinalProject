`timescale 1ns/1ps  // Set the time resolution

module distance_checker_tb;

    // Testbench signals
    reg [11:0] distance;  // Input distance (in cm)
    wire stop_flag;        // Output stop flag

    // Instantiate the distance_checker module
    distance_checker uut (
        .distance(distance),
        .stop_flag(stop_flag)
    );

    // Test procedure
    initial begin
        $display("Time(ns) | Distance | Stop Flag");
        $monitor("%0dns | %0d cm | %b", $time, distance, stop_flag);

        // Test case 1: Distance greater than 20 cm
        distance = 12'd25;
        #10;  // Wait 10 ns

        // Test case 2: Distance exactly 20 cm
        distance = 12'd20;
        #10;  // Wait 10 ns

        // Test case 3: Distance less than 20 cm
        distance = 12'd15;
        #10;  // Wait 10 ns

        // Test case 4: Edge case of 0 cm
        distance = 12'd0;
        #10;  // Wait 10 ns

        // Test case 5: Maximum distance value (for completeness)
        distance = 12'd4095;
        #10;  // Wait 10 ns

        // Finish the simulation
        $finish;
    end

endmodule
