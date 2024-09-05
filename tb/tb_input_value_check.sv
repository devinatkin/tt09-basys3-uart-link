`timescale 1ns/1ps

module tb_input_value_check;

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter CHARACTER_COUNT = 10;
    parameter SWITCH_COUNT = 16;
    parameter BUTTON_COUNT = 5;

    // Inputs
    logic [(DATA_WIDTH * CHARACTER_COUNT) - 1:0] sr_data;
    logic clk;
    logic reset_n;
    logic ena;

    // Outputs
    logic [SWITCH_COUNT - 1:0] switch_data;
    logic [BUTTON_COUNT - 1:0] button_data;

    // Instantiate the DUT (Design Under Test)
    input_value_check #(DATA_WIDTH, CHARACTER_COUNT, SWITCH_COUNT, BUTTON_COUNT) uut (
        .switch_data(switch_data),
        .button_data(button_data),
        .sr_data(sr_data),
        .clk(clk),
        .reset_n(reset_n),
        .ena(ena)
    );

    // Clock generation
    always #5 clk = ~clk; // 100 MHz clock period

    // Test stimulus
    initial begin
        // Initialize inputs
        clk = 0;
        reset_n = 0;
        ena = 0;
        sr_data = 0;

        // Apply reset
        #10 reset_n = 1;

        // Enable the system
        #10 ena = 1;

        // Test case 1: Send "BUT: 0xFF"
        sr_data = {"B", "T", ":", " ", "0", "x", "F", "F", "F", "F"};  // Fill the character buffer with "BUT: 0xFF"
        #100;
        if (button_data == 5'b11111) $display("Test 1 Passed: Button data correctly set to 0xFF");
        else $display("Test 1 Failed: Button data = %h", button_data);

        // Test case 2: Send "SW: 0xFFFF"
        sr_data = {"S", "W", ":", " ", "0", "x", "F", "F", "F", "F"};  // Fill the character buffer with "SW: 0xFFFF"
        #100;
        if (switch_data == 16'hFFFF) $display("Test 2 Passed: Switch data correctly set to 0xFFFF");
        else $display("Test 2 Failed: Switch data = %h", switch_data);

        // Test case 3: Random input, no match
        sr_data = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J"};
        #100;
        if (switch_data == 16'hFFFF && button_data == 5'b11111)
            $display("Test 3 Passed: No changes to switch or button data on invalid input");
        else
            $display("Test 3 Failed: Unexpected behavior on invalid input");

        // End simulation
        #50 $finish;
    end

    // Dump waveform
    initial begin
        $dumpfile("output.vcd");
        $dumpvars(0, tb_input_value_check);
    end

endmodule
