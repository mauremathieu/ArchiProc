add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/dp/alu_do_w
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/dp/alu_op1_data_r
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/dp/alu_op2_data_r
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/dp/regfile_inst/rd_data_i
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/dp/reg_we_i
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/dp/pc_counter_r
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/dp/pc_next_w
add wave -position end -radix decimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/dp/regfile_inst/register_r[5]
add wave -position end -radix decimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/dp/regfile_inst/register_r[6]
add wave -position end -radix decimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/dp/regfile_inst/register_r[7]
add wave -position end -radix decimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/dp/regfile_inst/register_r[28]
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/cp/instruction_i
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/cp/inst_dec_r
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/cp/inst_exec_r
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/cp/inst_mem_r
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/cp/inst_wb_r
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/cp/stall_w
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/cp/pip_jump_w
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/cp/branch_taken_w
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/cp/rs1_dec_w
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/cp/rs2_dec_w
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/cp/rd_add_exec_w
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/cp/rd_add_mem_w
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/cp/rd_add_wb_w
run 8 us
wave zoom full
config wave -signalnamewidth 1