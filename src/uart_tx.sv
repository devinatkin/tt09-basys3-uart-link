// Based on Module by : Yuya Kudo

`include "uart_if.sv"

module uart_tx #(parameter
    DATA_WIDTH = 8,
    BAUD_RATE = 115_200,
    CLK_FREQ = 50_000_000

    localparam
    LB_DATA_WIDTH    = $clog2(DATA_WIDTH),
    PULSE_WIDTH      = CLK_FREQ / BAUD_RATE,
    LB_PULSE_WIDTH   = $clog2(PULSE_WIDTH),
    HALF_PULSE_WIDTH = PULSE_WIDTH / 2)
    uart_if.tx txif,
    input logic clk,
    input logic reset_n,
    input logic ena
    );


endmodule