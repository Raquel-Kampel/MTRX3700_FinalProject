module json_to_uart_top_tb();

    // Testbench signals
    logic clk;
    logic rst;
    logic start;
    logic [255:0] json_flat;  // Flattened JSON string
    logic [7:0] json_len;     // Length of the JSON string
    logic GPIO_5;             // UART TX output
    logic [17:0] LEDR;        // LEDs output
    logic done;               // Transmission complete signal

    // Instantiate the DUT (Device Under Test)
    json_to_uart_top dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .json_flat(json_flat),
        .json_len(json_len),
        .GPIO_5(GPIO_5),
        .LEDR(LEDR),
        .done(done)
    );

    // Generate a 50 MHz clock signal
    always #10 clk = ~clk;

    // Test scenario
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        start = 0;
        json_len = 23;  // Length of the JSON: {"T":1,"L":0.5,"R":0.5}

        // Provide the flattened JSON string
        json_flat = {
            8'h7B, 8'h22, 8'h54, 8'h22, 8'h3A, 8'h31, 8'h2C, 8'h22,
            8'h4C, 8'h22, 8'h3A, 8'h30, 8'h2E, 8'h35, 8'h2C, 8'h22,
            8'h52, 8'h22, 8'h3A, 8'h30, 8'h2E, 8'h35, 8'h7D
        };

        // Release reset after 100 ns
        #100 rst = 0;

        // Start the transmission after a short delay
        #50 start = 1;
        #20 start = 0;  // De-assert the start signal

        // Wait for the `done` signal
        wait(done);

        // Display the result
        $display("Test Passed: Transmission completed at time %0t", $time);

        // End the simulation
        #100 $finish;
    end

endmodule




