
module sevenseg4ddriver(
    input logic clk, //100Mhz System Clock
    input logic rst_n,
    input logic [6:0] digit0_segments,
    input logic [6:0] digit1_segments,
    input logic [6:0] digit2_segments,
    input logic [6:0] digit3_segments,
    output logic [6:0] segments,
    output logic [3:0] anodes
    );

    logic clk_reduced; // Reduced clock signal for the mux
    logic [6:0] segments_mux; // Mux output for the segments
    assign segments = ~segments_mux; // Invert the output for the segments
    segment_mux persistence_mux (
        .clk(clk_reduced),
        .rst_n(rst_n),
        .in0(digit0_segments),
        .in1(digit1_segments),
        .in2(digit2_segments),
        .in3(digit3_segments),
        .out_val(segments_mux),
        .out_sel(anodes)
    );

    pwm_module #(
        .bit_width(13) // Wide bit width setup
    ) clk_reducer (
        .clk(clk),
        .rst_n(rst_n),
        .duty(4096), 
        .max_value(8192),
        .pwm_out(clk_reduced)
    );

endmodule