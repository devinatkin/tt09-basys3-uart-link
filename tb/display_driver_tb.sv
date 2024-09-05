`timescale 1ns / 1ns

// This is a testbench for the display_driver module.
// The module accounts for the need to cycle through the anodes and hold the display for a certain amount of time.

module tb_display_driver();

    // Declare signals to connect to the display_driver module
    logic clk;              // 100MHz clock (Lower frequency clocks are generated internal to the display_driver module)
    logic rst_n;            // Active low reset
    logic [3:0] bcd0;       // BCD input for seconds LSB
    logic [3:0] bcd1;       // BCD input for seconds MSB
    logic [3:0] bcd2;       // BCD input for minutes LSB
    logic [3:0] bcd3;       // BCD input for minutes MSB
    logic [6:0] seg;        // 7-bit segment value
    logic [3:0] an;         // 4-bit anode value

    logic [31:0] displayHold;   // 32-bit value to hold the display for a certain amount of time

    // Instantiate the display_driver module
    display_driver uut (
        .clk(clk),
        .rst_n(rst_n),
        .bcd0(bcd0),
        .bcd1(bcd1),
        .bcd2(bcd2),
        .bcd3(bcd3),
        .seg(seg),
        .an(an)
    );

    // Clock generation for 100MHz
    always #5 clk = ~clk;

    always @(an) begin
        $display("an = %b, seg = %b, time = %1d%1d:%1d%1d", an, bcd3, bcd2, bcd1, bcd0);
        #1; // Short delay to move transitions away from clock edges

        if (an == 4'b0111) begin // Increment after the anodes have cycled through
            displayHold = displayHold + 1;
            if (displayHold == 32'd3) begin // Increment after 100 anode cycles
                displayHold = 32'd0;

                // Update the BCD values for seconds and minutes
                bcd0 = bcd0 + 1;
                if (bcd0 == 4'd10) begin
                    bcd0 = 4'd0;
                    bcd1 = bcd1 + 1;
                end
                if (bcd1 == 4'd6) begin
                    bcd1 = 4'd0;
                    bcd2 = bcd2 + 1;
                end
                if (bcd2 == 4'd10) begin
                    bcd2 = 4'd0;
                    bcd3 = bcd3 + 1;
                end
                if (bcd3 == 4'd6) begin
                    bcd3 = 4'd0;
                end
            end
        end
    end

    // Testbench logic
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        bcd0 = 4'd0;
        bcd1 = 4'd0;
        bcd2 = 4'd0;
        bcd3 = 4'd0;
        displayHold = 32'd0;

        #2; // Short delay to move transitions away from clock edges

        // Apply reset
        rst_n = 0;
        #10;
        rst_n = 1;
        #100;

        // Wait until the time reaches 59:59 before ending the simulation
        while (!(bcd3 == 4'd5 && bcd2 == 4'd9 && bcd1 == 4'd5 && bcd0 == 4'd9)) begin
            #100;
        end
        $finish;
    end

endmodule
