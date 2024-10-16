module movement_control (
    input logic clk,                // Clock input
    input logic reset,              // Reset input
    input logic find_person_cmd,    // Command to start finding person
    input logic [9:0] orientation_cmd,  // Orientation command (degrees, max 360)
    input logic [1:0] cmd,          // Command input: 00=stop, 01=forward, 10=backward, 11=turn
    input logic [1:0] turn_dir,     // Turn direction: 00=left, 01=right
    output logic motor_left_fwd,    // Motor control for left motor (forward)
    output logic motor_left_bwd,    // Motor control for left motor (backward)
    output logic motor_right_fwd,   // Motor control for right motor (forward)
    output logic motor_right_bwd,   // Motor control for right motor (backward)
    output logic flag_A,            // Flag to signal Module A
    output logic finish_flag_B,     // Flag to signal Module B when done
    output logic done               // Signal to indicate movement is complete
);

    // Parameters
    parameter TURN_ANGLE = 45;            // 45-degree turn
    parameter TURN_TIME = 250000;         // Time in clock cycles for 45-degree turn
    parameter PAUSE_TIME = 25000000;      // Time for 0.5-second pause (depends on your clock)
    
    // Internal state machine states
    typedef enum logic [2:0] {
        IDLE       = 3'b000,
        TURN       = 3'b001,
        PAUSE      = 3'b010,
        NEXT_TURN  = 3'b011,
        ORIENTATE  = 3'b100,
        COMPLETE   = 3'b101
    } state_t;

    state_t current_state, next_state;
    logic [31:0] timer;  // Timer for pause and turn duration
    logic [3:0] turn_count; // Counter to track 8 turns for finding person
    logic [9:0] current_orientation;  // Current orientation (degrees)

    // Sequential logic for state transition and timer counting
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            timer <= 0;
            turn_count <= 0;
            current_orientation <= 0;
        end 
        else begin
            current_state <= next_state;
            if (current_state == TURN || current_state == PAUSE || current_state == ORIENTATE) begin
                timer <= timer + 1;
            end 
            else begin
                timer <= 0;
            end
            if (current_state == TURN && next_state == PAUSE) begin
                turn_count <= turn_count + 1;
                current_orientation <= current_orientation + TURN_ANGLE;
            end
        end
    end

    // Combinational logic for next state and motor control signals
    always_comb begin
        // Default outputs
        motor_left_fwd = 1'b0;
        motor_left_bwd = 1'b0;
        motor_right_fwd = 1'b0;
        motor_right_bwd = 1'b0;
        flag_A = 1'b0;
        finish_flag_B = 1'b0;
        done = 1'b0;
        next_state = current_state;

        case (current_state)
            IDLE: begin
                if (find_person_cmd) begin
                    next_state = TURN;
                end 
                
                else if (cmd == 2'b11) begin  // Command to orientate to specific direction
                    next_state = ORIENTATE;
                end
            end

            TURN: begin
                // Turn robot by 45 degrees
                motor_left_bwd = 1'b1;
                motor_right_fwd = 1'b1;
                if (timer >= TURN_TIME) begin
                    next_state = PAUSE;
                end
            end

            PAUSE: begin
                // Pause for 0.5 seconds
                flag_A = 1'b1; // Signal to Module A to record
                if (timer >= PAUSE_TIME) begin
                    if (turn_count < 8) begin
                        next_state = TURN;
                    end else begin
                        next_state = COMPLETE;
                    end
                end
            end

            ORIENTATE: begin
                // Rotate to specified orientation command
                if (orientation_cmd > current_orientation) begin
                    motor_left_bwd = 1'b1;
                    motor_right_fwd = 1'b1;
                end else if (orientation_cmd < current_orientation) begin
                    motor_left_fwd = 1'b1;
                    motor_right_bwd = 1'b1;
                end

                if (timer >= TURN_TIME * (orientation_cmd / TURN_ANGLE)) begin
                    current_orientation = orientation_cmd;
                    next_state = COMPLETE;
                end
            end

            COMPLETE: begin
                finish_flag_B = 1'b1;  // Signal to Module B that the operation is complete
                done = 1'b1;  // Indicate that the process is complete
                next_state = IDLE;
            end
        endcase
    end

endmodule
