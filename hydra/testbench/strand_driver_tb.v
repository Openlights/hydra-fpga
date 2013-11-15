/**
 * Hydra - An open source strand lighting controller
 * (c) 2013-2014 Jon Evans <jon@craftyjon.com>
 * Released under the MIT License -- see LICENSE.txt for details.
 *
 * strand_driver_tb.v - Testbench for WS2801/WS2811 driver state machine
 */
 
 `timescale 1ns / 1ps


module strand_driver_tb;

    parameter MEM_DATA_WIDTH = 24;
    parameter STRAND_PARAM_WIDTH = 16;

    reg clk = 0;
    reg rst_n = 1;

    reg ws2811_mode = 1;
    reg start_frame = 0;

    reg [STRAND_PARAM_WIDTH-1:0] strand_length = 160;

    wire [STRAND_PARAM_WIDTH-1:0] current_idx;
    reg [MEM_DATA_WIDTH-1:0] mem_data = 24'hFF0055;

    wire busy;
    wire done;

    wire strand_clk;
    wire strand_data;

    // UUT
    strand_driver sd_inst (
            .clk(clk),
            .rst_n(rst_n),
            .ws2811_mode(ws2811_mode),
            .strand_length(strand_length),
            .current_idx(current_idx),
            .mem_data(mem_data),
            .start_frame(start_frame),
            .busy(busy),
            .done(done),
            .strand_clk(strand_clk),
            .strand_data(strand_data)
        );

    // Clock process
    always #10 clk = !clk;

    // Test process
    initial begin

        $dumpfile("strand_driver_tb.vcd");
        $dumpvars(0, strand_driver_tb);

        #10 rst_n = 0;
        #10 rst_n = 1;
        #10 start_frame = 1;
        #10 start_frame = 0;

        #500 $finish;
    end

endmodule
