`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        
// 
// Create Date:     05/05/2019 00:19 AM
// Design Name:     EE3 lab1
// Module Name:     Counter
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool versions:   Vivado 2016.4
// Description:     a counter that advances its reading as long as time_reading 
//                  signal is high and zeroes its reading upon init_regs=1 input.
//                  the time_reading output represents: 
//                  {dekaseconds,seconds}
// Dependencies:    Lim_Inc
//
// Revision         3.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Counter(clk, init_regs, count_enabled, time_reading);

   parameter CLK_FREQ = 100000000; // 100MHz default 
   
   input clk, init_regs, count_enabled;
   output [7:0] time_reading;

   // 1. Registers: These store the actual state (count)
   reg [$clog2(CLK_FREQ)-1:0] clk_cnt = 0; //INIT ADDED HERE
   reg [3:0] ones_seconds = 0;    //INIT ADDED HERE
   reg [3:0] tens_seconds = 0;   //INIT ADDED HERE
  
   // 2. Wires: These carry the "Next State" calculation from Lim_Inc
   wire [$clog2(CLK_FREQ)-1:0] next_clk_cnt;
   wire [3:0] next_ones, next_tens;
   wire tick_1hz, tick_01hz, co_out;   
   
   // 3. Instance: Clock Divider (100MHz -> 1Hz)
   Lim_Inc #(CLK_FREQ) div_1hz (
        .a(clk_cnt),
        .ci(count_enabled),
        .sum(next_clk_cnt),
        .co(tick_1hz)
    );

   // 4. Instance: Seconds Counter (0-9)
   Lim_Inc #(10) units_cnt (
        .a(ones_seconds),
        .ci(tick_1hz),
        .sum(next_ones),
        .co(tick_01hz)
    );

   // 5. Instance: Deca-seconds Counter (10s, 0-9)
   Lim_Inc #(10) tens_cnt (
       .a(tens_seconds), 
       .ci(tick_01hz), 
       .sum(next_tens), 
       .co(co_out)
   );

   // 6. Synchronous Update Logic
   always @(posedge clk) begin
        if (init_regs) begin
            clk_cnt      <= 0;
            ones_seconds <= 0;
            tens_seconds <= 0;
        end else begin
            clk_cnt      <= next_clk_cnt;
            ones_seconds <= next_ones;
            tens_seconds <= next_tens;
        end
    end

    assign time_reading = {tens_seconds, ones_seconds}; 

endmodule
