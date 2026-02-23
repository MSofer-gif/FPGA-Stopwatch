`timescale 1ns / 1ps

module Debouncer(
    input clk,               // 100MHz clock from Basys3
    input input_unstable,    // Raw signal from the push-button
    output reg output_stable // Clean pulse (1 clock cycle long)
    );

    parameter COUNTER_BITS = 16; // Time constant for stability
    reg [COUNTER_BITS-1:0] counter = 0; //INIT ADDED HERE
    reg state = 0 ;               // Current stable logic level //INIT ADDED HERE
    reg last_state = 0;          // Previous state to detect rising edge //INIT ADDED HERE

    always @(posedge clk) begin
        // Hysteresis counter logic
        if (input_unstable == 1) begin
            if (counter < {COUNTER_BITS{1'b1}}) counter <= counter + 1;
        end else begin
            if (counter > 0) counter <= counter - 1;
        end

        // Threshold detection for stable state
        if (counter == {COUNTER_BITS{1'b1}}) state <= 1'b1;
        else if (counter == 0) state <= 1'b0;

        // One-shot pulse generation (rising edge detector)
        last_state <= state;
        output_stable <= (state == 1'b1 && last_state == 1'b0);
    end
endmodule