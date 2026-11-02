`timescale 1ns / 1ps

module ID_Stage (
    input         clk,
    input         rst,
    input  [31:0] PC_in,
    input  [31:0] Instruction,
    // from later stages / units (not implemented yet in this session)
    input         Hazard,
    input  [3:0]  SR,
    input  [3:0]  WB_Dest,
    input  [31:0] WB_Value,
    input         WB_WB_EN,
    // outputs
    output [31:0] PC,
    output        WB_EN,
    output        MEM_R_EN,
    output        MEM_W_EN,
    output [3:0]  EXE_CMD,
    output        B,
    output        S,
    output [31:0] Val_Rn,
    output [31:0] Val_Rm,
    output        imm,
    output [11:0] Shift_operand,
    output [23:0] Signed_imm_24,
    output [3:0]  Dest,
    output [3:0]  src_1,
    output [3:0]  src_2,
    output        Two_src
);

    assign PC = PC_in;

    // ---------------- Instruction fields ----------------
    wire [3:0]  cond   = Instruction[31:28];
    wire [1:0]  mode   = Instruction[27:26];
    wire [3:0]  opcode = Instruction[24:21];
    wire        S_bit  = Instruction[20];
    wire [3:0]  Rn     = Instruction[19:16];
    wire [3:0]  Rd     = Instruction[15:12];
    wire [3:0]  Rm     = Instruction[3:0];

    assign imm           = Instruction[25];
    assign Shift_operand = Instruction[11:0];
    assign Signed_imm_24 = Instruction[23:0];
    assign Dest          = Rd;

    // ---------------- Control Unit ----------------
    wire [3:0] cu_EXE_CMD;
    wire       cu_MEM_R_EN, cu_MEM_W_EN, cu_WB_EN, cu_B, cu_S;

    ControlUnit u_Control_Unit (
        .Mode(mode),
        .Opcode(opcode),
        .S(S_bit),
        .EXE_CMD(cu_EXE_CMD),
        .MEM_R_EN(cu_MEM_R_EN),
        .MEM_W_EN(cu_MEM_W_EN),
        .WB_EN(cu_WB_EN),
        .B(cu_B),
        .S_OUT(cu_S)
    );

    // uncond_MEM_W_EN / uncond_MEM_R_EN : raw Control Unit outputs
    wire uncond_MEM_W_EN = cu_MEM_W_EN;
    wire uncond_MEM_R_EN = cu_MEM_R_EN;

    // ---------------- Condition Check ----------------
    wire cond_ok;

    Condition_Check u_Condition_Check (
        .cond(cond),
        .SR(SR),
        .cond_ok(cond_ok)
    );

    // ---------------- Register File + src2 MUX ----------------
    assign src_1 = Rn;
    assign src_2 = uncond_MEM_W_EN ? Rd : Rm;   // STR reads Dest as the data to store

    RegisterFile u_RegisterFile (
        .clk(clk),
        .rst(rst),
        .src_1(src_1),
        .src_2(src_2),
        .Dest_WB(WB_Dest),
        .Result_WB(WB_Value),
        .writeBackEN(WB_WB_EN),
        .reg_out_1(Val_Rn),
        .reg_out_2(Val_Rm)
    );

    // ---------------- Two_src (used by Hazard Detection) ----------------
    assign Two_src = ~imm | uncond_MEM_W_EN;

    // ---------------- Control signal MUX: zero if cond fails or hazard ----------------
    wire kill = ~cond_ok | Hazard;

    assign {WB_EN, MEM_R_EN, MEM_W_EN, EXE_CMD, B, S} =
        kill ? 9'd0 : {cu_WB_EN, cu_MEM_R_EN, cu_MEM_W_EN, cu_EXE_CMD, cu_B, cu_S};

endmodule