`timescale 1ns / 1ps

module ARM (
    input clk,
    input rst
);

    // Control inputs tied to 0 as required in Step 8 of the manual
    wire freeze = 1'b0;
    wire flush = 1'b0;
    wire Branch_taken = 1'b0;
    wire [31:0] BranchAddr = 32'd0;

    // Wires named to match the ILA wrapper on Page 10 of the manual
    wire [31:0] IF_pc, IF_instruction;
    wire [31:0] ID_pc, ID_instruction;
    wire [31:0] id_out_pc;
    wire [31:0] EXE_pc;
    wire [31:0] exe_out_pc;
    wire [31:0] MEM_pc;
    wire [31:0] mem_out_pc;
    wire [31:0] WB_pc;
    wire [31:0] wb_out_pc;

    // 1. IF Stage & IF/ID Pipeline Register
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

    // 2. ID Stage & ID/EXE Pipeline Register
    ID_Stage u_ID_Stage (
        .clk(clk),
        .rst(rst),
        .PC_in(ID_pc),
        .PC(id_out_pc)
    );

    ID_Stage_Reg u_ID_Stage_Reg (
        .clk(clk),
        .rst(rst),
        .PC_in(id_out_pc),
        .PC(EXE_pc)
    );

    // 3. EXE Stage & EXE/MEM Pipeline Register
    EXE_Stage u_EXE_Stage (
        .clk(clk),
        .rst(rst),
        .PC_in(EXE_pc),
        .PC(exe_out_pc)
    );

    EXE_Stage_Reg u_EXE_Stage_Reg (
        .clk(clk),
        .rst(rst),
        .PC_in(exe_out_pc),
        .PC(MEM_pc)
    );

    // 4. MEM Stage & MEM/WB Pipeline Register
    MEM_Stage u_MEM_Stage (
        .clk(clk),
        .rst(rst),
        .PC_in(MEM_pc),
        .PC(mem_out_pc)
    );

    MEM_Stage_Reg u_MEM_Stage_Reg (
        .clk(clk),
        .rst(rst),
        .PC_in(mem_out_pc),
        .PC(WB_pc)
    );

    // 5. WB Stage
    WB_Stage u_WB_Stage (
        .clk(clk),
        .rst(rst),
        .PC_in(WB_pc),
        .PC(wb_out_pc)
    );

endmodule