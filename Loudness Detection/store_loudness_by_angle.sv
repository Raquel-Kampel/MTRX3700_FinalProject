module store_loudness_by_angle_360 #(
    parameter W = 32,        // Bit-width for loudness value (adjustable)
    parameter NAngles = 360  // 360 angles for 360-degree scan
) (
    input                  clk,             // Clock signal
    input                  reset,           // Reset signal
    input                  loudness_valid,  // Valid signal for loudness value
    input      [W-1:0]     loudness,        // Loudness value input
    input      [8:0]       angle_index,     // Angle index (0 to 359 for 0° to 359°)
    output logic [W-1:0]   loudness_array [0:NAngles-1],  // Array to store loudness for each angle
    output logic           done             // Signal when all angles are processed
);

    logic [8:0] angle_counter;  // Counter to keep track of which angle is being processed
    logic all_angles_done;      // Flag for completing all angle measurements

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // On reset, clear all stored loudness values and counters
            angle_counter <= 0;
            all_angles_done <= 1'b0;
            for (int i = 0; i < NAngles; i = i + 1) begin
                loudness_array[i] <= 0;
            end
        end else if (loudness_valid) begin
            // Store loudness value for the corresponding angle index
            loudness_array[angle_index] <= loudness;
            
            // Increment angle counter and check if all angles are done
            if (angle_counter == NAngles - 1) begin
                all_angles_done <= 1'b1;   // Indicate that all angles have been processed
            end else begin
                angle_counter <= angle_counter + 1;
            end
        end
    end

    assign done = all_angles_done;  // Done signal when all angles are processed

endmodule
