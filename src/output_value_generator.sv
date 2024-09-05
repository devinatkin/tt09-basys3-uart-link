module output_value_check #(
    parameter DATA_WIDTH = 8,
    CHARACTER_COUNT = 10,
    LED_COUNT = 16,
    ELEMENT_COUNT = 12)
    (
    input logic [LED_COUNT-1:0] led_data,
    input logic [ELEMENT_COUNT-1:0] element_data,
    input logic tx_ready,
    output logic [DATA_WIDTH-1:0] output_data,
    output logic output_valid,
    input logic clk,
    input logic reset_n,
    input logic ena
    );

logic [LED_COUNT-1:0] led_data_reg;
logic [ELEMENT_COUNT-1:0] element_data_reg;

logic [DATA_WIDTH-1:0] character_buff [CHARACTER_COUNT-1:0];
logic ready_to_send; // You're either ready to send or you're sending
logic send_led_data;
logic send_element_data;
// - "LD: 0xFFFF" Coming from this design going to the peripheral
// - "7S: 0xFFFF" Coming from this design going to the peripheral

function logic [7:0] bin_to_hex_str(input logic [3:0] bin_value);
    // Convert the 4-bit value to a corresponding ASCII hex digit
    case (bin_value)
        4'b0000: bin_to_hex_str = 8'h30; // "0"
        4'b0001: bin_to_hex_str = 8'h31; // "1"
        4'b0010: bin_to_hex_str = 8'h32; // "2"
        4'b0011: bin_to_hex_str = 8'h33; // "3"
        4'b0100: bin_to_hex_str = 8'h34; // "4"
        4'b0101: bin_to_hex_str = 8'h35; // "5"
        4'b0110: bin_to_hex_str = 8'h36; // "6"
        4'b0111: bin_to_hex_str = 8'h37; // "7"
        4'b1000: bin_to_hex_str = 8'h38; // "8"
        4'b1001: bin_to_hex_str = 8'h39; // "9"
        4'b1010: bin_to_hex_str = 8'h41; // "A"
        4'b1011: bin_to_hex_str = 8'h42; // "B"
        4'b1100: bin_to_hex_str = 8'h43; // "C"
        4'b1101: bin_to_hex_str = 8'h44; // "D"
        4'b1110: bin_to_hex_str = 8'h45; // "E"
        4'b1111: bin_to_hex_str = 8'h46; // "F"
        default: bin_to_hex_str = 8'h3F; // "?" for error case
    endcase
endfunction



always_ff @(posedge clk) begin
    if(!reset_n) begin
        led_data_reg <= 0;
        element_data_reg <= 0;
        ready_to_send <= 1;
        send_led_data <= 0;
        send_element_data <= 0;
        output_data <= 0;
        output_valid <= 0;
        for(int i = 0; i < CHARACTER_COUNT; i++) begin
            character_buff[i] <= 0;
        end

    end else if(ena) begin
        if(led_data_reg != led_data) begin
            send_led_data <= 1;
            led_data_reg <= led_data;
        end
        if(element_data_reg != element_data) begin
            send_element_data <= 1;
            element_data_reg <= element_data;
        end
        if(ready_to_send) begin
            if(send_led_data) begin
                // Assign individual characters to the array
                character_buff[0] <= 8'd76; // "L"
                character_buff[1] <= 8'd68; // "D"
                character_buff[2] <= 8'd58; // ":"
                character_buff[3] <= 8'd32; // " "
                character_buff[4] <= 8'd48; // "0"
                character_buff[5] <= 8'd120; // "x"

                // Convert the binary value to hex and assign it to character_buff
                character_buff[6] <= bin_to_hex_str(led_data_reg[3:0]);
                character_buff[7] <= bin_to_hex_str(led_data_reg[7:4]);
                character_buff[8] <= bin_to_hex_str(led_data_reg[11:8]);
                character_buff[9] <= bin_to_hex_str(led_data_reg[15:12]);
                
                send_led_data <= 0;
                ready_to_send <= 0;
                //$display("Character Buffer Set to: %c-%c-%c-%c-%c-%c-%c-%c-%c-%c", character_buff[0], character_buff[1], character_buff[2], character_buff[3], character_buff[4], character_buff[5], character_buff[6], character_buff[7], character_buff[8], character_buff[9]);
            end else if(send_element_data) begin
                // Assign individual characters to the array for element data
                character_buff[0] <= 8'd55; // "7"
                character_buff[1] <= 8'd83; // "S"
                character_buff[2] <= 8'd58; // ":"
                character_buff[3] <= 8'd32; // " "
                character_buff[4] <= 8'd48; // "0"
                character_buff[5] <= 8'd120; // "x"

                // Convert the binary value to hex and assign it to character_buff
                character_buff[6] <= bin_to_hex_str(element_data_reg[3:0]);
                character_buff[7] <= bin_to_hex_str(element_data_reg[7:4]);
                character_buff[8] <= bin_to_hex_str(element_data_reg[11:8]);
                character_buff[9] <= "0";

                send_element_data <= 0;
                ready_to_send <= 0;
            end


        end else begin // Sending
            if(tx_ready) begin
                output_data <= character_buff[0];
                // Shift the buffer manually
                for(int i = 0; i < CHARACTER_COUNT-1; i++) begin
                    character_buff[i] <= character_buff[i+1];
                end
                character_buff[CHARACTER_COUNT-1] <= 0;
                output_valid <= 1;

                // Check if every element in the buffer is 0
                if(character_buff[0] == 0 && character_buff[1] == 0 && character_buff[2] == 0 && character_buff[3] == 0 && character_buff[4] == 0 && character_buff[5] == 0 && character_buff[6] == 0 && character_buff[7] == 0 && character_buff[8] == 0 && character_buff[9] == 0) begin
                    ready_to_send <= 1;
                    // When now sending make sure there is no ouput
                    output_data <= 0;
                    output_valid <= 0;
                end
            end
        end
    end
end



endmodule
