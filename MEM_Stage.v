`timescale 1ns / 1ps

module MEM_Stage (
    input clk,
    input rst,
    input [31:0] PC_in,
    output [31:0] PC
);
    assign PC = PC_in;
endmodule


module MEM_Stage_Reg (
    input clk,
    input rst,
    input [31:0] PC_in,
    output reg [31:0] PC
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            PC <= 32'd0;
        else
            PC <= PC_in;
    end
endmodule