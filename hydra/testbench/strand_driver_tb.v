/**
 * Hydra - An open source strand lighting controller
 * (c) 2013-2014 Jon Evans <jon@craftyjon.com>
 * Released under the MIT License -- see LICENSE.txt for details.
 *
 * strand_driver_tb.v - Testbench for WS2801/WS2811 driver state machine
 */
 
 `timescale 1ns / 1ps


module strand_driver_tb;

    reg clk = 0;
    reg rst_n = 1;

    // UUT
    strand_driver #(MEM_ADDR_WIDTH) sd_inst (
            .clk(clk),
            .rst_n(rst_n),
            .current_idx(strand_offset),
            .mem_data(mem_data)
        );

    // Clock process
    always #10 clk = !clk;

    // Test process
    initial begin

        $dumpfile("strand_driver_tb.vcd");
        $dumpvars(0, strand_driver_tb);

        #10 rst_n = 0;
        #10 rst_n = 1;

        #500 $finish;
    end

endmodule
