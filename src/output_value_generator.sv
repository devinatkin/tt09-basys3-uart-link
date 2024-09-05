module output_value_check #(
    parameter DATA_WIDTH = 8,
    CHARACTER_COUNT = 10,
    LED_COUNT = 16,
    ELEMENT_COUNT = 12)
    (
    input logic [LED_COUNT-1:0] led_data,
    input logic [ELEMENT_COUNT-1:0] element_data,
    output logic tx_ready,
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
string hex_str;
// - "LD: 0xFFFF" Coming from this design going to the peripheral
// - "7S: 0xFFFF" Coming from this design going to the peripheral

function string bin_to_hex_str(input logic [3:0] bin_value);
    // Declare the output string
    string hex_str;

    // Convert the 4-bit value to a corresponding hex digit
    case (bin_value)
        4'b0000: hex_str = "0";
        4'b0001: hex_str = "1";
        4'b0010: hex_str = "2";
        4'b0011: hex_str = "3";
        4'b0100: hex_str = "4";
        4'b0101: hex_str = "5";
        4'b0110: hex_str = "6";
        4'b0111: hex_str = "7";
        4'b1000: hex_str = "8";
        4'b1001: hex_str = "9";
        4'b1010: hex_str = "A";
        4'b1011: hex_str = "B";
        4'b1100: hex_str = "C";
        4'b1101: hex_str = "D";
        4'b1110: hex_str = "E";
        4'b1111: hex_str = "F";
        default: hex_str = "?"; // Error case
    endcase

    return hex_str; // Return the final hex string
endfunction


always_ff @(posedge clk) begin
    if(!reset_n) begin
        led_data_reg <= 0;
        element_data_reg <= 0;
        ready_to_send <= 1;
        send_led_data <= 0;
        send_element_data <= 0;

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
                character_buff[0] <= "L";
                character_buff[1] <= "D";
                character_buff[2] <= ":";
                character_buff[3] <= " ";
                character_buff[4] <= "0";
                character_buff[5] <= "x";

                // Convert the binary value to hex and assign it to character_buff
                character_buff[6] = bin_to_hex_str(led_data[3:0]);
                character_buff[7] = bin_to_hex_str(led_data[7:4]);
                character_buff[8] = bin_to_hex_str(led_data[11:8]);
                character_buff[9] = bin_to_hex_str(led_data[15:12]);
                
                send_led_data <= 0;
                ready_to_send <= 0;
            end else if(send_element_data) begin
                // Assign individual characters to the array for element data
                character_buff[0] <= "7";
                character_buff[1] <= "S";
                character_buff[2] <= ":";
                character_buff[3] <= " ";
                character_buff[4] <= "0";
                character_buff[5] <= "x";

                // Convert the binary value to hex and assign it to character_buff
                character_buff[6] = bin_to_hex_str(element_data[3:0]);
                character_buff[7] = bin_to_hex_str(element_data[7:4]);
                character_buff[8] = bin_to_hex_str(element_data[11:8]);
                character_buff[9] = "0";

                send_element_data <= 0;
                ready_to_send <= 0;
            end
        end
        if(!ready_to_send) begin
            output_data <= character_buff[0];
            // Shift the buffer manually
            for(int i = 0; i < CHARACTER_COUNT-1; i++) begin
                character_buff[i] <= character_buff[i+1];
            end
            character_buff[CHARACTER_COUNT-1] <= 0;
            output_valid <= 1;

            // Check if the buffer is empty
            if(character_buff[0] == 0) begin
                ready_to_send <= 1;
            end
        end else begin
            output_data <= 0;
            output_valid <= 0;
        end
    end
end



endmodule
