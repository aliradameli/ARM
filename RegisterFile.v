`timescale 1ns / 1ps

module RegisterFile (
    input clk,
    input rst,
    input [3:0] src_1,
    input [3:0] src_2,
    input [3:0] Dest_WB,
    input [31:0] Result_WB,
    input writeBackEN,
    output [31:0] reg_out_1,
    output [31:0] reg_out_2
);

    reg [31:0] reg_file [0:14];
    integer i;

    
    always @(negedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 15; i = i + 1) begin
                reg_file[i] <= i; 
            end
        end else if (writeBackEN && (Dest_WB < 4'd15)) begin
            reg_file[Dest_WB] <= Result_WB;
        end
    end

    assign reg_out_1 = (src_1 < 4'd15) ? reg_file[src_1] : 32'd0;
    assign reg_out_2 = (src_2 < 4'd15) ? reg_file[src_2] : 32'd0;

endmodule