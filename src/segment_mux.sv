
module segment_mux (
    input logic clk,            // Clock signal
    input logic rst_n,           // Active low reset signal
    input logic [6:0] in0,       // First 7-bit input
    input logic [6:0] in1,       // Second 7-bit input
    input logic [6:0] in2,       // Third 7-bit input
    input logic [6:0] in3,       // Fourth 7-bit input
    output logic [6:0] out_val,   // 7-bit output
    output logic [3:0] out_sel    // 4-bit output
);

    // Behavior under active low reset or positive clock edge
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            out_sel <= 4'b0001;   // Reset counter
        end else begin
            case(out_sel)
                4'b0001: out_sel <= 4'b0010; // Increment counter
                4'b0010: out_sel <= 4'b0100; // Increment counter
                4'b0100: out_sel <= 4'b1000; // Increment counter
                4'b1000: out_sel <= 4'b0001; // Increment counter
                default: out_sel <= 4'b0001; // Leaving Reset
            endcase
        end 
    end

    // Multiplexing the input values based on the counter
    always_comb begin
        case (out_sel)
            4'b0001: out_val = in0; // First input
            4'b0010: out_val = in1; // Second input
            4'b0100: out_val = in2; // Third input
            4'b1000: out_val = in3; // Fourth input
            default: out_val = 7'b0000000; // Reset
        endcase
    end

endmodule
