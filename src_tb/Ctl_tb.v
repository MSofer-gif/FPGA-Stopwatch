`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        
// 
// Create Date:     05/05/2019 02:59:38 AM
// Design Name:     EE3 lab1
// Module Name:     Ctl_tb
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool versions:   Vivado 2016.4
// Description:     test bennch for the control.
// Dependencies:    None
//
// Revision: 		3.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Ctl_tb();

    reg clk, reset, trig, split, correct;
    wire init_regs, count_enabled;
    integer test_num;
    
    Ctl uut (clk, reset, trig, split, init_regs, count_enabled);
    
    initial begin
        correct = 1;
        clk = 0; reset = 1; trig = 0; split = 0;
                test_num = 0;
        
        // ========== TEST 1: Basic Reset ==========
        test_num = 1;
        reset = 1; trig = 0; split = 0;
        #20; // Wait for reset to propagate
        
        if (!(init_regs == 1'b1 && count_enabled == 1'b0)) begin
            correct = 0;
            $display("Test %0d FAILED: Reset not in IDLE", test_num);
        end
        
        // ========== TEST 2: IDLE -> COUNTING ==========
        test_num = 2;
        reset = 0; // Release reset
        #10;
        trig = 1; // Pulse trig
        #10;
        trig = 0;
        #10; // Wait for state update
        
        if (!(init_regs == 1'b0 && count_enabled == 1'b1)) begin
            correct = 0;
            $display("Test %0d FAILED: IDLE -> COUNTING", test_num);
        end
        
        // ========== TEST 3: COUNTING -> PAUSED ==========
        test_num = 3;
        #10;
        trig = 1; // Pulse trig
        #10;
        trig = 0;
        #10;
        
        if (!(init_regs == 1'b0 && count_enabled == 1'b0)) begin
            correct = 0;
            $display("Test %0d FAILED: COUNTING -> PAUSED", test_num);
        end
        
        // ========== TEST 4: PAUSED -> COUNTING ==========
        test_num = 4;
        #10;
        trig = 1; // Pulse trig
        #10;
        trig = 0;
        #10;
        
        if (!(init_regs == 1'b0 && count_enabled == 1'b1)) begin
            correct = 0;
            $display("Test %0d FAILED: PAUSED -> COUNTING", test_num);
        end
        
        // ========== TEST 5: COUNTING stays COUNTING ==========
        test_num = 5;
        #20; // Keep trig=0 for 2 cycles
        
        if (!(init_regs == 1'b0 && count_enabled == 1'b1)) begin
            correct = 0;
            $display("Test %0d FAILED: COUNTING should stay COUNTING", test_num);
        end
        
        // ========== TEST 6: Reset from COUNTING ==========
        test_num = 6;
        #10;
        reset = 1; // Assert reset
        #10;
        reset = 0; // Release reset
        #10;
        
        if (!(init_regs == 1'b1 && count_enabled == 1'b0)) begin
            correct = 0;
            $display("Test %0d FAILED: Reset from COUNTING", test_num);
        end
        
        // ========== TEST 7: PAUSED -> IDLE via split ==========
        test_num = 7;
        // First go to PAUSED: IDLE -> COUNTING -> PAUSED
        #10;
        trig = 1; #10; trig = 0; #10; // IDLE -> COUNTING
        trig = 1; #10; trig = 0; #10; // COUNTING -> PAUSED
        
        // Now test split: PAUSED -> IDLE
        #10;
        split = 1; // Assert split
        #10;
        split = 0; // Release split
        #10;
        
        if (!(init_regs == 1'b1 && count_enabled == 1'b0)) begin
            correct = 0;
            $display("Test %0d FAILED: PAUSED -> IDLE via split", test_num);
        end
        
        // ========== TEST 8: PAUSED stays PAUSED ==========
        test_num = 8;
        // Go to PAUSED: IDLE -> COUNTING -> PAUSED
        #10;
        trig = 1; #10; trig = 0; #10; // IDLE -> COUNTING
        trig = 1; #10; trig = 0; #10; // COUNTING -> PAUSED
        
        // Keep trig=0, split=0 for 2 cycles
        #20;
        
        if (!(init_regs == 1'b0 && count_enabled == 1'b0)) begin
            correct = 0;
            $display("Test %0d FAILED: PAUSED should stay PAUSED", test_num);
        end
        
        #10;
        
        if (correct)
            $display("Test Passed - %m");
        else
            $display("Test Failed - %m");
        $finish;
    end
    
    always #5 clk = ~clk;
    
endmodule
