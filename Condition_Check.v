`timescale 1ns / 1ps

// Condition Check: evaluates the 4-bit cond field against the status register (Table 3).
// SR = {N, Z, C, V}
module Condition_Check (
    input  [3:0] cond,
    input  [3:0] SR,
    output reg   cond_ok
);

    wire N = SR[3];
    wire Z = SR[2];
    wire C = SR[1];
    wire V = SR[0];

    always @(*) begin
        case (cond)
            4'b0000: cond_ok = Z;                       // EQ
            4'b0001: cond_ok = ~Z;                      // NE
            4'b0010: cond_ok = C;                       // CS/HS
            4'b0011: cond_ok = ~C;                      // CC/LO
            4'b0100: cond_ok = N;                       // MI
            4'b0101: cond_ok = ~N;                      // PL
            4'b0110: cond_ok = V;                       // VS
            4'b0111: cond_ok = ~V;                      // VC
            4'b1000: cond_ok = C & ~Z;                  // HI
            4'b1001: cond_ok = ~C | Z;                  // LS
            4'b1010: cond_ok = (N == V);                // GE
            4'b1011: cond_ok = (N != V);                // LT
            4'b1100: cond_ok = ~Z & (N == V);           // GT
            4'b1101: cond_ok = Z | (N != V);            // LE
            4'b1110: cond_ok = 1'b1;                    // AL
            default: cond_ok = 1'b0;                    // 1111: not implemented
        endcase
    end

endmodule
