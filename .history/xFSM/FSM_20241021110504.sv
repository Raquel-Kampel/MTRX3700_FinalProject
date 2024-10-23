module FSM (

);

typedef enum logic [1:0] {
    IDLE = 2'b00,
    IR   = 2'b01,
    CAM  = 2'b10,
} state;
state current_state, next_state;

typedef enum logic [1:0] {
    SEARCH   = 2'b00,
    FOLLOW     = 2'b01,
} state;

endmodule 