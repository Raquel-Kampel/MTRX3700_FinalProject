module FSM (
    input logic [7:0] IR_button
);

// ~ State Definitions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

typedef enum logic [1:0] { 
    IDLE = 2'b00,           // Setting initial drive mode
    CAM   = 2'b01,
    IR  = 2'b10
} state;
state current_state, next_state;

typedef enum logic [1:0] { 
    SEARCH = 2'b00,         // Setting sub-states for CAM
    FOLLOW = 2'b01,
    PAUSE  = 2'b11
} CAM_state;
CAM_state current_CAM_state, next_CAM_state;

typedef enum logic [2:0] { 
    STOP   = 3'b000,        // Setting global drive state
    LEFT   = 3'b001,
    RIGHT  = 3'b010,
    SLOW   = 3'b011,
    MEDIUM = 3'b100,
    FAST   = 3'b101
} drive_state;
drive current_drive_state, next_drive_state;

// ~ State Setter ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

always_comb begin
    case(current_state)

        IDLE: next_state = (IR_button == 8'h0f) ? CAM : (IR_button == 8'h13) ? IR : IDLE;
        IDLE: next_state = (IR_button == 8'h0f) ? CAM : (IR_button == 8'h13) ? IR : IDLE;
        IDLE: next_state = (IR_button == 8'h0f) ? CAM : (IR_button == 8'h13) ? IR : IDLE;


    endcase

    case(current_CAM_state)

    endcase   

    case(current_drive_state)

    endcase







    case(state)
        Idle:next_state=(hex_data[23:16]==8'h0f)?IR_drive:
                        (hex_data[23:16]==8'h13)?RED_drive: Idle;

        IR_drive:next_state=(hex_data[23:16]==8'h13)?RED_drive:
                            (LEDG<e_stop||hex_data[23:16]==8'h10)?Idle:IR_drive;

        RED_drive:next_state=(hex_data[23:16]==8'h0f)?IR_drive:
                            (hex_data[23:16]==8'h10)?Idle:RED_drive;
    endcase
    case(ir_drive)
        ir_Stop:ir_next_drive=(hex_data[23:16]==8'h05)?ir_Forward:
                (hex_data[23:16]==8'h07)?ir_Left:
                (hex_data[23:16]==8'h09)?ir_Right:
                (hex_data[23:16]==8'h04)?ir_arc_Left:
                (hex_data[23:16]==8'h06)?ir_arc_Right:ir_Stop;

        ir_Forward:ir_next_drive=(LEDG<e_stop||hex_data[23:16]==8'h08)?ir_Stop:
                (hex_data[23:16]==8'h07)?ir_Left:
                (hex_data[23:16]==8'h09)?ir_Right:
                (hex_data[23:16]==8'h04)?ir_arc_Left:
                (hex_data[23:16]==8'h06)?ir_arc_Right:ir_Forward;

        ir_Left:ir_next_drive=(hex_data[23:16]==8'h05)?ir_Forward:
                (LEDG<e_stop||hex_data[23:16]==8'h08)?ir_Stop:
            (hex_data[23:16]==8'h09)?ir_Right:
            (hex_data[23:16]==8'h04)?ir_arc_Left:
                (hex_data[23:16]==8'h06)?ir_arc_Right:ir_Left;
                    
        ir_Right:ir_next_drive=(hex_data[23:16]==8'h05)?ir_Forward:
                (hex_data[23:16]==8'h07)?ir_Left:
                (LEDG<e_stop||hex_data[23:16]==8'h08)?ir_Stop:
                (hex_data[23:16]==8'h04)?ir_arc_Left:
                (hex_data[23:16]==8'h06)?ir_arc_Right:ir_Right;

        ir_arc_Left:ir_next_drive=(hex_data[23:16]==8'h05)?ir_Forward:
                (hex_data[23:16]==8'h07)?ir_Left:
                (hex_data[23:16]==8'h09)?ir_Right:
                (LEDG<e_stop||hex_data[23:16]==8'h08)?ir_Stop:
                (hex_data[23:16]==8'h06)?ir_arc_Right:ir_arc_Left;

        ir_arc_Right:ir_next_drive=(hex_data[23:16]==8'h05)?ir_Forward:
                (hex_data[23:16]==8'h07)?ir_Left:
                (hex_data[23:16]==8'h09)?ir_Right:
                (LEDG<e_stop||hex_data[23:16]==8'h08)?ir_Stop:
                (hex_data[23:16]==8'h04)?ir_arc_Left:ir_arc_Right;
    endcase
    case (red)
        r_follow:next_red=(hex_data[23:16]==8'h1B)?r_detect:r_follow;
        r_detect:next_red=(hex_data[23:16]==8'h1F||reset==1)?r_follow:r_detect;
    endcase
    case(gear)
        Gear_1:next_gear=(hex_data[23:16]==8'h1A)?Gear_2:Gear_1;
        Gear_2:next_gear=(hex_data[23:16]==8'h1A)?Gear_3:
                                            (hex_data[23:16]==8'h1E)?Gear_1:Gear_2;
        Gear_3:next_gear=(hex_data[23:16]==8'h1A)?Gear_4:
                                            (hex_data[23:16]==8'h1E)?Gear_2:Gear_3;
        Gear_4:next_gear=(hex_data[23:16]==8'h1E)?Gear_3:Gear_4;
    endcase
end


always_ff @(posedge CLOCK_50)begin
    if (state!=next_state||next_gear!=gear) begin
        reset=1;
    end
    else begin
        reset=0;
    end
    state<=next_state;
    ir_drive<=ir_next_drive;
        red<=next_red;
    gear<=next_gear;
end


endmodule 