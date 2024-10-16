module programmer (
    input logic clk,                    // Clock input
    input logic reset,                  // Reset input
    input logic finish_rotate_flag,     // Flag from Movement Module (rotation complete)
    input logic finish_recording_flag,  // Flag from pitch detect (recording complete)
    input logic [7:0] amplitude_data [7:0], // Array from Module A containing the highest amplitude for each direction
    output logic [9:0] direction_to_face,  // Output direction for Movement Module (in degrees)
    output logic ready_to_turn           // Signal to Movement Module that it can start turning
);

    // Internal variables
    logic [7:0] max_amplitude;           // Variable to store the maximum amplitude
    logic [2:0] max_index;               // Index of the direction with the maximum amplitude

    // Parameters for directions (assuming 8 directions: 0, 45, 90, ..., 315 degrees)
    parameter DIRECTION_STEP = 45;       // Each step is 45 degrees

    // State machine to handle the logic
    typedef enum logic [1:0] {
        IDLE = 2'b00,          // Waiting for flags to be set
        PROCESS = 2'b01,       // Processing the amplitude data
        COMPLETE = 2'b10       // Completed and ready to send direction
    } state_t;

    state_t current_state, next_state;

    // Sequential logic for state transitions
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            max_amplitude <= 0;
            max_index <= 0;
            direction_to_face <= 0;
            ready_to_turn <= 0;
        end 
        
        else begin
            current_state <= next_state;
        end
    end

    // Combinational logic for next state and processing
    always_comb begin
        next_state = current_state;      // Default: remain in current state
        ready_to_turn = 1'b0;    // Default: not ready to turn

        case (current_state)
            IDLE: begin
                // Wait until both flags are set (rotation and recording are complete)
                if (finish_rotate_flag && finish_recording_flag) begin
                    next_state = PROCESS;  // Move to processing state
                end
            end

            PROCESS: begin
                // Initialize max_amplitude and max_index
                max_amplitude = amplitude_data[0];
                max_index = 0;

                // Loop through the amplitude_data array to find the maximum value
                for (int i = 1; i < 8; i++) begin
                    if (amplitude_data[i] > max_amplitude) begin
                        max_amplitude = amplitude_data[i];
                        max_index = i;
                    end
                end

                // Calculate the direction to face based on the index with the highest amplitude
                direction_to_face = max_index * DIRECTION_STEP;  // Each index corresponds to 45-degree steps
                next_state = COMPLETE;  // Go to complete state
            end

            COMPLETE: begin
                // Signal to Movement Module that the direction is ready
                ready_to_turn = 1'b1;   // Indicate that the movement can now start
                next_state = IDLE;      // Return to idle after processing
            end
        endcase
    end

endmodule
