module json_uart_tb;

    // Testbench signals
    logic clk;
    logic rst;
    logic start;
    logic [7:0] json_str [0:31];  // Array for JSON string (maximum of 32 characters)
    logic [7:0] json_len;         // Length of the JSON string
    logic uart_out;               // UART transmission line output
    logic done;                   // Done signal from json_to_uart

    // Clock generation (50 MHz clock)
    always #10 clk = ~clk;  // 50 MHz clock with 20ns period

    // Instantiate the JSON to UART conversion module with UART transmitter
    json_to_uart json_inst (
        .clk(clk),
        .rst(rst),
        .start(start),
        .json_str(json_str),
        .json_len(json_len),
        .uart_out(uart_out),     // UART transmission line
        .done(done)
    );

    // Initial block to drive the inputs and simulate the UART transmission
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        start = 0;
        
        // Apply reset for 50 time units
        #50 rst = 0;

        // Load JSON string into json_str array
        json_str[0] = 8'h7B;  // '{'
        json_str[1] = 8'h22;  // '"'
        json_str[2] = 8'h54;  // 'T'
        json_str[3] = 8'h22;  // '"'
        json_str[4] = 8'h3A;  // ':'
        json_str[5] = 8'h31;  // '1'
        json_str[6] = 8'h31;  // '1'
        json_str[7] = 8'h7D;  // '}'

        json_len = 8;  // Set the length of the JSON string

        // Start transmitting the JSON string
        #100 start = 1;
        #100 start = 0;

        // Run the simulation for a longer duration to capture the full transmission
        #700000 $finish;  // 700,000 ps = 700 microseconds
    end

    // Monitor the uart_out signal and done signal to track transmission
    initial begin
        $monitor("Time: %0t | UART Out: %b | Done: %b", 
                  $time, uart_out, done);
    end

    // Dump waveform data for analysis in a waveform viewer
    initial begin
        $dumpfile("json_uart_tb.vcd");
        $dumpvars(0, json_uart_tb);
    end

endmodule



