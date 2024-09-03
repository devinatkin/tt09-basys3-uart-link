`timescale 1ns / 1ps

module tb_uart;

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter BAUD_RATE = 115_200;
    parameter CLK_FREQ = 50_000_000;

    // Clock and Reset
    logic clk;
    logic reset_n;

    // UART signals
    logic ena;
    logic [DATA_WIDTH-1:0] tx_data;
    logic [DATA_WIDTH-1:0] rx_data;
    logic tx_ready;
    logic rx_ready;
    logic tx, rx;

    // UART Interface instances
    uart_if.rx rxif();
    uart_if.tx txif();

    // UART instance
    uart #(
        .DATA_WIDTH(DATA_WIDTH),
        .BAUD_RATE(BAUD_RATE),
        .CLK_FREQ(CLK_FREQ)
    ) uart_inst (
        .clk(clk),
        .reset_n(reset_n),
        .ena(ena),
        .rxif(rxif),
        .txif(txif),
        .rx(rx),
        .tx(tx)
    );

    // Clock generation
    always #10 clk = ~clk;

    // Assign rx to tx to form a loopback
    assign rx = tx;

    // Testbench logic
    initial begin
        // Initialize
        clk = 0;
        reset_n = 0;
        ena = 1;
        tx_data = 0;

        // Apply reset
        #100;
        reset_n = 1;

        // Transmit and receive all possible values
        for (int i = 0; i < (1 << DATA_WIDTH); i++) begin
            // Send data
            tx_data = i;
            txif.data = tx_data;
            txif.valid = 1;
            #100;
            txif.valid = 0;

            // Wait for transmission to complete
            wait(txif.ready == 0);
            wait(txif.ready == 1);

            // Wait for reception to complete
            wait(rxif.valid == 1);
            rx_data = rxif.data;

            // Check received data
            if (rx_data !== tx_data) begin
                $display("ERROR: Data mismatch at %0t: sent %0h, received %0h", $time, tx_data, rx_data);
            end else begin
                $display("SUCCESS: Data matched at %0t: sent %0h, received %0h", $time, tx_data, rx_data);
            end

            // Wait for the next transmission
            #100;
        end

        $display("All data transmitted and received successfully.");
        $stop;
    end

endmodule
