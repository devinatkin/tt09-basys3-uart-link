/*
 * Copyright (c) 2024 Devin Atkin
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module design1 (
    input  wire       clk,          // 100 MHz Basys 3 Clock
    input  wire       rst,        // Reset (active low)
    input  wire [15:0] sw,          // Basys 3 Switches
    input  wire [3:0]  btn,         // Basys 3 Buttons
    output wire [15:0] led,         // Basys 3 LEDs
    output wire [6:0]  seg,         // 7-segment display segments (A-G)
    output wire [3:0]  an           // 7-segment display anodes
);

    // Parameters
    parameter SWITCH_COUNT = 16;
    parameter BUTTON_COUNT = 5;
    parameter LED_COUNT = 16;

    // Internal signals
    logic [SWITCH_COUNT-1:0] switch_data;
    logic [BUTTON_COUNT-1:0] button_data;
    logic [LED_COUNT-1:0] led_data;

    // Connect Basys 3 switches and buttons to internal signals
    assign switch_data = sw;
    assign button_data = btn;

    // LED outputs
    assign led = led_data;

    // Display driver instantiation for Basys 3 7-segment display
    display_driver SegmentDisplay (
        .clk(clk),                   // 100 MHz System Clock
        .rst_n(!rst),               // Active Low Reset
        .bcd0(switch_data[3:0]),     // BCD input for the first digit (seconds LSB)
        .bcd1(switch_data[7:4]),     // BCD input for the second digit (seconds MSB)
        .bcd2(switch_data[11:8]),    // BCD input for the third digit (minutes LSB)
        .bcd3(switch_data[15:12]),   // BCD input for the fourth digit (minutes MSB)
        .seg(seg),                   // Segment Outputs (A-G)
        .an(an)                      // Common Anode Outputs (0 = on, 1 = off)
    );

    // LED Cycle instantiation to control Basys 3 LEDs
    led_cycle Led_Cycle_inst (
        .clk(clk),
        .rst_n(!rst),
        .buttons(button_data),
        .led(led_data)
    );

endmodule
