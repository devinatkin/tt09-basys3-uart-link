// Based on Module by : Yuya Kudo


interface uart_if
#(parameter
DATA_WIDTH = 8)

logic signal;
logic [DATA_WIDTH-1:0] data;
logic valid;
logic ready;

modport tx(
   output signal,
   input data,
   input valid,
   output ready 
);

modport rx(
    input signal,
    output data,
    output valid,
    input ready
);

endinterface