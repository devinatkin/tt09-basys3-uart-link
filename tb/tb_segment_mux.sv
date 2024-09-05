// Testbench for 4-to-1 Segment Mux
// Run through the mux selection and check if the output is as expected

module tb_segment_mux;

    // Declare signals for testbench
    logic clk;          // Clock
    logic rst_n;        // Reset
    logic [6:0] in0;        // Input 0
    logic [6:0] in1;        // Input 1
    logic [6:0] in2;        // Input 2
    logic [6:0] in3;        // Input 3
    logic [6:0] out_val;    // Output value
    logic [3:0] out_sel;    // Output selection (One hot encoded)

    // Instantiate DUT (Device Under Test)
    segment_mux uut (
        .clk(clk),      // Clock input (Increments through the selection possibilities)
        .rst_n(rst_n),  // Reset input (Active low)
        .in0(in0),      // Input 0
        .in1(in1),      // Input 1
        .in2(in2),      // Input 2
        .in3(in3),      // Input 3
        .out_val(out_val),  // Output value
        .out_sel(out_sel)   // Output selection
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test Procedure
    initial begin
        // Initialize inputs
        in0 = 7'b0000001;
        in1 = 7'b0000010;
        in2 = 7'b0000100;
        in3 = 7'b0001000;
        
        // Apply reset
        rst_n = 0;
        #12;
        rst_n = 1;
        
        // Check reset behavior
        if (out_sel !== 4'b0001 || out_val !== 7'b0000001) begin
            $display("Error: Reset behavior not as expected. out_sel = %b, out_val = %b", out_sel, out_val);
        end

        #10;  // Wait for one clock cycle

        // Check multiplexing behavior
        if (out_sel === 4'b0001 && out_val !== in0) begin
            $display("Error: Mux failed for in0. out_val = %b", out_val);
        end
        
        #10;

        if (out_sel === 4'b0010 && out_val !== in1) begin
            $display("Error: Mux failed for in1. out_val = %b", out_val);
        end

        #10;

        if (out_sel === 4'b0100 && out_val !== in2) begin
            $display("Error: Mux failed for in2. out_val = %b", out_val);
        end

        #10;

        if (out_sel === 4'b1000 && out_val !== in3) begin
            $display("Error: Mux failed for in3. out_val = %b", out_val);
        end

        #10;

        // Go back to the first selection to see if the pattern repeats
        if (out_sel === 4'b0001 && out_val !== in0) begin
            $display("Error: Mux failed for in0 in the second loop. out_val = %b", out_val);
        end

        $display("Simulation complete. Testbench successful if no errors are displayed.");
        $finish;
    end
endmodule
