`timescale 1ns / 1ps

module ARM (
    input clk,
    input rst
);

    // Hazard Detection wire
    wire Hazard;
    // When Hazard == 1, freeze PC and IF/ID reg
    wire freeze = Hazard;

    // Branch and Flush wires driven from EXE stage
    wire        Branch_taken;
    wire [31:0] BranchAddr;
    wire        flush;

    // IF and IF/ID wires
    wire [31:0] IF_pc, IF_instruction;
    wire [31:0] ID_pc, ID_instruction;
    wire [31:0] id_out_pc;

    // ID stage outputs
    wire        id_WB_EN, id_MEM_R_EN, id_MEM_W_EN, id_B, id_S, id_imm, id_Two_src;
    wire [3:0]  id_EXE_CMD, id_Dest, id_src_1, id_src_2;
    wire [31:0] id_Val_Rn, id_Val_Rm;
    wire [11:0] id_Shift_operand;
    wire [23:0] id_Signed_imm_24;

    // ID/EXE register outputs (Preserving your exact wire names)
    (* keep = "true" *) wire        EXE_WB_EN, EXE_MEM_R_EN, EXE_MEM_W_EN, EXE_B, EXE_S, EXE_imm;
    (* keep = "true" *) wire [3:0]  EXE_EXE_CMD, EXE_Dest;
    (* keep = "true" *) wire [31:0] EXE_pc, EXE_Val_Rn, EXE_Val_Rm;
    (* keep = "true" *) wire [11:0] EXE_Shift_operand;
    (* keep = "true" *) wire [23:0] EXE_Signed_imm_24;

    // EXE stage & Status Register wires
    (* keep = "true" *) wire [31:0] EXE_ALU_Res;
    (* keep = "true" *) wire [31:0] EXE_Br_addr;
    (* keep = "true" *) wire [3:0]  EXE_Status_Bits;
    (* keep = "true" *) wire [3:0]  SR;

    // Aliases matching Figure 2 of Session 3 manual for ILA / Waveform
    (* keep = "true" *) wire        EXE_WB            = EXE_WB_EN;
    (* keep = "true" *) wire [31:0] EXE_ALU_Result_o  = EXE_ALU_Res;
    (* keep = "true" *) wire [3:0]  EXE_status_bits_o = EXE_Status_Bits;
    (* keep = "true" *) wire [3:0]  SR_status_bits_o  = SR;

    // EXE/MEM register outputs
    (* keep = "true" *) wire        MEM_WB_EN, MEM_R_EN, MEM_W_EN;
    (* keep = "true" *) wire [31:0] MEM_ALU_Res, MEM_Val_Rm;
    (* keep = "true" *) wire [3:0]  MEM_Dest;

    // MEM Stage outputs
    wire [31:0] MEM_Data_out;

    // MEM/WB register outputs
    wire        WB_WB_EN;
    wire        WB_MEM_R_EN;
    wire [31:0] WB_ALU_Res;
    wire [31:0] WB_Data;
    wire [3:0]  WB_Dest;

    // WB Stage Output (Loops back to ID Stage Register File)
    wire [31:0] Result_WB;

    // Connect Branch & Flush from EXE stage
    assign Branch_taken = EXE_B;
    assign BranchAddr   = EXE_Br_addr;
    assign flush        = EXE_B;

    // ==================== Hazard Detection Unit ====================
    HazardDetectionUnit u_HazardDetectionUnit (
        .src1(id_src_1),
        .src2(id_src_2),
        .Two_src(id_Two_src),
        .EXE_WB_EN(EXE_WB_EN),
        .EXE_Dest(EXE_Dest),
        .MEM_WB_EN(MEM_WB_EN),
        .MEM_Dest(MEM_Dest),
        .Hazard(Hazard)
    );

    // ==================== 1. IF STAGE ====================
    IF_Stage u_IF_Stage (
        .clk(clk),
        .rst(rst),
        .freeze(freeze),
        .Branch_taken(Branch_taken),
        .BranchAddr(BranchAddr),
        .PC(IF_pc),
        .Instruction(IF_instruction)
    );

    IF_Stage_Reg u_IF_Stage_Reg (
        .clk(clk),
        .rst(rst),
        .freeze(freeze),
        .flush(flush),
        .PC_in(IF_pc),
        .Instruction_in(IF_instruction),
        .PC(ID_pc),
        .Instruction(ID_instruction)
    );

    // ==================== 2. ID STAGE ====================
    ID_Stage u_ID_Stage (
        .clk(clk),
        .rst(rst),
        .PC_in(ID_pc),
        .Instruction(ID_instruction),
        .Hazard(Hazard),
        .SR(SR),
        
        // --- FIXED PORTS: Matching the exact names in ID_Stage.v ---
        .Dest_WB(WB_Dest),
        .Result_WB(Result_WB),
        .writeBackEN(WB_WB_EN),
        // -----------------------------------------------------------
        
        .PC(id_out_pc),
        .WB_EN(id_WB_EN),
        .MEM_R_EN(id_MEM_R_EN),
        .MEM_W_EN(id_MEM_W_EN),
        .EXE_CMD(id_EXE_CMD),
        .B(id_B),
        .S(id_S),
        .Val_Rn(id_Val_Rn),
        .Val_Rm(id_Val_Rm),
        .imm(id_imm),
        .Shift_operand(id_Shift_operand),
        .Signed_imm_24(id_Signed_imm_24),
        .Dest(id_Dest),
        .src_1(id_src_1),
        .src_2(id_src_2),
        .Two_src(id_Two_src)
    );

    ID_Stage_Reg u_ID_Stage_Reg (
        .clk(clk),
        .rst(rst),
        .flush(flush),
        .WB_EN_in(id_WB_EN),
        .MEM_R_EN_in(id_MEM_R_EN),
        .MEM_W_EN_in(id_MEM_W_EN),
        .EXE_CMD_in(id_EXE_CMD),
        .B_in(id_B),
        .S_in(id_S),
        .PC_in(id_out_pc),
        .Val_Rn_in(id_Val_Rn),
        .Val_Rm_in(id_Val_Rm),
        .imm_in(id_imm),
        .Shift_operand_in(id_Shift_operand),
        .Signed_imm_24_in(id_Signed_imm_24),
        .Dest_in(id_Dest),
        .PC(EXE_pc),
        .WB_EN(EXE_WB_EN),
        .MEM_R_EN(EXE_MEM_R_EN),
        .MEM_W_EN(EXE_MEM_W_EN),
        .EXE_CMD(EXE_EXE_CMD),
        .B(EXE_B),
        .S(EXE_S),
        .Val_Rn(EXE_Val_Rn),
        .Val_Rm(EXE_Val_Rm),
        .imm(EXE_imm),
        .Shift_operand(EXE_Shift_operand),
        .Signed_imm_24(EXE_Signed_imm_24),
        .Dest(EXE_Dest)
    );

    // ==================== 3. EXE STAGE ====================
    EXE_Stage u_EXE_Stage (
        .clk(clk),
        .rst(rst),
        .EXE_CMD(EXE_EXE_CMD),
        .MEM_R_EN(EXE_MEM_R_EN),
        .MEM_W_EN(EXE_MEM_W_EN),
        .PC_in(EXE_pc),
        .Val_Rn(EXE_Val_Rn),
        .Val_Rm(EXE_Val_Rm),
        .imm(EXE_imm),
        .Shift_operand(EXE_Shift_operand),
        .Signed_imm_24(EXE_Signed_imm_24),
        .SR_in(SR),
        .ALU_Res(EXE_ALU_Res),
        .Br_addr(EXE_Br_addr),
        .Status_Bits(EXE_Status_Bits)
    );

    StatusRegister u_StatusRegister (
        .clk(clk),
        .rst(rst),
        .S(EXE_S),
        .Status_in(EXE_Status_Bits),
        .SR(SR)
    );

    EXE_Stage_Reg u_EXE_Stage_Reg (
        .clk(clk),
        .rst(rst),
        .WB_EN_in(EXE_WB_EN),
        .MEM_R_EN_in(EXE_MEM_R_EN),
        .MEM_W_EN_in(EXE_MEM_W_EN),
        .ALU_Res_in(EXE_ALU_Res),
        .Val_Rm_in(EXE_Val_Rm),
        .Dest_in(EXE_Dest),
        .WB_EN(MEM_WB_EN),
        .MEM_R_EN(MEM_R_EN),
        .MEM_W_EN(MEM_W_EN),
        .ALU_Res(MEM_ALU_Res),
        .Val_Rm(MEM_Val_Rm),
        .Dest(MEM_Dest)
    );

    // ==================== 4. MEM STAGE ====================
    MEM_Stage u_MEM_Stage (
        .clk(clk),
        .rst(rst),
        .MEM_R_EN(MEM_R_EN),
        .MEM_W_EN(MEM_W_EN),
        .ALU_res(MEM_ALU_Res),
        .Val_Rm(MEM_Val_Rm),
        .Data_out(MEM_Data_out)
    );

    MEM_Stage_Reg u_MEM_Stage_Reg (
        .clk(clk),
        .rst(rst),
        .WB_EN_in(MEM_WB_EN),
        .MEM_R_EN_in(MEM_R_EN),
        .ALU_res_in(MEM_ALU_Res),
        .Data_in(MEM_Data_out),
        .Dest_in(MEM_Dest),
        .WB_EN(WB_WB_EN),
        .MEM_R_EN(WB_MEM_R_EN),
        .ALU_res(WB_ALU_Res),
        .Data(WB_Data),
        .Dest(WB_Dest)
    );

    // ==================== 5. WB STAGE ====================
    WB_Stage u_WB_Stage (
        .MEM_R_EN(WB_MEM_R_EN),
        .ALU_res(WB_ALU_Res),
        .Data(WB_Data),
        .Result_WB(Result_WB)
    );

endmodule