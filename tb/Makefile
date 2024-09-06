# Makefile for testing with iverilog and vvp

# Define the compiler and simulator
IVL = iverilog -g2012
VVP = vvp

# Output directory for simulation files
OUT_DIR = sim_out

# Create the output directory if it doesn't exist
$(shell mkdir -p $(OUT_DIR))

# All source files (excluding testbenches)
SOURCES = \
	../src/tt_um_devinatkin_basys3_uart.sv \
	../src/uart.sv \
	../src/uart_tx.sv \
	../src/uart_rx.sv \
	../src/uart_sr_input.sv \
	../src/uart_tx_fifo.sv \
	../src/input_value_check.sv \
	../src/output_value_generator.sv \
	../src/pwm_module.sv \
	../src/circular_shift_register.sv \
	../src/bcd_binary.sv \
	../src/display_driver.sv \
	../src/segment_mux.sv \
	../src/sevenseg4ddriver.sv \
	../src/led_cycle.sv

# Phony targets
.PHONY: all clean

all: tb_uart tb_uart_sr

tb_uart: 
	$(IVL) -o $(OUT_DIR)/$@.vvp $(SOURCES) tb_uart.sv
	$(VVP) $(OUT_DIR)/$@.vvp

tb_uart_sr: 
	$(IVL) -o $(OUT_DIR)/$@.vvp $(SOURCES) tb_uart_sr.sv
	$(VVP) $(OUT_DIR)/$@.vvp

tb_uart_fifo: 
	$(IVL) -o $(OUT_DIR)/$@.vvp $(SOURCES) tb_uart_fifo.sv
	$(VVP) $(OUT_DIR)/$@.vvp

tb_input_value_check:
	$(IVL) -o $(OUT_DIR)/$@.vvp $(SOURCES) tb_input_value_check.sv
	$(VVP) $(OUT_DIR)/$@.vvp

tb_output_value_check:
	$(IVL) -o $(OUT_DIR)/$@.vvp $(SOURCES) tb_output_value_generator.sv
	$(VVP) $(OUT_DIR)/$@.vvp

tb_pwm:
	$(IVL) -o $(OUT_DIR)/$@.vvp $(SOURCES) tb_pwm_module.sv
	$(VVP) $(OUT_DIR)/$@.vvp

tb_circular_shift_register:
	$(IVL) -o $(OUT_DIR)/$@.vvp $(SOURCES) tb_circular_shift_register.sv
	$(VVP) $(OUT_DIR)/$@.vvp

tb_led_cycle:
	$(IVL) -o $(OUT_DIR)/$@.vvp $(SOURCES) tb_led_cycle.sv
	$(VVP) $(OUT_DIR)/$@.vvp

clean:
	@echo Cleaning up...
	rm -rf $(OUT_DIR)