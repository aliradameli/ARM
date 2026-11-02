module ID_Stage_Reg (
    input         clk,
    input         rst,
    input  [31:0] PC_in,
    input         WB_EN_in,
    input         MEM_R_EN_in,
    input         MEM_W_EN_in,
    input  [3:0]  EXE_CMD_in,
    input         B_in,
    input         S_in,
    input  [31:0] Val_Rn_in,
    input  [31:0] Val_Rm_in,
    input         imm_in,
    input  [11:0] Shift_operand_in,
    input  [23:0] Signed_imm_24_in,
    input  [3:0]  Dest_in,
    output reg [31:0] PC,
    output reg        WB_EN,
    output reg        MEM_R_EN,
    output reg        MEM_W_EN,
    output reg [3:0]  EXE_CMD,
    output reg        B,
    output reg        S,
    output reg [31:0] Val_Rn,
    output reg [31:0] Val_Rm,
    output reg        imm,
    output reg [11:0] Shift_operand,
    output reg [23:0] Signed_imm_24,
    output reg [3:0]  Dest
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PC            <= 32'd0;
            WB_EN         <= 1'b0;
            MEM_R_EN      <= 1'b0;
            MEM_W_EN      <= 1'b0;
            EXE_CMD       <= 4'd0;
            B             <= 1'b0;
            S             <= 1'b0;
            Val_Rn        <= 32'd0;
            Val_Rm        <= 32'd0;
            imm           <= 1'b0;
            Shift_operand <= 12'd0;
            Signed_imm_24 <= 24'd0;
            Dest          <= 4'd0;
        end else begin
            PC            <= PC_in;
            WB_EN         <= WB_EN_in;
            MEM_R_EN      <= MEM_R_EN_in;
            MEM_W_EN      <= MEM_W_EN_in;
            EXE_CMD       <= EXE_CMD_in;
            B             <= B_in;
            S             <= S_in;
            Val_Rn        <= Val_Rn_in;
            Val_Rm        <= Val_Rm_in;
            imm           <= imm_in;
            Shift_operand <= Shift_operand_in;
            Signed_imm_24 <= Signed_imm_24_in;
            Dest          <= Dest_in;
        end
    end
endmodule
