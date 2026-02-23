`timescale 1ns / 1ps

module tb_Debouncer();
    reg clk;
    reg input_unstable;
    wire output_stable;

    // Instantiate the Debouncer (parameter set to small value for fast simulation)
    Debouncer #(.COUNTER_BITS(4)) uut (
        .clk(clk),
        .input_unstable(input_unstable),
        .output_stable(output_stable)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        input_unstable = 0; #50;
        
        // Simulate bouncing (noise)
        input_unstable = 1; #10;
        input_unstable = 0; #10;
        input_unstable = 1; #10;
        input_unstable = 0; #10;
        
        input_unstable = 1; #10;// checking
        input_unstable = 1; #10;
        input_unstable = 1; #10;
        input_unstable = 0; #10;
        
        // Simulate stable press
        input_unstable = 1; #200;
        input_unstable = 0; #100;
        
        $stop;
    end
endmodule