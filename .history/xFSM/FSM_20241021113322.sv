module FSM (
    .
);

typedef enum logic [1:0] {
    IDLE = 2'b00,
    IR   = 2'b01,
    CAM  = 2'b10
} state;
state current_state, next_state;

typedef enum logic [1:0] {
    SEARCH = 2'b00,
    FOLLOW = 2'b01,
    PAUSE  = 2'b11
} CAM_state;
CAM_state current_CAM_state, next_CAM_state;

typedef enum logic [2:0] {
    STOP   = 3'b000,
    LEFT   = 3'b001,
    RIGHT  = 3'b010,
    SLOW   = 3'b011,
    MEDIUM = 3'b100,
    FAST   = 3'b101
} drive_state;
drive current_drive_state, next_drive_state;



endmodule 