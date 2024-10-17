module uart_rx_tb();

    // Testbench signals
    logic clk;
    logic rst;
    logic uart_in;
    logic [7:0] data_rx;
    logic valid;
    logic ready;

    // Instantiate the DUT (Device Under Test)
    uart_rx #(
        .CLKS_PER_BIT(434),  // Baud rate = 115200 (for 50 MHz clock)
        .BITS_N(8)
    ) dut (
        .clk(clk),
        .rst(rst),
        .uart_in(uart_in),
        .data_rx(data_rx),
        .valid(valid),
        .ready(ready)
    );

    // Generate a 50 MHz clock (period = 20 ns)
    always #10 clk = ~clk;

    // UART transmission helper task (sends one byte over UART)
    task send_byte(input [7:0] data_byte);
        integer i;
        begin
            // Ensure the line is idle before transmitting
            uart_in = 1;
            #(434 * 20);  // Wait 1 bit period (idle state)

            // Start bit (low)
            uart_in = 0;
            #(434 * 20);  // Wait 1 bit period for start bit

            // Send 8 data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                uart_in = data_byte[i];
                #(434 * 20);  // Wait 1 bit period for each data bit
            end

            // Stop bit (high)
            uart_in = 1;
            #(434 * 20);  // Wait 1 bit period for stop bit

            // Return to idle state (high)
            uart_in = 1;
            #(434 * 20);  // Wait extra time to ensure idle state
        end
    endtask

    // Test scenario
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        uart_in = 1;  // Idle state (high)
        ready = 1;    // Always ready to receive data

        // Apply reset
        #50 rst = 0;

        // Wait a bit before sending data
        #100;

        // Send byte 0x55 ("U" in ASCII)
        $display("Sending byte 0x55 at time %0t", $time);
        send_byte(8'h55);  // Binary: 01010101

        // Wait for the `valid` signal to assert
        wait (valid);

        // Check the received data
        if (data_rx == 8'h55) begin
            $display("Test Passed: Received byte = 0x%h at time %0t", data_rx, $time);
        end else begin
            $display("Test Failed: Expected 0x55, but got 0x%h at time %0t", data_rx, $time);
        end

        // End the simulation
        #100 $finish;
    end

endmodule
