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
    reg [7:0] counter_preset;
    reg [7:0] bit_position;
    reg [2:0] current_state;
    reg [2:0] next_state;
    reg [MEM_DATA_WIDTH-1:0] current_data;
    reg strand_clk_i;
    reg strand_data_i;
    reg busy_i;
    reg [7:0] bit_position_i;
    reg [STRAND_PARAM_WIDTH-1:0] current_idx_i;
    reg counter_set_i;
    reg counter_running;

    wire words_to_decode;
    wire current_bit;

    // FSM
    localparam  STATE_IDLE = 3'b000,
                STATE_START = 3'b001,
                STATE_UNPACK = 3'b010,
                STATE_DECODE_1 = 3'b011,
                STATE_DECODE_2 = 3'b100;

    // Output timing
    localparam  T1H = 8'd120,  // WS2811 1-bit high period
                T1L = 8'd130,
                T0H = 8'd50,
                T0L = 8'd200,
                TRESET = 8'd255,
                TCLKDIV2 = 8'd10;

    // State machine
    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            current_idx <= { STRAND_PARAM_WIDTH {1'b0} };
            current_data <= { MEM_DATA_WIDTH {1'b0} };
            busy <= 1'b0;
            done <= 1'b0;
            strand_clk <= 1'b0;
            strand_data <= 1'b0;
            counter <= {8 {1'b0} };
            bit_position <= {8 {1'b0} };
            current_state <= STATE_IDLE;
            counter_running <= 1'b0;
        end
        else begin
            busy <= busy_i;
            bit_position <= bit_position_i;
            current_idx <= current_idx_i;

            strand_clk <= strand_clk_i;
            strand_data <= strand_data_i;
            
            // Latch the new data word
            if (current_state == STATE_UNPACK) begin
                current_data <= mem_data;
            end

            // Manage the timing counter
            if (counter_set_i == 1'b1) begin
                counter <= counter_preset;
                counter_running <= 1'b1;
            end else begin
                if (counter > 0) begin
                    counter <= counter - 1;
                end else begin
                    counter_running <= 1'b0;
                end
            end

            current_state <= next_state;
        end
    end

    assign words_to_decode = (current_idx < strand_length);
    assign current_bit = mem_data[bit_position];

    // Next state process
    always @(*) begin
        next_state = current_state;
        strand_data_i = strand_data;
        strand_clk_i = strand_clk;
        counter_preset = counter;
        busy_i = busy;
        bit_position_i = bit_position;
        current_idx_i = current_idx;

        case (current_state)
            STATE_IDLE: begin
                // Start transmission
                if (start_frame == 1'b1) begin
                    next_state = STATE_START;
                    busy_i = 1'b1;
                    current_idx_i = { STRAND_PARAM_WIDTH {1'b0} };
                    bit_position_i = {8 {1'b0} };
                end
            end
            STATE_START: begin
                // Perform any one-time initialization
                // TODO: does this need to exist?
                current_idx_i = { STRAND_PARAM_WIDTH {1'b0} };
                next_state = STATE_UNPACK;
            end
            STATE_UNPACK: begin
                // Grab the next pixel word
                if (words_to_decode == 1'b1) begin
                    next_state = STATE_DECODE_1;
                end else begin
                    next_state = STATE_IDLE;
                    busy_i = 0;
                end

                // Reset the bit position counter at the beginning of each word
                bit_position = {8 {1'b0} };
            end
            STATE_DECODE_1: begin
                // First output phase.
                if (ws2811_mode == 1'b1) begin
                    // WS2811? D <= 1, T <= (bit==1) ? T1H : T0H
                    if (current_bit == 1'b1) begin
                        counter_preset = T1H;
                    end else begin
                        counter_preset = T0H;
                    end
                    strand_data_i = 1'b1;
                end else begin
                    // WS2812? D <= bit, C <= 0, T <= TCLKDIV2
                    strand_data_i = mem_data[bit_position];
                    strand_clk_i = 1'b0;
                    counter_preset = TCLKDIV2;
                end

                counter_set_i = !counter_running;

                if (counter == 0 && counter_running) begin
                    next_state = STATE_DECODE_2;
                end
            end
            STATE_DECODE_2: begin
                // Second output phase.
                // WS2811? D <= 0, T <= (bit==1) ? T1L: T0L
                // WS2812? C <= 0, T <= TCLKDIV2
                if (ws2811_mode == 1'b1) begin
                    if (mem_data[bit_position] == 1'b1) begin
                        counter_preset = T1L;
                    end else begin
                        counter_preset = T0L;
                    end
                    strand_data_i = 1'b0;
                end else begin
                    // Toggle the clock high; data remains the same
                    strand_data_i = strand_data;
                    strand_clk_i = 1'b1;
                    counter_preset = TCLKDIV2;
                end

                // Advance the bit index
                if (counter == 0 && counter_running) begin
                    if (bit_position < 8'd23) begin
                        next_state = STATE_DECODE_1;
                        bit_position_i = bit_position + 1;
                    end else begin
                        next_state = STATE_UNPACK;
                        current_idx_i = current_idx + 1;
                    end
                end

                counter_set_i = !counter_running;
            end
        endcase
    end

 endmodule
