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

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100 MHz clock (10 ns period)
  end

  // Test procedure
  initial begin
    // Initialize all inputs
    reset_n = 0;
    ena = 0;
    led_data = 16'h0000;
    element_data = 12'h000;

    // Apply reset
    #20;
    reset_n = 1;

    // Enable the module
    ena = 1;

    // Stimulus 1: Set led_data
    #200;
    led_data = 16'hABCD;

    // Stimulus 2: Set element_data
    #500;
    element_data = 12'hFFF;

    // Wait and observe the output
    #100;

    // Stimulus 3: Change both led_data and element_data
    led_data = 16'h1234;
    element_data = 12'hAAA;

    // Wait and observe
    #100;

    // Finish the simulation
    $stop;
  end

  // Monitor outputs
  initial begin
    $monitor("Time = %0t, led_data = %h, element_data = %h, output_data = %h, output_valid = %b", 
              $time, led_data, element_data, output_data, output_valid);
  end

endmodule
