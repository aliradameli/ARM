`timescale 1ns / 1ps

module IF_Stage (
    input clk,
    input rst,
    input freeze,
    input Branch_taken,
    input [31:0] BranchAddr,
    output [31:0] PC,
    output [31:0] Instruction
);

    reg  [31:0] PC_Reg;
    wire [31:0] PC_Plus_1;
    wire [31:0] Next_PC;

    // 1. Adder: Word-addressable memory increments PC by 1
    assign PC_Plus_1 = PC_Reg + 32'd1;

    // 2. MUX: Choose between PC + 1 and BranchAddr
    assign Next_PC = Branch_taken ? BranchAddr : PC_Plus_1;

    // 3. PC Register: Resets to 0 on rst, holds value if freeze is 1
    always @(posedge clk or posedge rst) begin
        if (rst)
            PC_Reg <= 32'd0;
        else if (!freeze)
            PC_Reg <= Next_PC;
    end

    // Output PC to next stage (tapped after the +1 adder per schematic)
    assign PC = PC_Plus_1;

    // 4. Instruction Memory IP Core Instantiation
    // (If you set Depth = 1024 instead of 2048, change PC_Reg[10:0] to PC_Reg[9:0])
    dist_mem_gen_0 Inst_Mem (
        .a(PC_Reg[10:0]),      // input wire [10 : 0] a
        .spo(Instruction)      // output wire [31 : 0] spo
    );

endmodule


module IF_Stage_Reg (
    input clk,
    input rst,
    input freeze,
    input flush,
    input [31:0] PC_in,
    input [31:0] Instruction_in,
    output reg [31:0] PC,
    output reg [31:0] Instruction
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PC <= 32'd0;
            Instruction <= 32'd0;
        end else if (flush) begin
            PC <= 32'd0;
            Instruction <= 32'd0;
        end else if (!freeze) begin
            PC <= PC_in;
            Instruction <= Instruction_in;
        end
    end

endmodule