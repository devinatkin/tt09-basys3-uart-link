module bcd_to_binary (
    input logic [3:0] bcd,  // 4-bit BCD input
    output logic [6:0] seg  // 7-bit segary output
);

    // This always block triggers whenever there is a change in the BCD input.
    always_comb begin
        // Switch-case statement to convert the BCD to segary
        case (bcd)
            4'b0000: seg = 7'b0111111; // 0
            4'b0001: seg = 7'b0000110; // 1
            4'b0010: seg = 7'b1011011; // 2
            4'b0011: seg = 7'b1001111; // 3
            4'b0100: seg = 7'b1100110; // 4
            4'b0101: seg = 7'b1101101; // 5
            4'b0110: seg = 7'b1111101; // 6
            4'b0111: seg = 7'b0000111; // 7
            4'b1000: seg = 7'b1111111; // 8
            4'b1001: seg = 7'b1101111; // 9
            default: seg = 7'b0000000; // Default case, should not happen for valid BCD input
        endcase
    end

endmodule
