//                              -*- Mode: Verilog -*-
// Filename        : RV32i_monocycle_controlpath.sv
// Description     : control path
// Author          : michel agoyan
// Created On      : Mon Aug 19 14:06:29 2024
// Last Modified By: michel agoyan
// Last Modified On: Mon Aug 19 14:06:29 2024
// Update Count    : 0
// Status          : Unknown, Use with caution!

module RV32i_controlpath (
    input logic clk_i,
    input logic resetn_i,
    input logic [31:0] instruction_i,
    input logic alu_zero_i,
    input logic alu_lt_i,
    output logic [2:0] pc_next_sel_o,
    output logic reg_we_o,
    output logic mem_we_o,
    output logic mem_re_o,
    output logic [1:0] alu_src1_o,
    output logic alu_src2_o,
    output logic [2:0] imm_gen_sel_o,
    output logic [3:0] alu_control_o,
    output logic [1:0] wb_sel_o,

    output logic [4:0] rd_add_o,

    output logic stall_o
);

  import RV32i_pkg::*;

  logic branch_taken_w;
  logic stall_w;

  logic [6:0] opcode_dec_w, opcode_exec_w, opcode_mem_w, opcode_wb_w;
  logic [6:0] func7_exec_w;
  logic [2:0] func3_exec_w;
  logic [9:0] func10_exec_w;
  logic [31:0] inst_dec_r, inst_exec_r, inst_mem_r, inst_wb_r;

  logic[4:0] rd_add_dec_w, rd_add_exec_w, rd_add_mem_w, rd_add_wb_w;

  

  assign rs1_dec_w=instruction_i[19:15];
  assign rs2_dec_w=instruction_i[24:20];
  assign rd_add_dec_w=instruction_i[11:7];
  
  assign inst_dec_r = (stall_w == 1'b1)? 32'h00000013: instruction_i;
 

  assign opcode_dec_w = instruction_i[6:0];
  
  always_comb begin : pc_next_sel_comb
    if (branch_taken_w == 1'b1) pc_next_sel_o = SEL_PC_BRANCH;
    else begin
      case (opcode_dec_w)
        RV32I_I_INSTR_JALR: pc_next_sel_o = SEL_PC_JALR;
        RV32I_J_INSTR: pc_next_sel_o = SEL_PC_JAL;
        default: pc_next_sel_o = SEL_PC_PLUS_4;

      endcase
    end

  end

  always_comb begin : alu_src1_comb
    case (opcode_dec_w)
      RV32I_U_INSTR_LUI: alu_src1_o = SEL_OP1_IMM;
      RV32I_U_INSTR_AUIPC: alu_src1_o = SEL_OP1_PC;
      default: alu_src1_o = SEL_OP1_RS1;
    endcase

  end
  always_comb begin : alu_src2_comb
    case (opcode_dec_w)
      RV32I_I_INSTR_OPER: alu_src2_o = SEL_OP2_IMM;
      RV32I_I_INSTR_LOAD: alu_src2_o = SEL_OP2_IMM;
      RV32I_U_INSTR_AUIPC: alu_src2_o = SEL_OP2_IMM;
      RV32I_S_INSTR: alu_src2_o = SEL_OP2_IMM;
      default: alu_src2_o = SEL_OP2_RS2;
    endcase
  end

  always_comb begin : imm_gen_sel_comb
    case (opcode_dec_w)
      RV32I_I_INSTR_OPER: imm_gen_sel_o = IMM12_SIGEXTD_I;
      RV32I_I_INSTR_LOAD: imm_gen_sel_o = IMM12_SIGEXTD_I;
      RV32I_I_INSTR_JALR: imm_gen_sel_o = IMM12_SIGEXTD_I;
      RV32I_U_INSTR_LUI: imm_gen_sel_o = IMM20_UNSIGN_U;
      RV32I_U_INSTR_AUIPC: imm_gen_sel_o = IMM20_UNSIGN_U;
      RV32I_B_INSTR: imm_gen_sel_o = IMM12_SIGEXTD_SB;
      RV32I_S_INSTR: imm_gen_sel_o = IMM12_SIGEXTD_S;
      RV32I_J_INSTR: imm_gen_sel_o = IMM20_UNSIGN_UJ;
      default: imm_gen_sel_o = IMM12_SIGEXTD_I;
    endcase
  end

  always_ff @(posedge clk_i or resetn_i) begin : exec_stage
    if (resetn_i == 1'b0) inst_exec_r <= 32'h0;
    else inst_exec_r <= inst_dec_r;
  end
  assign rd_add_exec_w=inst_exec_r[11:7];

  assign opcode_exec_w = inst_exec_r[6:0];
  assign func7_exec_w  = inst_exec_r[31:25];
  assign func3_exec_w  = inst_exec_r[14:12];
  assign func10_exec_w = {func7_exec_w, func3_exec_w};

 

  always_comb begin : alu_control_comb
    alu_control_o = ALU_X;
    case (opcode_exec_w)
      RV32I_R_INSTR: begin
        case (func10_exec_w)
          {RV32I_FUNCT7_ADD, RV32I_FUNCT3_ADD} : alu_control_o = ALU_ADD;
          {RV32I_FUNCT7_SUB, RV32I_FUNCT3_SUB} : alu_control_o = ALU_SUB;
          {RV32I_FUNCT7_XOR, RV32I_FUNCT3_XOR} : alu_control_o = ALU_XOR;
          {RV32I_FUNCT7_OR, RV32I_FUNCT3_OR} : alu_control_o = ALU_OR;
          {RV32I_FUNCT7_AND, RV32I_FUNCT3_AND} : alu_control_o = ALU_AND;
          {RV32I_FUNCT7_SLL, RV32I_FUNCT3_SLL} : alu_control_o = ALU_SLLV;
          {RV32I_FUNCT7_SRL, RV32I_FUNCT3_SR} : alu_control_o = ALU_SRLV;
          {RV32I_FUNCT7_SRA, RV32I_FUNCT3_SR} : alu_control_o = ALU_SRAV;
          default: alu_control_o = ALU_X;
        endcase
      end
      RV32I_I_INSTR_OPER: begin
        case (func3_exec_w)
          RV32I_FUNCT3_ADD: alu_control_o = ALU_ADD;
          RV32I_FUNCT3_XOR: alu_control_o = ALU_XOR;
          RV32I_FUNCT3_OR: alu_control_o = ALU_OR;
          RV32I_FUNCT3_AND: alu_control_o = ALU_AND;
          RV32I_FUNCT3_SLL: alu_control_o = ALU_SLLV;
          RV32I_FUNCT3_SR: begin
            if (func7_exec_w == RV32I_FUNCT7_SRL) alu_control_o = ALU_SRLV;
            else if (func7_exec_w == RV32I_FUNCT7_SRA) alu_control_o = ALU_SRAV;
          end
          RV32I_FUNCT3_SR: alu_control_o = ALU_SRAV;
          default: alu_control_o = ALU_X;
        endcase
      end
      RV32I_U_INSTR_LUI: alu_control_o = ALU_COPY_RS1;
      RV32I_B_INSTR: begin
        case (func3_exec_w)
          RV32I_FUNCT3_BEQ: alu_control_o = ALU_SUB;
          RV32I_FUNCT3_BNE: alu_control_o = ALU_SUB;
          RV32I_FUNCT3_BLT: alu_control_o = ALU_SLT;
          RV32I_FUNCT3_BGE: alu_control_o = ALU_SLT;
          RV32I_FUNCT3_BLTU: alu_control_o = ALU_SLTU;
          RV32I_FUNCT3_BGEU: alu_control_o = ALU_SLTU;
          default: alu_control_o = ALU_SUB;
        endcase
      end
      RV32I_U_INSTR_AUIPC: alu_control_o = ALU_ADD;
      RV32I_I_INSTR_LOAD: alu_control_o = ALU_ADD;
      RV32I_S_INSTR: alu_control_o = ALU_ADD;
      RV32I_I_INSTR_LOAD: alu_control_o = ALU_ADD;
      RV32I_I_INSTR_JALR: alu_control_o = ALU_ADD;

      default: alu_control_o = ALU_X;
    endcase
  end

  always_comb begin : branch_taken_comb
    case (opcode_exec_w)
      RV32I_B_INSTR:
      case (func3_exec_w)
        RV32I_FUNCT3_BEQ: begin
          if (alu_zero_i == 1'b1) branch_taken_w = 1'b1;
          else branch_taken_w = 1'b0;
        end
        RV32I_FUNCT3_BNE: begin
          if (alu_zero_i == 1'b0) branch_taken_w = 1'b1;
          else branch_taken_w = 1'b0;
        end
        RV32I_FUNCT3_BLT: begin
          if (alu_zero_i == 1'b0) branch_taken_w = 1'b1;
          else branch_taken_w = 1'b0;
        end
        RV32I_FUNCT3_BGE: begin
          if (alu_zero_i == 1'b1) branch_taken_w = 1'b1;
          else branch_taken_w = 1'b0;
        end
        RV32I_FUNCT3_BLTU: begin
          if (alu_zero_i == 1'b0) branch_taken_w = 1'b1;
          else branch_taken_w = 1'b0;
        end
        RV32I_FUNCT3_BGEU: begin
          if (alu_zero_i == 1'b1) branch_taken_w = 1'b1;
          else branch_taken_w = 1'b0;
        end
        default: branch_taken_w = 1'b0;
      endcase

      default: branch_taken_w = 1'b0;
    endcase

  end

  always_ff @(posedge clk_i or resetn_i) begin : mem_stage
    if (resetn_i == 1'b0) inst_mem_r <= 32'h0;
    else inst_mem_r <= inst_exec_r;
  end
  assign rd_add_mem_w=inst_mem_r[11:7];

  assign opcode_mem_w = inst_mem_r[6:0];

  always_comb begin : mem_we_comb
    case (opcode_mem_w)
      RV32I_S_INSTR: mem_we_o = WE_1;
      default: mem_we_o = WE_0;
    endcase
  end

  always_comb begin : mem_re_comb
    case (opcode_mem_w)
      RV32I_I_INSTR_LOAD: mem_re_o = RE_1;
      default: mem_re_o = RE_0;
    endcase
  end

  always_ff @(posedge clk_i or resetn_i) begin : wb_stage
    if (resetn_i == 1'b0) inst_wb_r <= 32'h0;
    else inst_wb_r <= inst_mem_r;
  end
  assign rd_add_wb_w=inst_wb_r[11:7];
  assign rd_add_o=rd_add_wb_w;

  assign opcode_wb_w = inst_wb_r[6:0];

  always_comb begin : reg_we_comb
    case (opcode_wb_w)
      RV32I_B_INSTR: reg_we_o = WE_0;
      RV32I_I_INSTR_JALR: reg_we_o = WE_1;
      RV32I_J_INSTR: reg_we_o = WE_1;
      default: reg_we_o = WE_1;
    endcase

  end

  always_comb begin : wb_sel_comb
    case (opcode_wb_w)
      RV32I_I_INSTR_LOAD: wb_sel_o = SEL_WB_MEM;
      RV32I_I_INSTR_JALR: wb_sel_o = SEL_WB_PC_PLUS_4;
      RV32I_J_INSTR: wb_sel_o = SEL_WB_PC_PLUS_4;
      default: wb_sel_o = SEL_WB_ALU;
    endcase

  end

  assign stall_w = 1'b0;

  assign stall_o = stall_w;

endmodule
