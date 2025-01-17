# Signaux du Pipeline de base
add wave -divider "Pipeline Control"
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/cp/instruction_i
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/cp/inst_dec_r
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/cp/inst_exec_r
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/cp/inst_mem_r
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/cp/inst_wb_r
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/cp/stall_w
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/cp/pip_jump_w
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/cp/branch_taken_w

# Program Counter et Contrôle
add wave -divider "PC and Control"
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/dp/pc_counter_r
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/dp/pc_next_w
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/cp/pc_next_sel_o

# Cache Control
add wave -divider "Cache Control"
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/cache_instruction/addr_i
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/cache_instruction/read_en_i
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/cache_instruction/read_valid_o
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/cache_instruction/read_word_o

# Cache - Signaux internes
add wave -divider "Cache Internals"
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/cache_instruction/byte_offset
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/cache_instruction/cache_index
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/cache_instruction/cache_tag
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/cache_instruction/hit_detected
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/cache_instruction/cache[0].valid
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/cache_instruction/cache[0].tag
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/cache_instruction/cache[0].data

# Cache - Interface mémoire
add wave -divider "Cache Memory Interface"
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/cache_instruction/memory_address
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/cache_instruction/memory_read_enable
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/cache_instruction/mem_read_valid_i
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/cache_instruction/mem_read_data_i

# ALU et Registres
add wave -divider "ALU and Registers"
add wave -position end -radix hexadecimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/dp/alu_do_w
add wave -position end -radix decimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/dp/regfile_inst/register_r[5]
add wave -position end -radix decimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/dp/regfile_inst/register_r[6]
add wave -position end -radix decimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/dp/regfile_inst/register_r[7]
add wave -position end -radix decimal sim:/RV32i_tb/RV32i_soc_inst/RV32i_core/dp/regfile_inst/register_r[28]

run 8 us
wave zoom full
config wave -signalnamewidth 1