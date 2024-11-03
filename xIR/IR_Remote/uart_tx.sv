module uart_tx #(
    parameter CLKS_PER_BIT = (50_000_000/115_200),  // Baud_rate = 115200 with FPGA clk = 50MHz
    parameter BITS_N = 8,                           // Number of data bits per UART frame
    parameter PARITY_TYPE = 0                       // 0 for none, 1 for odd parity, 2 for even parity
) (
    input clk,
    input rst,
    input [BITS_N-1:0] data_tx,
    output logic uart_out,
    input valid,            // Handshake protocol: valid when `data_tx` is valid to be sent onto the UART
    output logic ready      // Handshake protocol: ready when UART is ready to send data
);

    logic [BITS_N-1:0] data_tx_temp;
    logic [2:0]        bit_n;
    logic [31:0]       clk_count;   // Clock counter for CLKS_PER_BIT
    logic              clk_en;      // Enable signal for bit transmission
    logic              parity_bit;  // Parity bit
    logic              stop_bit;

    enum {IDLE, START_BIT, DATA_BITS, PARITY_BIT, STOP_BIT} current_state, next_state;

    // Clock counter logic to match baud rate
    always_ff @(posedge clk) begin
        if (rst || (current_state == IDLE)) begin
            clk_count <= 0;
            clk_en <= 0;
        end else if (clk_count == CLKS_PER_BIT - 1) begin
            clk_count <= 0;
            clk_en <= 1;  // Enable bit transmission on this cycle
        end else begin
            clk_count <= clk_count + 1;
            clk_en <= 0;
        end
    end

    

    // Parity calculation logic
    always_comb begin : parity_logic
        parity_bit = 1'b0;  // Default to 0 when no parity
        if (PARITY_TYPE != 0) begin
            parity_bit = ^data_tx_temp;  // XOR of all bits to calculate parity
            if (PARITY_TYPE == 1) begin
                parity_bit = parity_bit;  
            end
            if (PARITY_TYPE == 2) begin
                parity_bit = ~parity_bit;
            end
        end
    end

    // FSM next state logic
    always_comb begin : fsm_next_state
        case (current_state)
            IDLE:       next_state = (valid) ? START_BIT : IDLE;  // Wait for valid data
            START_BIT:  next_state = (clk_en) ? DATA_BITS : START_BIT;
            DATA_BITS:  next_state = (clk_en && (bit_n == BITS_N-1)) ?
                                     (PARITY_TYPE == 0 ? STOP_BIT : PARITY_BIT) : DATA_BITS;
            PARITY_BIT: next_state = (clk_en) ? STOP_BIT : PARITY_BIT;  // Transmit parity bit if enabled
            STOP_BIT:   next_state = (clk_en) ? IDLE : STOP_BIT;  // Return to IDLE after stop bit
            default:    next_state = IDLE;
        endcase
    end

    // FSM sequential logic
always_ff @(posedge clk) begin
    if (rst) begin
        current_state <= IDLE;
        data_tx_temp <= 0;
        bit_n <= 0;
    end else begin
        current_state <= next_state;  // Move to the next state regardless of clk_en
        //if (clk_en) begin
            case (current_state)
                IDLE: begin
                    data_tx_temp <= data_tx;  // Load data for transmission
                    bit_n <= 0;               // Reset bit index at the start
                end
                DATA_BITS: begin
                    if ((bit_n < BITS_N) && (clk_en)) begin
                        bit_n <= bit_n + 1'b1;  // Increment bit index after transmitting the bit
                    end
                end
            endcase
        //end
    end
end



always_comb begin : fsm_output
    uart_out = 1'b1;  // Default UART line idle
    ready = 1'b0;     // Default not ready
    case (current_state)
        IDLE: begin
            ready = 1'b1;  // Ready for new data
            uart_out = 1'b1;  // Idle state (high)
        end
        START_BIT: begin
            //ready = 1'b0;
            uart_out = 1'b0;  // Start bit (low)
        end
        DATA_BITS: begin
            //ready = 1'b0;
            uart_out = data_tx_temp[bit_n];  // Transmit the current data bit
        end
        PARITY_BIT: begin
            //ready = 1'b0;
            uart_out = parity_bit;  // Transmit parity bit
        end
        STOP_BIT: begin
            //ready = 1'b0;
            uart_out = 1'b1;  // Stop bit (high)
        end
    endcase
end


   
endmodule

