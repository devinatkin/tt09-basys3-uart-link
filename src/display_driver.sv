// 4-Digit 7-Segment Display Driver

module display_driver(
    input logic clk,             // 100MHz System Clock
    input logic rst_n,           // Active Low Reset
    input logic [3:0] bcd0,      // BCD input for the first digit (seconds LSB)
    input logic [3:0] bcd1,      // BCD input for the second digit (seconds MSB)
    input logic [3:0] bcd2,      // BCD input for the third digit (minutes LSB)
    input logic [3:0] bcd3,      // BCD input for the fourth digit (minutes MSB)
    output logic [6:0] seg,      // Segment Outputs
    output logic [3:0] an        // Common Anode Outputs (0 = on, 1 = off)
);

    logic [6:0] digit0, digit1, digit2, digit3;  // Segment Outputs for each digit
    logic [3:0] out_sel;                         // Common Anode Outputs (0 = on, 1 = off)

    // Assign the BCD inputs directly to the segment driver logic
    bcd_to_binary digit0_seg (
        .bcd(bcd0),
        .seg(digit0)
    );

    bcd_to_binary digit1_seg (
        .bcd(bcd1),
        .seg(digit1)
    );

    bcd_to_binary digit2_seg (
        .bcd(bcd2),
        .seg(digit2)
    );

    bcd_to_binary digit3_seg (
        .bcd(bcd3),
        .seg(digit3)
    );

    // 7-Segment Driver for 4 digits
    sevenseg4ddriver seg_driver (
        .clk(clk),
        .rst_n(rst_n),
        .digit0_segments(digit0),
        .digit1_segments(digit1),
        .digit2_segments(digit2),
        .digit3_segments(digit3),
        .segments(seg),
        .anodes(out_sel)
    );

    assign an = ~out_sel;  // Invert out_sel to drive the common anode

endmodule
