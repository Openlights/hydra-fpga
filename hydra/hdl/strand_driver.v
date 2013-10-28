/**
 * Hydra - An open source strand lighting controller
 * (c) 2013-2014 Jon Evans <jon@craftyjon.com>
 * Released under the MIT License -- see LICENSE.txt for details.
 *
 * strand_driver.v - WS2801/WS2811 driver state machine
 */
 

  module strand_driver (
    clk,
    rst_n,
    current_idx,
    mem_data
    );

    parameter MEM_DATA_WIDTH = 24;
    parameter STRAND_PARAM_WIDTH = 16;

    input clk;
    input rst_n;
    output reg [STRAND_PARAM_WIDTH-1:0] current_idx;
    input [MEM_DATA_WIDTH-1:0] mem_data;

    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            
        end
        else begin
            
        end
    end

 endmodule
