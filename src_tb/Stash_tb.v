`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        Leo Segre
// 
// Create Date:     05/05/2019 02:59:38 AM
// Design Name:     EE3 lab1
// Module Name:     Stash_tb
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool versions:   Vivado 2016.4
// Description:     test bennch for the stash.
// Dependencies:    None
//
// Revision: 		1.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Stash_tb();

    reg clk, reset, sample_in_valid, next_sample, correct, loop_was_skipped;
    reg [7:0] sample_in;
    wire [7:0] sample_out;
    integer i, j;
    

    Stash #(.DEPTH(5)) uut (
        .clk(clk),
        .reset(reset),
        .sample_in(sample_in),
        .sample_in_valid(sample_in_valid),
        .next_sample(next_sample),
        .sample_out(sample_out)
    );
    
    initial begin
        // Initialize
        correct = 1;
        clk = 0; 
        reset = 1; 
        loop_was_skipped = 1;
        sample_in = 8'b0;
        sample_in_valid = 0;
        next_sample = 0;
        
        // Apply reset
        #15 reset = 0;
                // Test basic cases
        for (i = 0; i < 2; i = i + 1) begin
            // Write
            sample_in = 8'h10 + i;
            sample_in_valid = 1;
            next_sample = 0;
            #10;
            if (sample_out != sample_in) correct = 0;
            sample_in_valid = 0;
            
            // Read next
            next_sample = 1;
            #10;
            next_sample = 0;
            
            // Idle
            #10;
        end
        
        // Test rollover
        reset = 1;
        #10 reset = 0;
        
        // Fill memory
        for (j = 0; j < 5; j = j + 1) begin
            sample_in = 8'h30 + j;
            sample_in_valid = 1;
            #10;
            sample_in_valid = 0;
            #10;
        end
        
        // Press next_sample 5 times + 1 more for rollover check
        for (j = 0; j < 6; j = j + 1) begin
            next_sample = 1;
            #10;
            next_sample = 0;
            #10;
        end
        
        // The 6th next_sample should wrap to first address
        
        #5 
        
        if (correct && ~loop_was_skipped)
            $display("Test Passed - %m");
        else
            $display("Test Failed - %m");
        $finish;
    end
    
    // Clock generator (100 MHz -> 10ns period)
    always #5 clk = ~clk;
    
endmodule
