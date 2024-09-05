module circular_shift_register #(
    parameter WIDTH = 8,        // Width of each register
    parameter SIZE = 16         // Number of registers
) (
    input logic clk,            // Clock input
    input logic rst_n,          // Active low reset input
    output logic [(WIDTH*SIZE)-1:0] reg_out // Output array of registers
);

    logic [WIDTH-1:0] circ_reg [SIZE-1:0]; // Register array definition


    // Always block triggered by a positive edge of the clock
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            // Reset the register array to the initial state
            circ_reg[0]  <= 8'h00;
            circ_reg[1]  <= 8'h00;
            circ_reg[2]  <= 8'h00;
            circ_reg[3]  <= 8'h00;
            circ_reg[4]  <= 8'h10;
            circ_reg[5]  <= 8'h20;
            circ_reg[6]  <= 8'h40;
            circ_reg[7]  <= 8'hFF;
            circ_reg[8]  <= 8'hFF;
            circ_reg[9]  <= 8'h40;
            circ_reg[10] <= 8'h20;
            circ_reg[11] <= 8'h10;
            circ_reg[12] <= 8'h00;
            circ_reg[13] <= 8'h00;
            circ_reg[14] <= 8'h00;
            circ_reg[15] <= 8'h00;
            $display("Resetting the register array");
        end else begin
            // Circularly shift the register array
            for (int i = 0; i < SIZE-1; i++) begin
                circ_reg[i+1] <= circ_reg[i];
                $display("circ_reg[%0d] = %h", i+1, circ_reg[i+1]);
            end
            circ_reg[0] <= circ_reg[SIZE-1]; // Wrap around the last element
        end
    end

    // Always block to assign the values of the register array to the flattened output
    always_comb begin
        for (int i = 0; i < SIZE; i++) begin
            reg_out[(i*WIDTH)+:WIDTH] = circ_reg[i]; // Assign the register array to the output
        end
    end
    
endmodule
