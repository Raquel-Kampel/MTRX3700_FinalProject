module uart_rx #(
    parameter CLKS_PER_BIT = (50_000_000 / 115_200),  // 115200 baud rate
    parameter BITS_N = 8                              // 8 data bits
) (
    input  logic clk,              // Clock input (50 MHz)
    input  logic rst,              // Reset input
    input  logic uart_in,          // UART RX input
    output logic [7:0] data_rx,    // Received byte output
    output logic valid,            // Valid signal (1 cycle pulse when byte received)
    input  logic ready             // Ready signal (high to accept new data)
);

    // State machine states
    typedef enum logic [1:0] {
        IDLE = 2'b00,
        START_BIT = 2'b01,
        DATA_BITS = 2'b10,
        STOP_BIT = 2'b11
    } state_t;

    state_t state, next_state;     // Current and next states

    // Internal signals
    logic [15:0] clk_count;        // Clock counter for bit timing
    logic [2:0] bit_index;         // Index to track received bits
    logic [7:0] shift_reg;         // Shift register to hold incoming data bits

    // State machine logic with `negedge` clock sampling
    always_ff @(negedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            clk_count <= 0;
            bit_index <= 0;
            shift_reg <= 0;
            valid <= 0;            // Clear valid on reset
        end else begin
            state <= next_state;   // Update state

            // Increment clock counter if not in IDLE
            if (state != IDLE) begin
                if (clk_count < CLKS_PER_BIT - 1)
                    clk_count <= clk_count + 1;
                else
                    clk_count <= 0;  // Reset at end of bit period
            end else begin
                clk_count <= 0;  // Keep counter reset in IDLE
            end

            // Sample data bit at the middle of the bit period on `negedge`
            if (state == DATA_BITS && clk_count == (CLKS_PER_BIT / 2)) begin
                shift_reg <= {uart_in, shift_reg[7:1]};  // Shift in new bit (LSB first)
                bit_index <= bit_index + 1;
                $display("Data bit received: %b, Index: %0d, Shift_reg: %b, Time: %0t", 
                         uart_in, bit_index, shift_reg, $time);
            end

            // Assert valid when stop bit completes
            if (state == STOP_BIT && clk_count == CLKS_PER_BIT - 1) begin
                valid <= 1;  // Byte received successfully
                $display("Valid asserted: Byte received = 0x%h at time %0t", shift_reg, $time);
            end else begin
                valid <= 0;  // Deassert valid after one cycle
            end
        end
    end

    // Next-state logic
    always_comb begin
        next_state = state;  // Default to staying in the same state
        case (state)
            IDLE: begin
                if (!uart_in)  // Start bit detected (low)
                    next_state = START_BIT;
            end
            START_BIT: begin
                if (clk_count == CLKS_PER_BIT - 1)
                    next_state = DATA_BITS;  // Move to data bits
            end
            DATA_BITS: begin
                if (bit_index == BITS_N - 1 && clk_count == CLKS_PER_BIT - 1)
                    next_state = STOP_BIT;  // All bits received
            end
            STOP_BIT: begin
                if (clk_count == CLKS_PER_BIT - 1)
                    next_state = IDLE;  // Return to IDLE
            end
        endcase
    end

    // Assign output byte from the shift register
    assign data_rx = shift_reg;

endmodule





