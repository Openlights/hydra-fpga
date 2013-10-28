/**
 * Hydra - An open source strand lighting controller
 * (c) 2013-2014 Jon Evans <jon@craftyjon.com>
 * Released under the MIT License -- see LICENSE.txt for details.
 *
 * address_generator.v - Memory address generator module
 */
 
 `timescale 1ns / 1ps


module address_generator_tb;

    parameter MEM_ADDR_WIDTH = 24;

    reg clk = 0;
    reg rst_n = 1;

    wire [MEM_ADDR_WIDTH-1:0] addr;

    // UUT
    address_generator #(MEM_ADDR_WIDTH) ag_inst (
            .clk(clk),
            .rst_n(rst_n),
            .addr(addr)
        );

    // Clock process
    always #10 clk = !clk;


    initial begin

        $dumpfile("address_generator_tb.vcd");
        $dumpvars(0, address_generator_tb);

        #10 rst_n = 0;
        #10 rst_n = 1;

        #500 $finish;
    end


endmodule
