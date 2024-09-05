`timescale 1ns/1ps

module tb_output_value_check;

  // Parameters for the module
  parameter DATA_WIDTH = 8;
  parameter CHARACTER_COUNT = 10;
  parameter LED_COUNT = 16;
  parameter ELEMENT_COUNT = 12;

  // Testbench signals
  logic [LED_COUNT-1:0] led_data;
  logic [ELEMENT_COUNT-1:0] element_data;
  logic tx_ready;
  logic [DATA_WIDTH-1:0] output_data;
  logic output_valid;
  logic clk;
  logic reset_n;
  logic ena;

  // DUT instantiation
  output_value_check #(
    .DATA_WIDTH(DATA_WIDTH),
    .CHARACTER_COUNT(CHARACTER_COUNT),
    .LED_COUNT(LED_COUNT),
    .ELEMENT_COUNT(ELEMENT_COUNT)
  ) dut (
    .led_data(led_data),
    .element_data(element_data),
    .tx_ready(tx_ready),
    .output_data(output_data),
    .output_valid(output_valid),
    .clk(clk),
    .reset_n(reset_n),
    .ena(ena)
  );

  // Feed the DUT output into the output FIFO to verify the full output
  logic [DATA_WIDTH-1:0] tx_data;
  logic tx_valid;

  uart_tx_fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .CHARACTER_COUNT(CHARACTER_COUNT)
    ) uart_tx_fifo_inst
    (
    .tx_data(tx_data),
    .tx_valid(tx_valid),
    .tx_ready(1'b0), // Never ready for this testbench (FIFO will simply overflow)
    .tx_data_in(output_data),
    .tx_data_in_valid(output_valid),
    .clk(clk),
    .reset_n(reset_n),
    .ena(ena));


  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100 MHz clock (10 ns period)
  end

  // Test procedure
  initial begin
    // Initialize all inputs
    reset_n = 0;
    ena = 1;
    led_data = 16'h0000;
    element_data = 12'h000;
    tx_ready = 1;

    // Apply reset
    #10 reset_n = 1;

    // Wait for a few clock cycles
    #10;

    // Change the led_data
    led_data = 16'hF0FF;
    #10;
    // Wait for output valid to drop
    wait(!output_valid);

    // Change the led_data

    led_data = 16'hAFCD;
    // Wait for output valid to cycke
    wait(output_valid);
    wait(!output_valid);

    // Change the element_data
    element_data = 12'h123;
    // Wait for output valid to cycle
    wait(output_valid);
    wait(!output_valid);

    led_data = 16'hAACD;
    // Wait for output valid to cycke
    wait(output_valid);
    wait(!output_valid);

    #500 $finish;
  end

  // Monitor the output
  initial begin
    $monitor("led_data = %h, element_data = %h, tx_ready = %b, output_data = %h, output_valid = %b", led_data, element_data, tx_ready, output_data, output_valid);
  end


  // Dump waveform
  initial begin
      $dumpfile("output.vcd");
      $dumpvars(0, tb_output_value_check);
      $dumpvars(0, uart_tx_fifo_inst);
  end

endmodule
