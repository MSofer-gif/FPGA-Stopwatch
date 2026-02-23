`timescale 1ns/10ps

/**
 * Module: tb_Stopwatch
 * Purpose: Comprehensive verification of the final Stopwatch system.
 */
module tb_Stopwatch();

    // Inputs (Reg)
    reg clk;
    reg btnC, btnU, btnR, btnL, btnD;

    // Outputs (Wire)
    wire [6:0] seg;
    wire [3:0] an;
    wire dp;
    wire [2:0] led_left, led_right;

    // Instantiate UUT (Unit Under Test)
    Stopwatch uut (
        .clk(clk), 
        .btnC(btnC), 
        .btnU(btnU), 
        .btnR(btnR), 
        .btnL(btnL), 
        .btnD(btnD),
        .seg(seg), 
        .an(an), 
        .dp(dp), 
        .led_left(led_left), 
        .led_right(led_right)
    );

    // --- Clock Generation (Fixed for Warnings) ---
    // Initial value for clk fixes "not set" warning
    initial clk = 0; 
    // Using 'always' instead of 'forever' inside 'initial' to avoid loop limit warnings
    always #5 clk = ~clk; 

    // --- Stimulus Process ---
    initial begin
        // Initialize all inputs
        btnC = 0; btnU = 0; btnR = 0; btnL = 0; btnD = 0;
        
        // Wait for global reset
        #100;
        
        // --- Step 1: System Reset ---
        $display("Applying Reset...");
        btnC = 1; #200; btnC = 0; #200;

        // --- Step 2: Start Stopwatch (btnU) ---
        $display("Starting Stopwatch...");
        btnU = 1; #200; btnU = 0;
        #5000; 

        // --- Step 3: Test Split (btnR) ---
        $display("Activating Split/Freeze on left digits...");
        btnR = 1; #200; btnR = 0;
        #5000; 

        // --- Step 4: Sample time into Stash (btnD) ---
        $display("Sampling real time into Stash...");
        btnD = 1; #200; btnD = 0;
        #1000;

        // --- Step 5: Stop/Pause (btnU) ---
        $display("Pausing - Should release Split snapshot...");
        btnU = 1; #200; btnU = 0;
        #2000;

        // --- Step 6: Toggle Control to Stash Mode (btnL) ---
        $display("Toggling control mode to Stash...");
        btnL = 1; #200; btnL = 0;
        #1000;

        // --- Step 7: Test Next Sample (btnU in Stash Mode) ---
        $display("Testing next_sample navigation in Stash...");
        btnU = 1; #200; btnU = 0;
        #2000;

        // --- Step 8: Final Reset ---
        btnC = 1; #200; btnC = 0;

        $display("Simulation Finished Successfully");
        #100;
        $finish; // Use $finish to end simulation properly
    end

endmodule