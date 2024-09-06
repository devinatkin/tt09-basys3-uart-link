// Based on Module by : Yuya Kudo

module uart_rx #(parameter
    DATA_WIDTH = 8,
    BAUD_RATE = 115_200,
    CLK_FREQ = 50_000_000,

    localparam
    LB_DATA_WIDTH    = $clog2(DATA_WIDTH),
    PULSE_WIDTH      = CLK_FREQ / BAUD_RATE,
    LB_PULSE_WIDTH   = $clog2(PULSE_WIDTH),
    HALF_PULSE_WIDTH = PULSE_WIDTH / 2,
    PULSE_AND_HALF   = PULSE_WIDTH + HALF_PULSE_WIDTH)
    (
    input logic rx_signal,
    output logic [DATA_WIDTH-1:0] rx_data,
    output logic rx_valid,
    input logic rx_ready,
    input logic clk,
    input logic reset_n,
    input logic ena);

    // Noise Removing Filters
   function majority5(input [4:0] val);
      case(val)
        5'b00000: majority5 = 0;
        5'b00001: majority5 = 0;
        5'b00010: majority5 = 0;
        5'b00100: majority5 = 0;
        5'b01000: majority5 = 0;
        5'b10000: majority5 = 0;
        5'b00011: majority5 = 0;
        5'b00101: majority5 = 0;
        5'b01001: majority5 = 0;
        5'b10001: majority5 = 0;
        5'b00110: majority5 = 0;
        5'b01010: majority5 = 0;
        5'b10010: majority5 = 0;
        5'b01100: majority5 = 0;
        5'b10100: majority5 = 0;
        5'b11000: majority5 = 0;
        default:  majority5 = 1;
      endcase
   endfunction

   logic [1:0] SAMPLING_COUNT;
   logic [4:0] SIGNAL_Q;
   logic SIGNAL_R;

    // UART RX Filtering Logic,
    // Runs through the input data and filters out any noise in the signal
    always_ff @(posedge clk) begin
        if(!reset_n) begin
            SAMPLING_COUNT <= 0;
            SIGNAL_Q <= 5'b11111;
            SIGNAL_R <= 1;
        end else if(ena) begin
            // Connect to Deserializer After Removing Noise
            if(SAMPLING_COUNT == 0) begin
                SIGNAL_Q <= {rx_signal, SIGNAL_Q[4:1]};
            end

            SIGNAL_R <= majority5(SIGNAL_Q); // Majority Filter
            SAMPLING_COUNT <= SAMPLING_COUNT + 1;
        end
    end

    typedef enum logic [1:0] {
        STT_DATA,
        STT_STOP,
        STT_WAIT
    } uart_state;

    uart_state state;

    logic [DATA_WIDTH-1:0] DATA_TEMP_REG;
    logic [LB_DATA_WIDTH:0] DATA_CNT;
    logic [LB_PULSE_WIDTH:0] CLK_CNT;
    logic RX_DONE;

    always_ff @(posedge clk) begin
        if(!reset_n) begin
            state <= STT_WAIT;
            DATA_TEMP_REG <= 0;
            DATA_CNT <= 0;
            CLK_CNT <= 0;
        end
        else if (ena) begin

            case(state)
                // state: STT_WAIT
                // behavior: watch for a start bit
                // next state: when start bit is detected, go to the STT_DATA state
                STT_WAIT: begin
                    if(SIGNAL_R == 0) begin
                        CLK_CNT <= PULSE_AND_HALF[LB_PULSE_WIDTH:0];
                        DATA_CNT <= 0;
                        state <= STT_DATA;
                    end
                end

                // state: STT_DATA
                // behavior: Deserialized and recieve's the data
                // next state: when the data is recieved, go to the STT_STOP state
                STT_DATA: begin
                    if (CLK_CNT > 0) begin
                        CLK_CNT <= CLK_CNT - 1;
                    end
                    else begin
                        DATA_TEMP_REG <= {SIGNAL_R, DATA_TEMP_REG[DATA_WIDTH-1:1]};
                        CLK_CNT <= PULSE_WIDTH[LB_PULSE_WIDTH:0];

                        if (DATA_CNT == DATA_WIDTH[LB_DATA_WIDTH:0] - 1) begin
                            state <= STT_STOP;
                        end
                        else begin
                            DATA_CNT <= DATA_CNT + 1;
                        end
                    end
                end

                // state: STT_STOP
                // behavior: stop bit is detected
                // next state: go back to the STT_WAIT state
                STT_STOP: begin
                    if (CLK_CNT > 0) begin
                        CLK_CNT <= CLK_CNT - 1;
                    end
                    else if (SIGNAL_R) begin
                        state <= STT_WAIT;
                    end
                end

                // If we end up in an unknown state, go back to the wait state
                default: begin
                    state <= STT_WAIT;
                end
            endcase
        end
    end

    assign RX_DONE = (state == STT_STOP) && (CLK_CNT == 0);

    logic [DATA_WIDTH-1:0] DATA_REG;
    logic VALID_REG;

    always_ff @(posedge clk) begin
        if(!reset_n) begin
            DATA_REG <= 0;
            VALID_REG <= 0;
        end else if(ena) begin
            if(RX_DONE && !VALID_REG) begin
                DATA_REG <= DATA_TEMP_REG;
                VALID_REG <= 1;
            end else if (VALID_REG && rx_ready) begin
                VALID_REG <= 0;
            end
        end
    end

    assign rx_data = DATA_REG;
    assign rx_valid = VALID_REG;
endmodule