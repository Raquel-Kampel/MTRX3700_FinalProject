`timescale 1 ps / 1 ps

module ir_controller_tb;

    // Testbench signals
    logic clk;
    logic rst_n;
    logic [31:0] ir_data;
    logic data_ready;
    logic [2:0] state_control;  // 3-bit state output from ir_controller

    // Instantiate the ir_controller module
    ir_controller dut (
        .clk(clk),
        .rst_n(rst_n),
        .ir_data(ir_data),
        .data_ready(data_ready),
        .state_control(state_control)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 ps clock period
    end

    // Test procedure
    initial begin
        // Reset the system
        rst_n = 0;
        #10 rst_n = 1;

        // Test the Stop command (0x12)
        ir_data = 32'h00000012;
        data_ready = 1;
        #10 data_ready = 0;
        #10 $display("State Control (STOP): %b", state_control); // Should print 000
        assert(state_control == 3'b000) else $fatal("STOP command failed!");

        // Test the Left command (0x14)
        ir_data = 32'h00000014;
        data_ready = 1;
        #10 data_ready = 0;
        #10 $display("State Control (LEFT): %b", state_control); // Should print 001
        assert(state_control == 3'b001) else $fatal("LEFT command failed!");

        // Test the Right command (0x18)
        ir_data = 32'h00000018;
        data_ready = 1;
        #10 data_ready = 0;
        #10 $display("State Control (RIGHT): %b", state_control); // Should print 010
        assert(state_control == 3'b010) else $fatal("RIGHT command failed!");

        // Test the Fast command (0x1B)
        ir_data = 32'h0000001B;
        data_ready = 1;
        #10 data_ready = 0;
        #10 $display("State Control (FAST): %b", state_control); // Should print 011
        assert(state_control == 3'b011) else $fatal("FAST command failed!");

        // Test the Slow command (0x1F)
        ir_data = 32'h0000001F;
        data_ready = 1;
        #10 data_ready = 0;
        #10 $display("State Control (SLOW): %b", state_control); // Should print 100
        assert(state_control == 3'b100) else $fatal("SLOW command failed!");

        $stop; // End simulation
    end

endmodule


