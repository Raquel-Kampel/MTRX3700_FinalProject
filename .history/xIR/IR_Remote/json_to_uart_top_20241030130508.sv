module json_to_uart_top(
    input  logic clk,
    input  logic rst,               // Reset button (e.g., KEY[0])
    //input  logic transmitting,             // Start signal from switch (e.g., SW[0])
	input  logic [2:0] state_control, // External input for state control (3 bits)
    output logic GPIO_5,            // UART TX data on GPIO[5]
    output logic [17:0] LEDR,       // LEDs to display transmitted bytes and status
    output logic done,
	output logic [7:0] json_len_test               // Transmission complete signal
);

    // Internal signals
    logic uart_out;
    logic uart_ready;
    logic [7:0] data_out;
    logic data_valid;
    logic [7:0] byte_index;             // Track current byte index
    logic [31:0] delay_counter;
	logic transmitting;

    // Parameters
    parameter CLK_FREQ_HZ = 50_000_000;  
    parameter DELAY_SEC = 0;             
    parameter DELAY_COUNT = CLK_FREQ_HZ * DELAY_SEC;

    // JSON command for different states
    logic [271:0] json_flat;

    // Updated length of the JSON string (varies based on state, use max length)
    logic [7:0] json_len;

    // Update JSON command based on current state
    always_comb begin
        case (state_control)
            4'b0001: begin // LEFT
					 json_flat = {
						  8'h7B,  // '{'
						  8'h22,  // '"'
						  8'h54,  // 'T'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h31,  // '1'
						  8'h2C,  // ','
						  8'h22,  // '"'
						  8'h4C,  // 'L'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h2D,  // '-'
						  8'h30,  // '0'
						  8'h2E,  // '.'
						  8'h30,  // '0'
						  8'h30,  // '0'
						  8'h2C,  // ','
						  8'h22,  // '"'
						  8'h52,  // 'R'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h30,  // '0'
						  8'h2E,  // '.'
						  8'h31,  // '1'
						  8'h32,  // '2'
						  8'h7D,  // '}'
						  8'h0A   // '\n' (newline character)
					 };
                json_len = 27;  
            end
            4'b0010: begin // RIGHT
					 json_flat = {
						  8'h7B,  // '{'
						  8'h22,  // '"'
						  8'h54,  // 'T'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h31,  // '1'
						  8'h2C,  // ','
						  8'h22,  // '"'
						  8'h4C,  // 'L'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h30,  // '0'
						  8'h2E,  // '.'
						  8'h31,  // '1'
						  8'h32,  // '2'
						  8'h2C,  // ','
						  8'h22,  // '"'
						  8'h52,  // 'R'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h2D,  // '-'
						  8'h30,  // '0'
						  8'h2E,  // '.'
						  8'h30,  // '0'
						  8'h30,  // '0'
						  8'h7D,  // '}'
						  8'h0A   // '\n' (newline character)
					 };
                json_len = 27;  
            end
            4'b0101: begin // FORWARD FAST
					 json_flat = {
						  8'h7B,  // '{'
						  8'h22,  // '"'
						  8'h54,  // 'T'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h31,  // '1'
						  8'h2C,  // ','
						  8'h22,  // '"'
						  8'h4C,  // 'L'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h30,  // '0'
						  8'h2E,  // '.'
						  8'h35,  // '5'
						  8'h2C,  // ','
						  8'h22,  // '"'
						  8'h52,  // 'R'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h30,  // '0'
						  8'h2E,  // '.'
						  8'h35,  // '5'
						  8'h7D,  // '}'
						  8'h0A   // '\n' (newline character)
					 };
					 
                json_len = 24;  
            end
            4'b0100: begin //FORWARD MEDIUM
					 json_flat = {
						  8'h7B,  // '{'
						  8'h22,  // '"'
						  8'h54,  // 'T'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h31,  // '1'
						  8'h2C,  // ','
						  8'h22,  // '"'
						  8'h4C,  // 'L'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h30,  // '0'
						  8'h2E,  // '.'
						  8'h32,  // '2'
						  8'h35,  // '5'
						  8'h2C,  // ','
						  8'h22,  // '"'
						  8'h52,  // 'R'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h30,  // '0'
						  8'h2E,  // '.'
						  8'h32,  // '2'
						  8'h35,  // '5'
						  8'h7D,  // '}'
						  8'h0A   // '\n' (newline character)
					 };
                json_len = 26;  
            end
            4'b0011: begin //FORWARD SLOW
					 json_flat = {
						  8'h7B,  // '{'
						  8'h22,  // '"'
						  8'h54,  // 'T'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h31,  // '1'
						  8'h2C,  // ','
						  8'h22,  // '"'
						  8'h4C,  // 'L'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h30,  // '0'
						  8'h2E,  // '.'
						  8'h30,  // '0'
						  8'h35,  // '5'
						  8'h2C,  // ','
						  8'h22,  // '"'
						  8'h52,  // 'R'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h30,  // '0'
						  8'h2E,  // '.'
						  8'h30,  // '0'
						  8'h35,  // '5'
						  8'h7D,  // '}'
						  8'h0A   // '\n' (newline character)
					 };
                json_len = 26;  
			end			
            4'b0000: begin //STOP
					 json_flat = {
						  8'h7B,  // '{'
						  8'h22,  // '"'
						  8'h54,  // 'T'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h31,  // '1'
						  8'h2C,  // ','
						  8'h22,  // '"'
						  8'h4C,  // 'L'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h30,  // '0'
						  8'h2C,  // ','
						  8'h22,  // '"'
						  8'h52,  // 'R'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h30,  // '0'
						  8'h7D,  // '}'
						  8'h0A   // '\n' (newline character)
					 };
                json_len = 20;  // Set length accordingly
            end
            4'b0110: begin //REVERSE
					 json_flat = {
						  8'h7B,  // '{'
						  8'h22,  // '"'
						  8'h54,  // 'T'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h31,  // '1'
						  8'h2C,  // ','
						  8'h22,  // '"'
						  8'h4C,  // 'L'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h2D,  // '-'
						  8'h30,  // '0'
						  8'h2E,  // '.'
						  8'h32,  // '2'
						  8'h35,  // '5'
						  8'h2C,  // ','
						  8'h22,  // '"'
						  8'h52,  // 'R'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h2D,  // '-'
						  8'h30,  // '0'
						  8'h2E,  // '.'
						  8'h32,  // '2'
						  8'h35,  // '5'
						  8'h7D,  // '}'
						  8'h0A   // '\n' (newline character)
					 };
                json_len = 28;  
            end
            4'b0110: begin //LREVERSE
					 json_flat = {
						  8'h7B,  // '{'
						  8'h22,  // '"'
						  8'h54,  // 'T'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h31,  // '1'
						  8'h2C,  // ','
						  8'h22,  // '"'
						  8'h4C,  // 'L'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h2D,  // '-'
						  8'h30,  // '0'
						  8'h2E,  // '.'
						  8'h30,  // '0'
						  8'h30,  // '0'
						  8'h2C,  // ','
						  8'h22,  // '"'
						  8'h52,  // 'R'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h2D,  // '-'
						  8'h30,  // '0'
						  8'h2E,  // '.'
						  8'h32,  // '2'
						  8'h35,  // '5'
						  8'h7D,  // '}'
						  8'h0A   // '\n' (newline character)
					 };
                json_len = 28;  
            end
            4'b0110: begin //RREVERSE
					 json_flat = {
						  8'h7B,  // '{'
						  8'h22,  // '"'
						  8'h54,  // 'T'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h31,  // '1'
						  8'h2C,  // ','
						  8'h22,  // '"'
						  8'h4C,  // 'L'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h2D,  // '-'
						  8'h30,  // '0'
						  8'h2E,  // '.'
						  8'h32,  // '2'
						  8'h35,  // '5'
						  8'h2C,  // ','
						  8'h22,  // '"'
						  8'h52,  // 'R'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h2D,  // '-'
						  8'h30,  // '0'
						  8'h2E,  // '.'
						  8'h32,  // '2'
						  8'h35,  // '5'
						  8'h7D,  // '}'
						  8'h0A   // '\n' (newline character)
					 };
                json_len = 28;  
            end
			default: begin //STOP
					 json_flat = {
						  8'h7B,  // '{'
						  8'h22,  // '"'
						  8'h54,  // 'T'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h31,  // '1'
						  8'h2C,  // ','
						  8'h22,  // '"'
						  8'h4C,  // 'L'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h30,  // '0'
						  8'h2C,  // ','
						  8'h22,  // '"'
						  8'h52,  // 'R'
						  8'h22,  // '"'
						  8'h3A,  // ':'
						  8'h30,  // '0'
						  8'h7D,  // '}'
						  8'h0A   // '\n' (newline character)
					 };
                json_len = 20;  // Set length accordingly
			end
        endcase
    end

	assign json_len_test = json_len;

    // UART transmission and FSM for handling the transmission
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            byte_index <= json_len - 1;  // Start from the last byte
            transmitting <= 0;
            data_valid <= 0;
            done <= 0;
            delay_counter <= DELAY_COUNT;
        end 
		  
		else if (!transmitting) begin
            transmitting <= 1;
            byte_index <= json_len - 1;  // Start from the last byte
            data_valid <= 0;
            done <= 0;
            delay_counter <= DELAY_COUNT;
        end 
		  
		else if (transmitting) begin
            
			if (delay_counter > 0) begin
                delay_counter <= delay_counter - 1;
            end 
				
				else if (uart_ready && !data_valid) begin
                // Send the next byte when UART is ready
                data_out <= json_flat[byte_index * 8 +: 8];
                data_valid <= 1;
                byte_index <= byte_index - 1;  // Decrement index for correct order
                delay_counter <= DELAY_COUNT;
            end 
				
				else if (data_valid && uart_ready) begin
                data_valid <= 0;  // Wait for UART to consume the data
            end

            if (byte_index == 8'hFF && !data_valid) begin  // Transmission complete
                transmitting <= 0;
                done <= 1;  // Indicate transmission complete
            end
        end
    end

    // Instantiate the UART transmitter
    uart_tx #(
        .CLKS_PER_BIT(434),  // Baud rate = 115200 (for 50 MHz clock)
        .BITS_N(8),
        .PARITY_TYPE(0)
    ) uart_tx_inst (
        .clk(clk),
        .rst(rst),
        .data_tx(data_out),
        .uart_out(uart_out),
        .valid(data_valid),
        .ready(uart_ready)
    );

    // Assign the UART TX output to GPIO_5
    assign GPIO_5 = uart_out;

endmodule