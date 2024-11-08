module led_cycle (
    input clk,                  // 50MHz clock
    input rst_n,                // Reset signal
    input [4:0] buttons,        // 5 buttons for speed adjustment
    output logic [15:0] led       // 16 LEDs
);

    localparam bit_width = 6;    // Set the bit width to 8 for PWM instances
    localparam led_count = 16;
    logic [bit_width-1:0] duty [led_count-1:0];     // Duty cycles for each PWM module
    logic [led_count-1:0] pwm_out;        // PWM outputs
    logic [bit_width*led_count-1:0] reg_out;  // Output of the circular shift register
    logic clk_reduced;           // Reduced clock signal for the circular shift register
    logic [31:0] max_value;      // Maximum value for the clock reduction (speed control)

    // Speed control logic based on buttons
    always_comb begin
        case (buttons)
            5'b00001: max_value = 32'd5000000;  // Slowest speed
            5'b00010: max_value = 32'd4000000;
            5'b00100: max_value = 32'd3000000;
            5'b01000: max_value = 32'd2000000;
            5'b10000: max_value = 32'd1000000;  // Fastest speed
            default: max_value = 32'd5000000;   // Default to slowest if no button is pressed
        endcase
    end

    // Instantiate 16 PWM modules
    genvar i;
    generate
        for (i = 0; i < 16; i++) begin
            pwm_module #(
                .bit_width(bit_width)
            ) pwm_unit (
                .clk(clk),
                .rst_n(rst_n),
                .duty(duty[i]),
                .max_value(6'd63),
                .pwm_out(pwm_out[i])
            );
        end
    endgenerate

    // Instantiate the circular shift register
    circular_shift_register #(
        .WIDTH(bit_width), // Width of each register
        .SIZE(led_count)  // Number of registers
        ) csr (
        .clk(clk_reduced),
        .rst_n(rst_n),
        .reg_out(reg_out)
    );

    // Instantiate the 17th PWM module to reduce the clock speed
    pwm_module #(
        .bit_width(32) // Wide bit width setup for clock reduction
    ) clk_reducer (
        .clk(clk),
        .rst_n(rst_n),
        .duty(max_value >> 1),   // 50% duty cycle based on speed
        .max_value(max_value),   // Variable max value for speed control
        .pwm_out(clk_reduced)
    );

    // Control signals
    // Assign each duty cycle based on the circular shift register output
    genvar j;
    generate
        for (j = 0; j < 16; j++) begin
            assign duty[j] = reg_out[5*j +: 5];
        end
    endgenerate
    assign led = pwm_out;        // Drive LEDs with each bit of the PWM outputs

endmodule
