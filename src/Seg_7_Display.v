`timescale 1ns / 1ps

/**
 * Module: Seg_7_Display
 * Description: Drives a 4-digit 7-segment display using time-multiplexing logic.
 * The display operates on a 100MHz clock and selects digits at a frequency 
 * visible to the human eye without flickering.
 */
module Seg_7_Display(
    input clk,             // 100MHz System Clock
    input [15:0] x,        // 4 BCD digits to display (4 bits each)
    output reg [6:0] seg,  // a-g segments (Active Low: 0 = ON, 1 = OFF)
    output reg [3:0] an,   // Anodes for 4 digits (Active Low: 0 = ON, 1 = OFF)
    output wire dp         // Decimal point
    );

    // Decimal point is permanently disabled (Active Low logic: 1 = OFF)
    assign dp = 1'b1;

    /**
     * Refresh Counter Initialization:
     * Initializing the counter to 0 is essential for simulation to avoid 
     * 'X' (unknown) states in the logic chain.
     */
    reg [17:0] refresh_counter = 0; 
    
    /**
     * Refresh Frequency Calculation:
     * Using bits [17:16] to switch between digits.
     * With a 100MHz clock, the refresh rate per digit is 100MHz / 2^16.
     * The total refresh cycle for all 4 digits is 100MHz / 2^18 = ~381Hz (approx 2.62ms).
     * This falls within the recommended 1ms - 16ms range.
     */
    wire [1:0] active_digit = refresh_counter[17:16]; 
    reg [3:0] digit_to_show;

    // Increment the counter on every clock rising edge
    always @(posedge clk) begin
        refresh_counter <= refresh_counter + 1;
    end

    /**
     * Anode Selection Logic (Multiplexing):
     * Determines which physical digit is currently ON and passes the 
     * corresponding 4 bits from 'x' to the segment decoder.
     */
    always @(*) begin
        case(active_digit)
            2'b00: begin 
                an = 4'b1110;           // Activate Digit 0 (Rightmost)
                digit_to_show = x[3:0]; 
            end
            2'b01: begin 
                an = 4'b1101;           // Activate Digit 1
                digit_to_show = x[7:4]; 
            end
            2'b10: begin 
                an = 4'b1011;           // Activate Digit 2
                digit_to_show = x[11:8]; 
            end
            2'b11: begin 
                an = 4'b0111;           // Activate Digit 3 (Leftmost)
                digit_to_show = x[15:12]; 
            end
            default: begin 
                an = 4'b1111;           // All digits OFF
                digit_to_show = 4'h0; 
            end
        endcase
    end

    /**
     * BCD to 7-Segment Decoder:
     * Converts a 4-bit hex/BCD value into the standard 7-segment pattern.
     * Logic is Active Low: 0 means the segment is lit.
     */
    always @(*) begin
        case(digit_to_show)
            // Segments: abcdefg//internal decoder 7seg
            4'h0: seg = 7'b1000000; 
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100; 
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001; 
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010; 
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000; 
            4'h9: seg = 7'b0010000;
            default: seg = 7'b1111111; // All segments OFF
        endcase
    end
    
endmodule