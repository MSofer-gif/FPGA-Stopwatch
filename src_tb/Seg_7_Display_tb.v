`timescale 1ns / 1ps

/**
 * Module: tb_Seg_7_Display
 * Purpose: Testbench for the 7-segment display module.
 * Verifies the multiplexing logic and BCD to 7-segment decoding.
 */
module tb_Seg_7_Display();
    // Testbench signals
    reg clk;
    reg [15:0] x;
    wire [6:0] seg;
    wire [3:0] an;
    wire dp;

    // Unit Under Test (UUT) Instantiation
    Seg_7_Display uut (
        .clk(clk),
        .x(x),
        .seg(seg),
        .an(an),
        .dp(dp)
    );

    // Clock Generation: 100MHz (10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus process
    initial begin
        // Case 1: Displaying 1234
        x = 16'h1234;  
        
        // Wait at least 5ms to see a full refresh cycle (All 4 digits)
        // Calculated refresh cycle is ~2.62ms for clkdiv[17:16]
        #5000000;         
        
        // Case 2: Change number to 5678 to verify data updates
        x = 16'h5678;
        #5000000;         
        
        $display("7-Segment Simulation Finished");
        $stop;
    end
endmodule