/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_devinatkin_basys3_uart (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    parameter DATA_WIDTH = 8;
    parameter BAUD_RATE = 115_200;
    parameter CLK_FREQ = 50_000_000;
    parameter CHARACTER_COUNT = 10;
    logic tx_signal;
    logic rx_signal;

    logic [DATA_WIDTH-1:0] tx_data;
    logic tx_valid;
    logic tx_ready;

    logic [DATA_WIDTH-1:0] rx_data;
    logic rx_valid;
    logic rx_ready;

    logic [(DATA_WIDTH * CHARACTER_COUNT)-1:0] sr_data ;

    // Assign the direction of the IOs
    assign uio_oe  = 8'b00011001; 

    // All output pins must be assigned. If not used, assign to 0.
    assign uo_out  = ui_in;  // Example: ou_out is the sum of ui_in and uio_in
    assign uio_out[0] = tx_signal;
    assign uio_out[1] = 1'b0; // rx_signal
    assign uio_out[2] = 1'b0; // tx_valid 
    assign uio_out[3] = tx_ready;
    assign uio_out[4] = rx_valid;
    assign uio_out[5] = 1'b0; // rx_ready
    assign uio_out[6] = 1'b0; // unused
    assign uio_out[7] = 1'b0; // unused

    // uio_in[0] tx_signal - output
    assign rx_signal = uio_in[1];
    assign tx_valid = uio_in[2];
    // uio_in[3] tx_ready - output
    // uio_in[4] rx_valid - output
    assign rx_ready = uio_in[5];
    // uio_in[6] unused
    // uio_in[7] unused

    assign tx_data = rx_data;

     

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

    uart_sr_input #(
    .DATA_WIDTH(DATA_WIDTH),
    .CHARACTER_COUNT(CHARACTER_COUNT)
    ) uart_input_shift_register
    (
    .rx_data(rx_data),
    .rx_valid(rx_valid),
    .sr_data(sr_data),
    .clk(clk),
    .reset_n(rst_n),
    .ena(ena));

endmodule
