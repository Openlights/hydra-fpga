/**
 * Hydra - An open source strand lighting controller
 * (c) 2013-2014 Jon Evans <jon@craftyjon.com>
 * Released under the MIT License -- see LICENSE.txt for details.
 *
 * strand_driver.v - WS2801/WS2811 driver state machine
 *
 * Input clock is assumed to be 100 MHz, giving the following timings:
 * WS2811 T0H = 50, T0L = 200, T1H = 120, T1L = 130
 *
 * 
 * 
 */
 

  module strand_driver (
    clk,
    rst_n,
    ws2811_mode,
    strand_length,
    current_idx,
    mem_data,
    start_frame,
    busy,
    done,
    strand_clk,
    strand_data
    );

    parameter MEM_DATA_WIDTH = 24;
    parameter STRAND_PARAM_WIDTH = 16;

    input clk;
    input rst_n;

    // Parameter inputs (from registers)
    input ws2811_mode;
    input [STRAND_PARAM_WIDTH-1:0] strand_length;

    // Current pixel index (used to control the pixel RAM)
    output reg [STRAND_PARAM_WIDTH-1:0] current_idx;

    // Data in from the pixel RAM
    input [MEM_DATA_WIDTH-1:0] mem_data;

    // Toggle high to begin the state machine
    input start_frame;

    // Control outputs
    output reg busy;
    output reg done;

    // Outputs to IOB
    output reg strand_clk;
    output reg strand_data;

    // Locals
    reg [7:0] counter;
    reg [7:0] bit_position;
    reg [2:0] current_state;
    reg [2:0] next_state;
    reg [MEM_DATA_WIDTH-1:0] current_data;

    // FSM
    localparam  STATE_IDLE = 3'b000,
                STATE_START = 3'b001,
                STATE_UNPACK = 3'b010,
                STATE_DECODE_1 = 3'b011,
                STATE_DECODE_2 = 3'b100;

    // Output timing
    localparam  T1H = 8'd12,  // WS2811 1-bit high period
                T1L = 8'd13,
                T0H = 8'd5,
                T0L = 8'd20,
                TRESET = 8'd255,
                TCLKDIV2 = 8'd1;

    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            current_idx <= { STRAND_PARAM_WIDTH {1'b0} };
            busy <= 1'b0;
            done <= 1'b0;
            strand_clk <= 1'b0;
            strand_data <= 1'b0;
            counter <= {8 {1'b0} };
            bit_position <= {8 {1'b0} };
            current_state <= STATE_IDLE;
        end
        else begin
            current_state <= next_state;

            // Decrement frame counter
            if (counter > 0) begin
                counter <= counter - 1;
            end
            else if (counter == 0) begin
                if (bit_position == 8'd23) begin
                    current_idx <= current_idx + 1;
                end
                else begin
                    bit_position <= bit_position + 1;
                end                                
            end

            
            if (current_state == STATE_UNPACK) begin
                // Reset the bit position counter at the beginning of each word
                bit_position <= {8 {1'b0} };

                // Latch the new data word
                current_data <= mem_data;
            end
        end
    end

    always @(counter, start_frame, current_idx) begin
        next_state = current_state;
        case (current_state)
            STATE_IDLE: begin
                // Start transmission
                if (start_frame == 1'b1) begin
                    next_state = STATE_START;
                    busy = 1'b1;
                    current_idx = { STRAND_PARAM_WIDTH {1'b0} };
                    bit_position = {8 {1'b0} };
                end
            end
            STATE_START: begin
                // Perform any one-time initialization
                // TODO: does this need to exist?
                next_state = STATE_UNPACK;
            end
            STATE_UNPACK: begin
                // Grab the next pixel word
                if (current_idx < strand_length) begin
                    next_state = STATE_DECODE_1;
                end else begin
                    next_state = STATE_IDLE;
                end
            end
            STATE_DECODE_1: begin
                // First output phase.
                // WS2811? D <= 1, T <= (bit==1) ? T1H : T0H
                // WS2812? D <= bit, C <= 0, T <= TCLKDIV2
                
            end
            STATE_DECODE_2: begin
                // Second output phase.
                // WS2811? D <= 0, T <= (bit==1) ? T1L: T0L
                // WS2812? C <= 0, T <= TCLKDIV2
                

                // Advance the bit index
                if (bit_position < 8'd23) begin
                    next_state <= STATE_DECODE_1;
                end else begin
                    next_state <= STATE_UNPACK;
                end
            end
        endcase
    end

 endmodule
