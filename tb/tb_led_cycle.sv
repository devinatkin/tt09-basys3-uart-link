`timescale 1ns/1ps

module tb_led_cycle;

    // Clock and reset signals
    reg clk;
    reg rst_n;

    // Inputs
    reg [4:0] buttons;
    reg [15:0] switches;

    // Outputs
    wire [15:0] led;

    // Instantiate the design under test (DUT)
    led_cycle dut (
        .clk(clk),
        .rst_n(rst_n),
        .buttons(buttons),
        .led(led)
    );

    // Clock generation: 50 MHz clock (20ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // Toggle clock every 10ns
    end

    // Test stimulus
    initial begin
        // Initialize inputs
        rst_n = 0;
        buttons = 5'b00000;
        switches = 16'b0;

        // Apply reset
        #100 rst_n = 1;  // Release reset after 100ns
        
        // Wait a few clock cycles
        #200;

        // Test different button states to adjust speed
        buttons = 5'b00001;  // Slowest speed
        #1000000;

        buttons = 5'b00010;  // Increase speed
        #1000000;

        buttons = 5'b00100;  // Increase speed further
        #1000000;

        buttons = 5'b01000;  // Faster speed
        #1000000;

        buttons = 5'b10000;  // Fastest speed
        #1000000;

        // Disable all buttons, expect default slowest speed
        buttons = 5'b00000;
        #1000000;

        // End simulation
        $finish;
    end

    // Monitor LED output and display changes
    initial begin
        $monitor("Time: %0t | Reset: %b | Buttons: %b | LEDs: %b", $time, rst_n, buttons, led);
    end

endmodule
