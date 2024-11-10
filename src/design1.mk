# Define current directory
current_dir := ${CURDIR}
TARGET := basys3

# Define the top module and source files
TOP := design1
SOURCES := ${current_dir}/design1.sv ${current_dir}/led_cycle.sv ${current_dir}/bcd_binary.sv ${current_dir}/display_driver.sv ${current_dir}/pwm_module.sv ${current_dir}/input_value_check.sv ${current_dir}/segment_mux.sv ${current_dir}/uart_sr_input.sv ${current_dir}/uart.sv ${current_dir}/output_value_generator.sv ${current_dir}/tt_um_devinatkin_basys3_uart.sv ${current_dir}/uart_tx_fifo.sv ${current_dir}/circular_shift_register.sv ${current_dir}/sevenseg4ddriver.sv ${current_dir}/uart_rx.sv ${current_dir}/uart_tx.sv
XDC := ${current_dir}/basys3_design1.xdc

include ../common.mk