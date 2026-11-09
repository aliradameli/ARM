

`timescale 1ns / 1ps

module Val2Generator (
    input  [31:0] Val_Rm,
    input  [11:0] Shift_operand,     // Capitalized 'S' to match ID stage output
    input         imm,
    input         MEM_R_EN,          // Replaced 'is_mem' with the exact control signals
    input         MEM_W_EN,
    output reg [31:0] Val2
);

    wire is_mem = MEM_R_EN | MEM_W_EN;

    // Immediate rotation fields
    wire [7:0]  immed_8    = Shift_operand[7:0];
    wire [3:0]  rotate_imm = Shift_operand[11:8];
    wire [4:0]  rot_amt    = {rotate_imm, 1'b0}; // 2 * rotate_imm
    wire [63:0] imm_concat = {24'b0, immed_8, 24'b0, immed_8};

    // Register shift fields
    wire [4:0]  shift_imm  = Shift_operand[11:7];
    wire [1:0]  shift_type = Shift_operand[6:5];
    wire [63:0] rm_concat  = {Val_Rm, Val_Rm};

    always @(*) begin
        if (is_mem) begin
            // Sign extension for memory offset (LDR/STR)
            Val2 = {{20{Shift_operand[11]}}, Shift_operand};
        end else if (imm) begin
            // Immediate data processing rotation
            if (rot_amt == 5'd0)
                Val2 = {24'b0, immed_8};
            else
                Val2 = imm_concat[rot_amt +: 32];
        end else begin
            // Register data processing shifts
            case (shift_type)
                2'b00: Val2 = Val_Rm << shift_imm;                        // LSL
                2'b01: Val2 = Val_Rm >> shift_imm;                        // LSR
                2'b10: Val2 = $signed(Val_Rm) >>> shift_imm;              // ASR
                2'b11: begin                                              // ROR
                    if (shift_imm == 5'd0)
                        Val2 = Val_Rm;
                    else
                        Val2 = rm_concat[shift_imm +: 32];
                end
            endcase
        end
    end

endmodule