module uart_tx_fifo #(parameter
    DATA_WIDTH = 8,
    CHARACTER_COUNT = 10)
    (
    output logic [DATA_WIDTH-1:0] tx_data,
    output logic tx_valid,
    input logic tx_ready,
    input logic [DATA_WIDTH-1:0] tx_data_in,
    input logic tx_data_in_valid,
    input logic clk,
    input logic reset_n,
    input logic ena);

    // Function to find the highest bit set in 'val'
function logic [$clog2(CHARACTER_COUNT)-1:0] highest1Bit(input [CHARACTER_COUNT-1:0] val);
    integer i;
    highest1Bit = '0;  // Initialize to 0 (or possibly to a better default, e.g., -1 if no 1 found)
    for (i = CHARACTER_COUNT-1; i >= 0; i--) begin
        if (val[i] == 1) begin
            highest1Bit = i[$clog2(CHARACTER_COUNT)-1:0]; // Use the necessary width
            i = 0;  // Exit the loop
        end
    end
endfunction


    // DATA_WIDTH by CHARACTER_COUNT FiFo
    logic [DATA_WIDTH-1:0] fifo [CHARACTER_COUNT-1:0];

    // Declare a temporary variable to hold the result of highest1Bit
    logic [3:0] highest_idx;

    // // fifo registers split out so they show up in gtkwave
    // logic [DATA_WIDTH-1:0] fifo_0;
    // logic [DATA_WIDTH-1:0] fifo_1;
    // logic [DATA_WIDTH-1:0] fifo_2;
    // logic [DATA_WIDTH-1:0] fifo_3;
    // logic [DATA_WIDTH-1:0] fifo_4;
    // logic [DATA_WIDTH-1:0] fifo_5;
    // logic [DATA_WIDTH-1:0] fifo_6;
    // logic [DATA_WIDTH-1:0] fifo_7;
    // logic [DATA_WIDTH-1:0] fifo_8;
    // logic [DATA_WIDTH-1:0] fifo_9;

    // // Assign the data to the registers
    // assign fifo_0 = fifo[0];
    // assign fifo_1 = fifo[1];
    // assign fifo_2 = fifo[2];
    // assign fifo_3 = fifo[3];
    // assign fifo_4 = fifo[4];
    // assign fifo_5 = fifo[5];
    // assign fifo_6 = fifo[6];
    // assign fifo_7 = fifo[7];
    // assign fifo_8 = fifo[8];
    // assign fifo_9 = fifo[9];

    logic [CHARACTER_COUNT-1:0] fifo_valid;

    always_ff @(posedge clk) begin
        if(!reset_n) begin
            for(int i = 0; i < CHARACTER_COUNT; i++) begin
                fifo[i] <= 0;
                fifo_valid[i] <= 0;
            end
            tx_valid <= 0;
        end else if(ena) begin
            // Shift the data into the FIFO
            if(tx_data_in_valid) begin
                fifo[0] <= tx_data_in;
                fifo_valid[0] <= 1;
                $display("Loading Data into FIFO");
                // Shift the FIFO data across to accomodate new data if the FIFO has any valid data
                if(fifo_valid > 0) begin
                    for(int i = 1; i < CHARACTER_COUNT; i++) begin
                        fifo[i] <= fifo[i-1];
                        fifo_valid[i] <= fifo_valid[i-1];
                    end
                end
            end


            // Output the data if the FIFO has any valid data
            if (fifo_valid > 0) begin
                if(tx_ready) begin
                    highest_idx = highest1Bit(fifo_valid);
                    tx_data <= fifo[highest_idx];
                    tx_valid <= 1;
                    fifo[highest_idx] <= 0;
                    fifo_valid[highest_idx] <= 0;
                end else begin
                    tx_valid <= 0;
                end
            end else begin
                tx_valid <= 0;
            end
        end
    end

endmodule