module tb_circular_shift_register;

    // Parameters
    parameter WIDTH = 8;
    parameter SIZE = 16;

    // Clock and reset signals
    logic clk;
    logic rst_n;

    // Output array for observing the register state
    logic [(WIDTH * SIZE)-1:0] reg_out_flat;

    logic [(WIDTH * SIZE)-1:0] reg_out_prev;
    // Instantiate the circular shift register
    circular_shift_register #(
        .WIDTH(WIDTH),
        .SIZE(SIZE)
    ) u_circular_shift_register (
        .clk(clk),
        .rst_n(rst_n),
        .reg_out(reg_out_flat)
    );

    // Clock generation
    always begin
        #5 clk = ~clk; // 10 time unit period
    end

    // Testbench stimulus
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        
        // Apply reset and hold it for a few clock cycles
        #20 rst_n = 1; // Release reset after 10 time units

        reg_out_prev = reg_out_flat;

        // Loop through 16 cycles and print the register state after each cycle
        repeat (SIZE) begin
            @(posedge clk); // Wait for the positive edge of the clock
            
            $display("Register state after cycle: %h", reg_out_flat);

            // Check if the register has shifted correctly
            if (reg_out_flat === reg_out_prev) begin
                $error("Register has not shifted");
            end

            reg_out_prev = reg_out_flat;
        end

        // Finish the simulation
        $finish;
    end

endmodule
