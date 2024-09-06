/*
 * Copyright (c) 2024 Devin Atkin
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_devinatkin_basys3_uart (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // Always 1 when the design is powered
    input  wire       clk,      // Clock
    input  wire       rst_n     // Reset (active low)
);

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter BAUD_RATE = 115_200;
    parameter CLK_FREQ = 50_000_000;
    parameter CHARACTER_COUNT = 10;
    parameter SWITCH_COUNT = 16;
    parameter BUTTON_COUNT = 5;
    parameter LED_COUNT = 16;
    parameter ELEMENT_COUNT = 12;

    // Internal signals
    logic tx_signal, rx_signal;
    logic [DATA_WIDTH-1:0] tx_data, rx_data, tx_data_in;
    logic tx_valid, tx_ready, rx_valid, rx_ready, tx_data_in_valid;
    logic [(DATA_WIDTH * CHARACTER_COUNT)-1:0] sr_data;
    logic [SWITCH_COUNT-1:0] switch_data;
    logic [BUTTON_COUNT-1:0] button_data;
    logic [LED_COUNT-1:0] led_data;
    logic [ELEMENT_COUNT-1:0] element_data;

    assign uo_out = switch_data[7:0];
    assign element_data[11] = switch_data[7];
    // Assign IO directions
    assign uio_oe = 8'b00011101; // Define IO directions (1 = output)

    // Outputs assignment
    assign uio_out = {1'b0, 1'b0, rx_valid, 1'b0, tx_valid, tx_ready, 1'b0, tx_signal};

    // Inputs assignment
    assign rx_signal = uio_in[1];
    assign rx_ready  = uio_in[4];

 
    // UART instance
    uart #(
        .DATA_WIDTH(DATA_WIDTH),
        .BAUD_RATE(BAUD_RATE),
        .CLK_FREQ(CLK_FREQ)
    ) uart_inst (
        .clk(clk),
        .reset_n(rst_n),
        .ena(ena),
        .tx_signal(tx_signal),
        .tx_data(tx_data),
        .tx_valid(tx_valid),
        .tx_ready(tx_ready),
        .rx_signal(rx_signal),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .rx_ready(rx_ready)
    );

    // UART Shift Register for input
    uart_sr_input #(
        .DATA_WIDTH(DATA_WIDTH),
        .CHARACTER_COUNT(CHARACTER_COUNT)
    ) uart_input_shift_register (
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .sr_data(sr_data),
        .clk(clk),
        .reset_n(rst_n),
        .ena(ena)
    );

    // UART TX FIFO
    uart_tx_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .CHARACTER_COUNT(CHARACTER_COUNT)
    ) uart_tx_fifo_inst (
        .tx_data(tx_data),
        .tx_valid(tx_valid),
        .tx_ready(tx_ready),
        .tx_data_in(tx_data_in),
        .tx_data_in_valid(tx_data_in_valid),
        .clk(clk),
        .reset_n(rst_n),
        .ena(ena)
    );

    // Input value checker
    input_value_check #(
        .DATA_WIDTH(DATA_WIDTH),
        .CHARACTER_COUNT(CHARACTER_COUNT),
        .SWITCH_COUNT(SWITCH_COUNT),
        .BUTTON_COUNT(BUTTON_COUNT)
    ) input_value_check_inst (
        .switch_data(switch_data),
        .button_data(button_data),
        .sr_data(sr_data),
        .clk(clk),
        .reset_n(rst_n),
        .ena(ena)
    );

    // Output value generator
    output_value_check #(
    .DATA_WIDTH(DATA_WIDTH),
    .CHARACTER_COUNT(CHARACTER_COUNT),
    .LED_COUNT(LED_COUNT),
    .ELEMENT_COUNT(ELEMENT_COUNT)
    ) output_value_inst (
    .led_data(led_data),
    .element_data(element_data),
    .tx_ready(tx_ready),
    .output_data(tx_data_in),
    .output_valid(tx_data_in_valid),
    .clk(clk),
    .reset_n(rst_n),
    .ena(ena)
  );

display_driver SegmentDisplay (
    .clk(clk),             // 50MHz System Clock
    .rst_n(rst_n),           // Active Low Reset
    .bcd0(switch_data[3:0]),      // BCD input for the first digit (seconds LSB)
    .bcd1(switch_data[7:4]),      // BCD input for the second digit (seconds MSB)
    .bcd2(switch_data[11:8]),      // BCD input for the third digit (minutes LSB)
    .bcd3(switch_data[15:12]),      // BCD input for the fourth digit (minutes MSB)
    .seg(element_data[6:0]),      // Segment Outputs
    .an(element_data[10:7])        // Common Anode Outputs (0 = on, 1 = off)
);

    led_cycle Led_Cycle_inst (
        .clk(clk),
        .rst_n(rst_n),
        .buttons(button_data),
        .led(led_data)
    );

logic unused_bits;
assign unused_bits = uio_in[7]| uio_in[6]| uio_in[5] | uio_in[3] | uio_in[2] | uio_in[0];  // Mark unused bits
logic [7:0] unused_bits2;
assign unused_bits2 = ui_in;  // Mark unused bits

endmodule
