`timescale 1ns / 1ps

module sevenseg4ddrive_tb;

    logic clk;                  // 100 MHz clock
    logic rst_n;                // Reset signal
    logic [6:0] d0;             // Digit 0
    logic [6:0] d1;             // Digit 1
    logic [6:0] d2;             // Digit 2
    logic [6:0] d3;             // Digit 3
    
    logic [6:0] seg;            // Segment outputs
    logic [3:0] an;             // Anode outputs

    sevenseg4ddriver DUT(
    .clk(clk),
    .rst_n(rst_n),
    .digit0_segments(d0),
    .digit1_segments(d1),
    .digit2_segments(d2),
    .digit3_segments(d3),
    .segments(seg),
    .anodes(an)
    );

    // Clock generation for 100 MHz clock
    always begin
        #5 clk = ~clk;
    end

    //  Print Output whenever it changes
    always@(seg) begin
        $display("Anode State %4b, Cathode State %0h", an, seg);
                
    end

    initial begin
        // Initialize all inputs
        $display("Starting simulation...");
        clk = 0;            // 100 MHz clock
        rst_n=0;            // Reset signal
        d0 = 7'b0011000;    // Digit 0 set to 7'b0011000
        d1 = 7'b0011001;    // Digit 1 set to 7'b0011001
        d2 = 7'b0011010;    // Digit 2 set to 7'b0011010
        d3 = 7'b0011011;    // Digit 3 set to 7'b0011011
        
        #12; rst_n=1;       // Release reset after 10 ns

        // Wait for the anode to cycle through all 4 digits
        #10000000;          

        #10000000;

        #10000000;

        #10000000;
        
        #10000000;
        
        #10000000;
        
        $display("Finishing simulation...");
        $finish;
    end
endmodule