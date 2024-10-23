module FSM (

);

typedef enum logic [1:0] {
    IDLE   = 2'b00,
    IR     = 2'b01,
    CAMERA = 2'b10,
    SEARCH = 2'b11
} state;


endmodule 