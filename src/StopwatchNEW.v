`timescale 1ns/10ps

module Stopwatch(
    input clk,              // 100MHz clock from W5 pin
    input btnC,             // Center button: System Reset
    input btnU,             // Upper button: Start/Pause OR Next_Sample
    input btnR,             // Right button: Split (Freeze display)
    input btnL,             // Left button: Toggle Control (Stopwatch/Stash)
    input btnD,             // Bottom button: Sample current time into Stash
    output [6:0] seg,       // 7-segment patterns
    output [3:0] an,        // Anode control
    output dp,              // Decimal point
    output [2:0] led_left,  // LED indication for Stopwatch control
    output [2:0] led_right  // LED indication for Stash control
    );

    // Internal Wires for Debounced Buttons
    wire reset_p, trig_p, split_p, toggle_p, sample_p;
    
    // Internal Signals
    wire init_regs, count_enabled;
    wire [7:0] current_time;
    wire [7:0] stashed_time;
    
    // Registers for Split and Control Management
    reg [7:0] snapshot_reg = 0; 
    reg split_active = 0;
    reg control_mode = 0; // 0: Stopwatch control, 1: Stash control

    // 1. Debouncers: Required for all user buttons (Task 9)
    // Updated to COUNTER_BITS(16) as requested
    Debouncer #(.COUNTER_BITS(16)) db_reset (.clk(clk), .input_unstable(btnC), .output_stable(reset_p));
    Debouncer #(.COUNTER_BITS(16)) db_trig  (.clk(clk), .input_unstable(btnU), .output_stable(trig_p));
    Debouncer #(.COUNTER_BITS(16)) db_split (.clk(clk), .input_unstable(btnR), .output_stable(split_p));
    Debouncer #(.COUNTER_BITS(16)) db_toggle(.clk(clk), .input_unstable(btnL), .output_stable(toggle_p));
    Debouncer #(.COUNTER_BITS(16)) db_sample(.clk(clk), .input_unstable(btnD), .output_stable(sample_p));

    // 2. Control Unit (FSM): Governs counting states (Task 6)
    Ctl controller (
        .clk(clk), 
        .reset(reset_p), 
        .trig(trig_p && !control_mode), // Trigger SW only in SW mode
        .split(split_p), 
        .init_regs(init_regs), 
        .count_enabled(count_enabled)
    );

    // 3. Counter: Maintains 8-bit BCD time reading (Task 6)
    Counter #(.CLK_FREQ(100000000)) main_counter (
        .clk(clk), 
        .init_regs(init_regs), 
        .count_enabled(count_enabled), 
        .time_reading(current_time)
    );

    // 4. Stash: Stores and manages Lap/Split samples (Task 5)
    Stash #(.DEPTH(5)) data_stash (
        .clk(clk), 
        .reset(reset_p), 
        .sample_in(current_time), 
        .sample_in_valid(sample_p), 
        .next_sample(trig_p && control_mode), // Use btnU for next_sample in Stash mode
        .sample_out(stashed_time)
    );

    // 5. Split Logic: Freezes display at a snapshot (Task 9.b)
    always @(posedge clk) begin
        if (reset_p) begin
            split_active <= 0;
            snapshot_reg <= 8'h00;     // Explicitly clear snapshot on Reset
        end else if (trig_p && !control_mode) begin
            split_active <= 0;         // Release freeze on pause
        end else if (split_p && count_enabled) begin
            split_active <= 1;
            snapshot_reg <= current_time; // Capture current time snapshot
        end
    end

    // 6. Toggle Control Management and LED Indication (Task 9.d)
    always @(posedge clk) begin
        if (reset_p) control_mode <= 0;
        else if (toggle_p) control_mode <= ~control_mode;
    end

    assign led_left  = control_mode ? 3'b000 : 3'b111; 
    assign led_right = control_mode ? 3'b111 : 3'b000;

    // 7. Display Data Preparation: Side-by-Side split (Task 9)
    wire [7:0] left_digits = split_active ? snapshot_reg : current_time;
    wire [15:0] final_display = {left_digits, stashed_time};

    // 8. 7-Segment Display Unit
    Seg_7_Display display_unit (
        .clk(clk), 
        .x(final_display), 
        .seg(seg), 
        .an(an), 
        .dp(dp)
    );

endmodule