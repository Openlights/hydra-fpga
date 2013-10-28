/**
 * Hydra - An open source strand lighting controller
 * (c) 2013-2014 Jon Evans <jon@craftyjon.com>
 * Released under the MIT License -- see LICENSE.txt for details.
 *
 * address_generator.v - Memory address generator module
 */
 
 `timescale 1ns / 1ps


 module address_generator (
    clk,
    rst_n,

    addr
    );

    parameter MEM_ADDR_WIDTH = 24;

    input clk;
    input rst_n;

    output reg [MEM_ADDR_WIDTH-1:0] addr;

    // Address generation process
    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            // initialize stuff
            addr = { MEM_ADDR_WIDTH {1'b0} };
        end
        else begin
            // normal operation
            
            // address of memory is given by 
            // (strand_offset[current] + strand_idx[current]) % strand_length[current]
        end
    end

 endmodule