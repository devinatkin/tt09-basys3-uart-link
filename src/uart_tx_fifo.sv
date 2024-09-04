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
    function integer highest1Bit(input [CHARACTER_COUNT-1:0] val);
        integer i;
        highest1Bit = 0; 
        for (i = CHARACTER_COUNT-1; i >= 0; i--) begin
            if (val[i] == 1) begin
                highest1Bit = i;
                i = -1;
            end
        end
    endfunction

    // DATA_WIDTH by CHARACTER_COUNT FiFo
    logic [DATA_WIDTH-1:0] fifo [CHARACTER_COUNT-1:0];
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
                    tx_data <= fifo[highest1Bit(fifo_valid)];
                    tx_valid <= 1;
                    fifo[highest1Bit(fifo_valid)] <= 0;
                    fifo_valid[highest1Bit(fifo_valid)] <= 0;
                end else begin
                    tx_valid <= 0;
                end
            end else begin
                tx_valid <= 0;
            end
        end
    end

endmodule