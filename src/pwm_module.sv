
module pwm_module
#(parameter bit_width = 8)
(
input logic clk,                         // 1-bit input: clock
input logic rst_n,                       // 1-bit input: reset
input [bit_width-1:0] duty,              // bitwidth-bit input: duty cycle
input [bit_width-1:0] max_value,         // bitwidth-bit input: maximum value
output logic pwm_out                     // 1-bit output: pwm output
);

logic [bit_width-1:0] counter;

// pwm output is high when counter is less than duty
// otherwise, pwm output is low
always_ff @(posedge clk)
begin
    if (~rst_n) begin
        counter <= (bit_width)'('d0);
        pwm_out <= 1'b0;
    end else begin 
        if (counter == max_value) begin
            counter <= (bit_width)'('d0);
        end else begin
            counter <= counter + (bit_width)'('d1);
        end
        pwm_out <= (counter < duty);
    end
end
endmodule