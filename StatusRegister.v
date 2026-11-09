`timescale 1ns / 1ps

module StatusRegister (
    input clk,
    input rst,
    input S,
    input [3:0] Status_in,
    output reg [3:0] SR
);

    always @(negedge clk or posedge rst) begin
        if (rst)
            SR <= 4'b0000;
        else if (S)
            SR <= Status_in;
    end

endmodule