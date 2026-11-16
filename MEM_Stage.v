`timescale 1ns / 1ps

module MEM_Stage (
    input clk,
    input rst,
    input MEM_R_EN,
    input MEM_W_EN,
    input [31:0] ALU_res,
    input [31:0] Val_Rm,
    output [31:0] Data_out
);

    // Assuming IP Depth = 1024 (10 address bits).
    // The IP uses word-addressing internally if configured that way, 
    // or byte-addressing. By default, Distributed RAM with 32-bit width 
    // uses word-addressing (index 0, 1, 2...). 
    wire [9:0] addr = ALU_res[9:0];

    // Data Memory Instantiation
    dist_mem_gen_1 mm_Data_Mem (
        .a(addr),              // input wire [9 : 0] a
        .d(Val_Rm),            // input wire [31 : 0] d
        .clk(clk),             // input wire clk
        .we(MEM_W_EN),         // input wire we
        .spo(Data_out)         // output wire [31 : 0] spo
    );

endmodule


module MEM_Stage_Reg (
    input clk,
    input rst,
    input WB_EN_in,
    input MEM_R_EN_in,
    input [31:0] ALU_res_in,
    input [31:0] Data_in,
    input [3:0] Dest_in,
    output reg WB_EN,
    output reg MEM_R_EN,
    output reg [31:0] ALU_res,
    output reg [31:0] Data,
    output reg [3:0] Dest
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            WB_EN    <= 1'b0;
            MEM_R_EN <= 1'b0;
            ALU_res  <= 32'd0;
            Data     <= 32'd0;
            Dest     <= 4'd0;
        end else begin
            WB_EN    <= WB_EN_in;
            MEM_R_EN <= MEM_R_EN_in;
            ALU_res  <= ALU_res_in;
            Data     <= Data_in;
            Dest     <= Dest_in;
        end
    end

endmodule