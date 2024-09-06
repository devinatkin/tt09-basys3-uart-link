module input_value_check #(
    parameter DATA_WIDTH = 8,
    CHARACTER_COUNT = 10,
    SWITCH_COUNT = 16,
    BUTTON_COUNT = 5)
    (
    output logic [SWITCH_COUNT-1:0] switch_data,
    output logic [BUTTON_COUNT-1:0] button_data,
    input logic [(DATA_WIDTH * CHARACTER_COUNT)-1:0] sr_data,
    input logic clk,
    input logic reset_n,
    input logic ena
    );

logic [SWITCH_COUNT-1:0] switch_data_reg;
logic [BUTTON_COUNT-1:0] button_data_reg;

logic [DATA_WIDTH-1:0] character_buff [CHARACTER_COUNT-1:0];

// Define the constant patterns for "BUT: 0x&&&" and "SW: 0x&&&&"
// & is a wildcard character
localparam logic [DATA_WIDTH*CHARACTER_COUNT-1:0] BUT_PATTERN = {"B", "T", ":", " ", "0", "x", "&" , "&", "&", "&"};
localparam logic [DATA_WIDTH*CHARACTER_COUNT-1:0] SW_PATTERN = {"S", "W", ":", " ", "0" , "x", "&", "&", "&", "&"};

// Function to check if the character buffer matches a pattern
function automatic logic match_pattern(
    input logic [DATA_WIDTH*CHARACTER_COUNT-1:0] pattern
);
    logic is_match;
    integer i;
    begin

        is_match = 1'b1;  // Assume it's a match initially
        for(i = 0; i < CHARACTER_COUNT; i++) begin
            // If pattern contains wildcard '&', it's always a match at that position
            if(pattern[i*DATA_WIDTH +: DATA_WIDTH] != "&" &&
               pattern[i*DATA_WIDTH +: DATA_WIDTH] != character_buff[i]) begin
                // if (pattern == BUT_PATTERN) begin
                // $display("C: %c%c%c%c%c%c%c%c%c%c", 
                //     character_buff[0], character_buff[1], character_buff[2], character_buff[3], character_buff[4],
                //     character_buff[5], character_buff[6], character_buff[7], character_buff[8], character_buff[9]);
                // // $display("P: %c%c%c%c%c%c%c%c%c%c", 
                // //     pattern[0*DATA_WIDTH +: DATA_WIDTH], 
                // //     pattern[1*DATA_WIDTH +: DATA_WIDTH], 
                // //     pattern[2*DATA_WIDTH +: DATA_WIDTH], 
                // //     pattern[3*DATA_WIDTH +: DATA_WIDTH], 
                // //     pattern[4*DATA_WIDTH +: DATA_WIDTH], 
                // //     pattern[5*DATA_WIDTH +: DATA_WIDTH], 
                // //     pattern[6*DATA_WIDTH +: DATA_WIDTH], 
                // //     pattern[7*DATA_WIDTH +: DATA_WIDTH], 
                // //     pattern[8*DATA_WIDTH +: DATA_WIDTH], 
                // //     pattern[9*DATA_WIDTH +: DATA_WIDTH]
                // //     );
                // $display("Mismatch between Character %0d: %c and Pattern %c", i, character_buff[i], pattern[i*DATA_WIDTH +: DATA_WIDTH]);
                // end
                is_match = 1'b0;  // If any character mismatches, set is_match to 0
            end
        end
        match_pattern = is_match;
    end
endfunction

// Function to convert a hex character to a nibble
function automatic logic [3:0] hex_char_to_nibble(
    input logic [7:0] hex_char
);
    begin
        if (hex_char >= "0" && hex_char <= "9")
            hex_char_to_nibble = (hex_char - "0") & 4'hF;
        else if (hex_char >= "A" && hex_char <= "F")
            hex_char_to_nibble = hex_char - "A" + 4'd10;
        else if (hex_char >= "a" && hex_char <= "f")
            hex_char_to_nibble = hex_char - "a" + 4'd10;
        else
            hex_char_to_nibble = 4'b0000;
    end
endfunction

// Function to convert a hex string to a 16-bit value
function automatic logic [15:0] hex_string_to_value (
    input logic [7:0] hex_char_0, 
    input logic [7:0] hex_char_1, 
    input logic [7:0] hex_char_2, 
    input logic [7:0] hex_char_3
);
    logic [3:0] nibble_0, nibble_1, nibble_2, nibble_3;
    begin
        nibble_0 = hex_char_to_nibble(hex_char_0);
        nibble_1 = hex_char_to_nibble(hex_char_1);
        nibble_2 = hex_char_to_nibble(hex_char_2);
        nibble_3 = hex_char_to_nibble(hex_char_3);
        // $display("Hex char 0: %c, Hex char 1: %c, Hex char 2: %c, Hex char 3: %c", hex_char_0, hex_char_1, hex_char_2, hex_char_3);
        hex_string_to_value = {nibble_0, nibble_1, nibble_2, nibble_3};
    end
endfunction

always_ff @(posedge clk) begin
    if(!reset_n) begin
        switch_data_reg <= 0;
        button_data_reg <= 0;
    end else if(ena) begin
        if(match_pattern(BUT_PATTERN)) begin
            // "BUT: 0x&&&" pattern matched
            // $display("Matched BUT_PATTERN");
            button_data_reg <= hex_string_to_value(
                character_buff[3], character_buff[2], 
                character_buff[1], character_buff[0]
            );
        end else if(match_pattern(SW_PATTERN)) begin
            // "SW: 0x&&&&" pattern matched
            switch_data_reg <= hex_string_to_value(
                character_buff[3], character_buff[2], 
                character_buff[1], character_buff[0]
            );
        end
    end
end

assign switch_data = switch_data_reg;
assign button_data = button_data_reg;

generate
    genvar i;
    for(i = 0; i < CHARACTER_COUNT; i++) begin: SR_ASSIGN
        assign character_buff[i] = sr_data[(i+1)*DATA_WIDTH-1:i*DATA_WIDTH];
    end
endgenerate

endmodule
