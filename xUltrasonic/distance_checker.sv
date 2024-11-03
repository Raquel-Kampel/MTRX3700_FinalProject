module distance_checker(
    input [11:0] distance,  // Input distance from sensor_driver (in cm)
    output logic stop_flag  // Output stop flag if distance <= 20 cm
);

    // Define the 20 cm threshold as a constant
    localparam THRESHOLD = 12'd20;

    // Combinational logic to set the stop flag
    always_comb begin
        if (distance <= THRESHOLD)
            stop_flag = 1'b1;  // Set stop flag if distance <= 20 cm
        else
            stop_flag = 1'b0;  // Clear stop flag if distance > 20 cm
    end

endmodule
