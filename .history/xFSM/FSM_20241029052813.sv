module FSM (
    input logic clk_50,
    input logic [7:0] IR_button,
    input logic [2:0] CAM_direction,
    input logic [1:0] speed,
    input logic orange_detected,
    output logic reset,
    output logic [1:0] state,
    output logic [1:0] CAM_state,
    output logic [2:0] drive_state,
    output logic [6:0] HEX0,
    output logic [6:0] HEX1,
    output logic [6:0] HEX2,
    output logic [6:0] HEX3,
    output logic [6:0] HEX4,
    output logic [6:0] HEX5,
    output logic [6:0] HEX6,
    output logic [6:0] HEX7

);

// ~ State Definitions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

typedef enum logic [1:0] { 
    IDLE = 2'b00,           // Setting initial drive mode
    CAM   = 2'b01,
    IR  = 2'b10
} states;
states current_state, next_state;

typedef enum logic [1:0] { 
    SEARCH = 2'b00,         // Setting sub-states for CAM
    FOLLOW = 2'b01,
    PAUSE  = 2'b11
} CAM_states;
CAM_states current_CAM_state, next_CAM_state;

typedef enum logic [2:0] { 
    STOP   = 3'b000,        // Setting global drive state
    LEFT   = 3'b001,
    RIGHT  = 3'b010,
    SLOW   = 3'b011,
    MEDIUM = 3'b100,
    FAST   = 3'b101
} drive_states;
drive_states current_drive_state, next_drive_state;

// ~ State Setter ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

always_comb begin
    case(current_state)

        IDLE: next_state = (IR_button == 8'h0f) ? CAM : (IR_button == 8'h13) ? IR   : IDLE;
        CAM:  next_state = (IR_button == 8'h13) ? IR  : (IR_button == 8'h10) ? IDLE : CAM;
        IR:   next_state = (IR_button == 8'h0f) ? CAM : (IR_button == 8'h10) ? IDLE : IR;

    endcase

    case(current_CAM_state)

        SEARCH: next_CAM_state = (next_state != CAM) ? PAUSE : (orange_detected)   ? FOLLOW : SEARCH;
        FOLLOW: next_CAM_state = (next_state != CAM) ? PAUSE : (!orange_detected)  ? SEARCH : FOLLOW;
        PAUSE:  next_CAM_state = (next_state == CAM) ? SEARCH : PAUSE;

    endcase   

    next_drive_state = (next_CAM_state == SEARCH) ? RIGHT :
                       (next_CAM_state == FOLLOW && CAM_direction == 3'b010) ? RIGHT :
                       (next_CAM_state == FOLLOW && CAM_direction == 3'b001) ? LEFT :
                       (next_CAM_state == FOLLOW && CAM_direction == 3'b011 && speed == 2'b00) ? SLOW :
                       (next_CAM_state == FOLLOW && CAM_direction == 3'b011 && speed == 2'b01) ? MEDIUM :
                       (next_CAM_state == FOLLOW && CAM_direction == 3'b011 && speed == 2'b10) ? FAST : STOP;

    
end

always_ff @(posedge clk_50)begin
    if (current_state != next_state || current_CAM_state != next_CAM_state) begin
        reset <= 1;
    end
    else begin
        reset <= 0;
    end
    current_state <= next_state;
    current_CAM_state <= next_CAM_state;
    current_drive_state <= next_drive_state;
end

assign state = current_state;
assign CAM_state = current_CAM_state;
assign drive_state = current_drive_state;

assign HEX7 = (current_state == IDLE) ? 7'b1111001 :   // 'I'
              (current_state == CAM)  ? 7'b1000110 :   // 'C'
              (current_state == IR)   ? 7'b1111001 :   // 'I'
                                        7'b0000110 ;   // 'E'

assign HEX6 = (current_state == IDLE) ? 7'b0100001 :   // 'd'
              (current_state == CAM)  ? 7'b0001000 :   // 'A'
              (current_state == IR)   ? 7'b0101111 :   // 'r'
                                        7'b0101111 ;   // 'r'

assign HEX4 = (current_CAM_state == SEARCH)  ? 7'b0010010 :   // 'S'
              (current_CAM_state == FOLLOW)  ? 7'b0001110 :   // 'F'
              (current_CAM_state == PAUSE)   ? 7'b0001100 :   // 'P'
                                               7'b1111111 ;   // ''

assign HEX3 = (current_drive_state == LEFT) ?   7'b1000111 :   // 'L'   //
              (current_drive_state == RIGHT) ?  7'b0101111 :   // 'r'
              (current_drive_state == SLOW) ?   7'b0010010 :   // 'S'
              (current_drive_state == MEDIUM) ? 7'b0010010 :   // 'S'
              (current_drive_state == FAST) ?   7'b0010010 :   // 'S'
              (current_drive_state == STOP) ?   7'b0010010 :   // 'S'
                                                7'b1111111 ;   // ''

assign HEX2 = (current_drive_state == LEFT) ?   7'b0000110 :   // 'E' 
              (current_drive_state == RIGHT) ?  7'b0000010 :   // 'G'
              (current_drive_state == SLOW) ?   7'b0001100 :   // 'P'
              (current_drive_state == MEDIUM) ? 7'b0001100 :   // 'P'
              (current_drive_state == FAST) ?   7'b0001100 :   // 'P'
              (current_drive_state == STOP) ?   7'b0001111 :   // 't'
                                                7'b1111111 ;   // ''

assign HEX1 = (current_drive_state == LEFT) ?   7'b0001110 :   // 'F' 
              (current_drive_state == RIGHT) ?  7'b0001001 :   // 'H'
              (current_drive_state == SLOW) ?   7'b1111111 :   // ''
              (current_drive_state == MEDIUM) ? 7'b1111111 :   // '' 
              (current_drive_state == FAST) ?   7'b1111111 :   // ''
              (current_drive_state == STOP) ?   7'b1000000 :   // 'O'
                                                7'b1111111 ;   // ''

assign HEX0 = (current_drive_state == LEFT) ?   7'b0001111 :   // 't' 
              (current_drive_state == RIGHT) ?  7'b0001111 :   // 't'
              (current_drive_state == SLOW) ?   7'b1111001 :   // '1'
              (current_drive_state == MEDIUM) ? 7'b0100100 :   // '2'
              (current_drive_state == FAST) ?   7'b0110000 :   // '3'
              (current_drive_state == STOP) ?   7'b0001100 :   // 'P'
                                                7'b1111111 ;   // ''








endmodule 