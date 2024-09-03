// Based on Module by : Yuya Kudo

`include "uart_if.sv"

module uart #(parameter
    DATA_WIDTH = 8
    BAUD_RATE = 115_200
    CLK_FREQ = 50_000_000)
(
    input logic clk,
    input logic reset_n,
    input logic ena,
    uart_if.rx rxif,
    uart_if.tx txif,
    input logic rx,
    output logic tx
);

    uart_tx #(DATA_WIDTH, BAUD_RATE, CLK_FREQ)
    uart_tx_inst(.txif(txif),
                .clk(clk),
                .reset_n(reset_n),
                .ena(ena)
                );

    uart_rx #(DATA_WIDTH,BAUD_RATE,CLK_FREQ)
    uart_rx_inst(.rxif(rxif),
                .clk(clk),
                .reset_n(reset_n),
                .ena(ena))
endmodule