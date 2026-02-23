`timescale 1 ns / 1 ns
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        
// 
// Create Date:     00:00:00  AM 05/05/2019 
// Design Name:     EE3 lab1
// Module Name:     Counter_tb
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool versions:   Vivado 2016.4
// Description:     test bench for Counter module
// Dependencies:    Counter
//
// Revision:        3.0
// Revision:        3.1 - changed  9999999 to 99999999 for a proper, 1sec delay, 
//                        in the inner test loop.
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Counter_tb();

    reg clk, init_regs, count_enabled, correct, loop_was_skipped;
    wire [7:0] time_reading;
    wire [3:0] tens_seconds_wire;
    wire [3:0] ones_seconds_wire;
    integer ts, os;
    
    // Instantiate UUT
    Counter #(100000000) uut (
        .clk(clk),
        .init_regs(init_regs),
        .count_enabled(count_enabled),
        .time_reading(time_reading)
    );
    
    assign tens_seconds_wire = time_reading[7:4];
    assign ones_seconds_wire = time_reading[3:0];
    
     initial begin
        correct = 1;
        loop_was_skipped = 1;
        clk = 1;
        init_regs = 1;
        count_enabled = 0;

        #25; // Initialize
        init_regs = 0;
        count_enabled = 1;

        for (ts = 0; ts < 2; ts = ts + 1) begin
            for (os = 0; os < 10; os = os + 1) begin

                #(1000000000 - 10);

                if (ones_seconds_wire !== os || tens_seconds_wire !== ts) begin
                    $display("FAIL at %t: Expected %d%d, Got %h", 
                             $time, ts, os, time_reading);
                    correct = 0;
                end

                #10; 
                loop_was_skipped = 0;
            end
        end
        
        #100;
        if (correct && ~loop_was_skipped)
            $display("SUCCESS: Test Passed - %m");
        else
            $display("FAILURE: Test Failed - %m");
        $finish;
    end
    
    always #5 clk = ~clk;

endmodule
