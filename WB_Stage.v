`timescale 1ns / 1ps

module WB_Stage (
    input MEM_R_EN,
    input [31:0] ALU_res,
    input [31:0] Data,
    output [31:0] Result_WB
);

    assign Result_WB = MEM_R_EN ? Data : ALU_res;

endmodule