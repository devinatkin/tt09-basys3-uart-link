module tb_bcd_to_binary;
    
    // Declaring signals to connect to the bcd_to_binary module
    logic [3:0] bcd;
    logic [6:0] bin;

    // Instantiating the bcd_to_binary module
    bcd_to_binary uut (
        .bcd(bcd),
        .seg(bin)
    );

    // Initial block to apply test vectors
    initial begin
        $display("Time\tBCD\tBinary");
        #100;
        // Loop through all possible 4-bit BCD numbers
        for (bcd = 4'b0000; bcd <= 4'b1001; bcd = bcd + 1) begin
            #10; // Wait for 10 time units
            $display("%0d\t%4b\t%0b", $time, bcd, bin);
        end

        // Test completed
        $stop;
    end

    // Additional logging for changes in bin
    always @(bin) begin
        if ($time > 0)
            $display("At time %0d, binary output changed to %b", $time, bin);
    end

endmodule
