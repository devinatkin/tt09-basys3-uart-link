module uart_sr_input #(parameter
    DATA_WIDTH = 8,
    CHARACTER_COUNT = 10)
    (
    input logic [DATA_WIDTH-1:0] rx_data,
    input logic rx_valid,
    output logic  [(DATA_WIDTH * CHARACTER_COUNT)-1:0] sr_data,
    input logic clk,
    input logic reset_n,
    input logic ena);

    // DATA_WIDTH by CHARACTER_COUNT Shift Register
    logic [DATA_WIDTH-1:0] sr [CHARACTER_COUNT-1:0];

    always_ff @(posedge clk) begin
        if(!reset_n) begin
            for(int i = 0; i < CHARACTER_COUNT; i++) begin
                sr[i] <= 0;
            end
        end else if(ena) begin
            if(rx_valid) begin
                for(int i = 1; i < CHARACTER_COUNT; i++) begin
                    sr[i] <= sr[i-1];
                end
                sr[0] <= rx_data;
            end
        end
    end

    // Assign the SR data to the output
    generate
        genvar i;
        for(i = 0; i < CHARACTER_COUNT; i++) begin: SR_ASSIGN
            assign sr_data[(i+1)*DATA_WIDTH-1:i*DATA_WIDTH] = sr[i];
        end
    endgenerate
endmodule