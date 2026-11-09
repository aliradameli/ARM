`timescale 1ns / 1ps

module ALU (
    input  [31:0] Val1,
    input  [31:0] Val2,
    input  [3:0]  EXE_CMD,
    input         C_in,
    output reg [31:0] ALU_Res,       // Capitalized 'R' to match your EXE_Stage instantiation
    output [3:0]  Status_Bits        // {N, Z, C, V}
);

    reg c_out, v_out;

    always @(*) begin
        ALU_Res = 32'b0;
        c_out   = 1'b0;
        v_out   = 1'b0;

        case (EXE_CMD)
            4'b0001: ALU_Res = Val2;                 // MOV
            4'b1001: ALU_Res = ~Val2;                // MVN

            4'b0010: begin // ADD, LDR, STR
                {c_out, ALU_Res} = {Val1} + { Val2};
                v_out = (Val1[31] == Val2[31]) && (ALU_Res[31] != Val1[31]);
            end

            4'b0011: begin // ADC
                {c_out, ALU_Res} = {Val1} + {Val2} + C_in;
                v_out = (Val1[31] == Val2[31]) && (ALU_Res[31] != Val1[31]);
            end

            4'b0100: begin // SUB, CMP
                {c_out, ALU_Res} = Val1 - Val2;
                v_out = (Val1[31] != Val2[31]) && (ALU_Res[31] != Val1[31]);
            end
            

            4'b0101: begin // SBC: Val1 - Val2 - ~C_in
                {c_out, ALU_Res} = {Val1} - {Val2} - ~{C_in};
                c_out = ~c_out; // Invert borrow to get ARM Carry flag
                v_out = (Val1[31] != Val2[31]) && (ALU_Res[31] != Val1[31]);
            end

            4'b0110: ALU_Res = Val1 & Val2;          // AND, TST
            4'b0111: ALU_Res = Val1 | Val2;          // ORR
            4'b1000: ALU_Res = Val1 ^ Val2;          // EOR

            default: begin
                ALU_Res = 32'b0;
                c_out   = 1'b0;
                v_out   = 1'b0;
            end
        endcase
    end

    wire N = ALU_Res[31];
    wire Z = (ALU_Res == 32'b0);

    // Standard ARM flag order: N, Z, C, V
    assign Status_Bits = {Z, c_out, N, v_out};

endmodule