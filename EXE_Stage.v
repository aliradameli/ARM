`timescale 1ns / 1ps

module EXE_Stage (
    input clk,
    input rst,
    input [3:0] EXE_CMD,
    input MEM_R_EN,
    input MEM_W_EN,
    input [31:0] PC_in,
    input [31:0] Val_Rn,
    input [31:0] Val_Rm,
    input imm,
    input [11:0] Shift_operand,
    input [23:0] Signed_imm_24,
    input [3:0] SR_in,          // Current SR {N, Z, C, V}
    output [31:0] ALU_Res,
    output [31:0] Br_addr,
    output [3:0] Status_Bits    // Combinational {N, Z, C, V} from ALU
);

    wire [31:0] Val2;
    wire [31:0] sign_ext_imm24;

    // 1. Val2 Generator
    Val2Generator u_Val2Generator (
        .Val_Rm(Val_Rm),
        .Shift_operand(Shift_operand),
        .imm(imm),
        .MEM_R_EN(MEM_R_EN),
        .MEM_W_EN(MEM_W_EN),
        .Val2(Val2)
    );

    // 2. ALU (C_in is bit 1 of SR = {N, Z, C, V})
    ALU u_ALU (
        .Val1(Val_Rn),
        .Val2(Val2),
        .EXE_CMD(EXE_CMD),
        .C_in(SR_in[1]),
        .ALU_Res(ALU_Res),
        .Status_Bits(Status_Bits)
    );

    // 3. Branch Address Adder: PC + SignExtend(Signed_imm_24)
    assign sign_ext_imm24 = {{8{Signed_imm_24[23]}}, Signed_imm_24};
    assign Br_addr = PC_in + sign_ext_imm24;

endmodule


module EXE_Stage_Reg (
    input clk,
    input rst,
    input WB_EN_in,
    input MEM_R_EN_in,
    input MEM_W_EN_in,
    input [31:0] ALU_Res_in,
    input [31:0] Val_Rm_in,
    input [3:0] Dest_in,
    output reg WB_EN,
    output reg MEM_R_EN,
    output reg MEM_W_EN,
    output reg [31:0] ALU_Res,
    output reg [31:0] Val_Rm,
    output reg [3:0] Dest
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            WB_EN    <= 1'b0;
            MEM_R_EN <= 1'b0;
            MEM_W_EN <= 1'b0;
            ALU_Res  <= 32'd0;
            Val_Rm   <= 32'd0;
            Dest     <= 4'd0;
        end else begin
            WB_EN    <= WB_EN_in;
            MEM_R_EN <= MEM_R_EN_in;
            MEM_W_EN <= MEM_W_EN_in;
            ALU_Res  <= ALU_Res_in;
            Val_Rm   <= Val_Rm_in;
            Dest     <= Dest_in;
        end
    end

endmodule