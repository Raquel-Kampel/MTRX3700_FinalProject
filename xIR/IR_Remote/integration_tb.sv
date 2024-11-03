`timescale 1 ps / 1 ps

module integration_tb;

    // Testbench signals
    logic clk, rst;
    logic [31:0] ir_data;
    logic data_ready;
    logic [2:0] state_control;
    logic GPIO_5;
    logic [17:0] LEDR;
    logic done;

    // Instantiate the IR controller
    ir_controller ir_ctrl (
        .clk(clk),
        .rst_n(~rst),  // Active-low reset
        .ir_data(ir_data),
        .data_ready(data_ready),
        .state_control(state_control)
    );

    // Instantiate the json_to_uart_top module
    json_to_uart_top uart_top (
        .clk(clk),
        .rst(rst),
        .state_control(state_control),
        .GPIO_5(GPIO_5),
        .LEDR(LEDR),
        .done(done)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 ps clock period
    end

    // Test procedure with dynamic ir_data updates
    initial begin
        // Reset the system
        rst = 1;
        #10 rst = 0;

        // Test different IR codes
        test_ir_code(32'h00000014, 3'b001);  // Left arrow keycode
        test_ir_code(32'h00000018, 3'b010);  // Right arrow keycode
        test_ir_code(32'h0000001B, 3'b011);  // Volume up keycode
        test_ir_code(32'h0000001F, 3'b100);  // Volume down keycode
        test_ir_code(32'h00000012, 3'b000);  // Mute keycode

        $stop; // End the simulation
    end

    // Task to test each IR code with expected state
    task test_ir_code(input [31:0] code, input [2:0] expected_state);
        begin
            ir_data = code;         // Set the IR data
            data_ready = 1;         // Assert data ready
            #10 data_ready = 0;     // Deassert data ready
            #10;                    // Wait for state transition
            $display("State: %b (Expected: %b)", state_control, expected_state);
            #20;                    // Add delay between tests
        end
    endtask

endmodule




