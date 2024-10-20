module detect_control (
    input logic clk,
    input logic rst,                // Reset button (e.g., KEY[0])
    input logic [7:0] current_loudness, // Incoming loudness value (assumed 8-bit)
    output logic [2:0] state_control, // External input for state control (3 bits)
	 output logic stop_detect
);

    // Internal signals
    logic [7:0] temp_loudness;      // Temporary storage for current loudness value
    logic [7:0] max_loudness;       // Storage for maximum loudness encountered
    logic update_max;               // Signal to update max_loudness
	 
    // Parameters for state_control (based on your original states)
    typedef enum logic [2:0] {
        STOP  = 3'b000,
        LEFT  = 3'b001,
        RIGHT = 3'b010,
        FAST  = 3'b011,
        SLOW  = 3'b100
    } state_t;

    state_t current_state, next_state;

    // Main logic for storing max_loudness and comparing current_loudness
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            max_loudness <= 0;           // Reset the max_loudness to zero
            temp_loudness <= 0;          // Reset temp_loudness
            current_state <= RIGHT;      // Start in RIGHT state
				stop_detect <= 0;
        end
        else begin
            temp_loudness <= current_loudness;   // Store current loudness in temp_loudness
            
            // Compare current_loudness with max_loudness and update if necessary
            if (current_loudness > max_loudness) begin
                max_loudness <= current_loudness; // Update max_loudness
            end

            // Logic to switch between RIGHT and STOP states
            if (current_loudness < max_loudness) begin
                next_state <= STOP;  // Set state to STOP if current loudness is less than max
					 stop_detect <= 1;
            end
            else begin
                next_state <= RIGHT; // Otherwise, keep in RIGHT state
            end

            current_state <= next_state;
        end
    end


    // Assign the current state to the state_control output
    assign state_control = current_state;

endmodule
