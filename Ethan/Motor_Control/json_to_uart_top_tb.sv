module json_to_uart_top_tb();

    // Testbench signals
    logic clk;
    logic rst;
    logic start;
    logic [7:0] json_str [0:31];  // JSON string input (max 32 bytes)
    logic [7:0] json_len;         // Length of the JSON string
    logic GPIO_5;                 // UART TX line output (connected to robot's RX)
    logic done;                   // Transmission complete signal

    // Instantiate the DUT (Device Under Test)
    json_to_uart_top dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .json_str(json_str),
        .json_len(json_len),
        .GPIO_5(GPIO_5),
        .done(done)
    );

    // Generate a clock signal (50 MHz)
    always #10 clk = ~clk;

    // Test scenario
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        start = 0;
        json_len = 25;  // Length of the JSON string for speed control

        // Provide JSON string: {"T":1,"L":0.5,"R":0.5}
        json_str[0]  = 8'h7B;  // '{'
        json_str[1]  = 8'h22;  // '"'
        json_str[2]  = 8'h54;  // 'T'
        json_str[3]  = 8'h22;  // '"'
        json_str[4]  = 8'h3A;  // ':'
        json_str[5]  = 8'h31;  // '1'
        json_str[6]  = 8'h2C;  // ','
        json_str[7]  = 8'h22;  // '"'
        json_str[8]  = 8'h4C;  // 'L'
        json_str[9]  = 8'h22;  // '"'
        json_str[10] = 8'h3A;  // ':'
        json_str[11] = 8'h30;  // '0'
        json_str[12] = 8'h2E;  // '.'
        json_str[13] = 8'h35;  // '5'
        json_str[14] = 8'h2C;  // ','
        json_str[15] = 8'h22;  // '"'
        json_str[16] = 8'h52;  // 'R'
        json_str[17] = 8'h22;  // '"'
        json_str[18] = 8'h3A;  // ':'
        json_str[19] = 8'h30;  // '0'
        json_str[20] = 8'h2E;  // '.'
        json_str[21] = 8'h35;  // '5'
        json_str[22] = 8'h7D;  // '}'

        // Release reset after 100 ns
        #100 rst = 0;

        // Start the transmission after a short delay
        #50 start = 1;
        #20 start = 0;  // De-assert the start signal

        // Wait for transmission to complete
        wait(done);

        // Check if the transmission completed successfully
        if (done) begin
            $display("Test Passed: JSON transmission completed at time %0t", $time);
        end else begin
            $display("Test Failed: Transmission did not complete as expected.");
        end

        // End the simulation
        #100 $finish;
    end

endmodule


