# Makefile for Basys 3 Design

# Toolchain paths
F4PGA_INSTALL_DIR ?= $(HOME)/opt/f4pga
FPGA_FAM ?= xc7
FPGA_PART ?= xc7a35tcpg236-1
DEVICE ?= basys3

# Source files
SRC_FILES := design1.sv led_cycle.sv bcd_binary.sv display_driver.sv pwm_module.sv input_value_check.sv segment_mux.sv uart_sr_input.sv uart.sv output_value_generator.sv tt_um_devinatkin_basys3_uart.sv uart_tx_fifo.sv circular_shift_register.sv sevenseg4ddriver.sv uart_rx.sv uart_tx.sv
TOP_MODULE := design1
CONSTRAINTS := basys3_design1.xdc

# Output directory
BUILD_DIR := build

# Create build directory
$(shell mkdir -p $(BUILD_DIR))

# Synthesis
synth:
	yosys -p "read_verilog -sv $(SRC_FILES); synth_xilinx -top design1 -family xc7; write_json build/design1.json"

# Place and Route
place_route: synth
	nextpnr-xilinx --chipdb $(F4PGA_INSTALL_DIR)/conda/envs/xc7/share/nextpnr-xilinx/xc7a35tcpg236-1.bin --xdc $(CONSTRAINTS) --json $(BUILD_DIR)/$(TOP_MODULE).json --write $(BUILD_DIR)/$(TOP_MODULE)_routed.json --fasm $(BUILD_DIR)/$(TOP_MODULE).fasm --verbose --log $(BUILD_DIR)/nextpnr.log

# Bitstream Generation
bitstream: place_route
	fasm2bels --db-root $(F4PGA_INSTALL_DIR)/$(FPGA_FAM)/share/fasm2bels --part $(FPGA_PART) --fasm $(BUILD_DIR)/$(TOP_MODULE).fasm --bit $(BUILD_DIR)/$(TOP_MODULE).bit

# All
all: bitstream

# Clean
clean:
	rm -rf $(BUILD_DIR)
