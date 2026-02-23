`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        Leo Segre
// 
// Create Date:     05/05/2019 00:19 AM
// Design Name:     EE3 lab1
// Module Name:     Stash
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool versions:   Vivado 2016.4
// Description:     a Stash that stores all the samples in order upon sample_in and sample_in_valid.
//                  It exposes the chosen sample by sample_out and the exposed sample can be changed by next_sample. 
// Dependencies:    Lim_Inc
//
// Revision         1.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Stash(clk, reset, sample_in, sample_in_valid, next_sample, sample_out);

   parameter DEPTH = 5;
   
   input clk, reset, sample_in_valid, next_sample;
   input [7:0] sample_in;
   output [7:0] sample_out;
  
   // Local parameters
   localparam N = ($clog2(DEPTH) > 0) ? $clog2(DEPTH) : 1;
   
   // Registers
   reg [N-1:0] write_ptr;
   reg [N-1:0] read_ptr;
   reg [7:0] mem [0:DEPTH-1];
   
   // Wires
   wire [N-1:0] next_write_ptr;
   wire [N-1:0] next_read_ptr;
   wire write_co, read_co;
   
   // Memory output
   wire [7:0] mem_out = mem[read_ptr];
   
   // Lim_Inc instances
   Lim_Inc #(.L(DEPTH)) write_inc (
      .a(write_ptr),
      .ci(sample_in_valid),
      .sum(next_write_ptr),
      .co(write_co)
   );
   
   Lim_Inc #(.L(DEPTH)) read_inc (
      .a(read_ptr),
      .ci(next_sample),
      .sum(next_read_ptr),
      .co(read_co)
   );
   
   // Sequential logic
   integer i;
   always @(posedge clk or posedge reset) begin
      if (reset) begin
         write_ptr <= 0;
         read_ptr <= 0;
         for (i = 0; i < DEPTH; i = i + 1) mem[i] <= 0;
      end else begin
         if (sample_in_valid) begin
            mem[write_ptr] <= sample_in;
            write_ptr <= next_write_ptr;
         end
         if (next_sample) begin
            read_ptr <= next_read_ptr;
         end
      end
   end
   
   // Output MUX
   assign sample_out = sample_in_valid ? sample_in : mem_out;

endmodule
