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

logic [15:0] string_value;

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
    logic [7:0] nibble_byte;
    begin
        if (hex_char >= "0" && hex_char <= "9")
            nibble_byte = (hex_char - "0");
        else if (hex_char >= "A" && hex_char <= "F")
            nibble_byte = hex_char - "A" + 8'd10;
        else if (hex_char >= "a" && hex_char <= "f")
            nibble_byte = hex_char - "a" + 8'd10;
        else
            nibble_byte = 8'b00000000;
        hex_char_to_nibble = nibble_byte[3:0];
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
            button_data_reg <= string_value[BUTTON_COUNT-1:0];
        end else if(match_pattern(SW_PATTERN)) begin
            // "SW: 0x&&&&" pattern matched
            switch_data_reg <= string_value;
        end
    end
end

always_comb begin
    string_value = hex_string_to_value(
        character_buff[3], character_buff[2], 
        character_buff[1], character_buff[0]
    );
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
