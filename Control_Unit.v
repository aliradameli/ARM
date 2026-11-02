`timescale 1ns / 1ps

// Control Unit (ID stage)
// CtrlOut = {WB_EN, MEM_R_EN, MEM_W_EN, EXE_CMD[3:0], B, S_OUT}  (9 bits)
// uncond_* are the raw (un-muxed) memory enables, as in the diagram.
module ControlUnit (
    input        S,
    input  [3:0] Opcode,
    input  [1:0] Mode,
    output [8:0] CtrlOut,
    output       uncond_MEM_R_EN,
    output       uncond_MEM_W_EN,
    output       WB_EN,
    output       MEM_R_EN,
    output       MEM_W_EN,
    output [3:0] EXE_CMD,
    output       B,
    output       S_OUT
);

    // Mode
    localparam MODE_ARITH  = 2'b00;
    localparam MODE_MEM    = 2'b01;
    localparam MODE_BRANCH = 2'b10;

    // Opcodes
    localparam OP_MOV = 4'b1101, OP_MVN = 4'b1111, OP_ADD = 4'b0100,
               OP_ADC = 4'b0101, OP_SUB = 4'b0010, OP_SBC = 4'b0110,
               OP_AND = 4'b0000, OP_ORR = 4'b1100, OP_EOR = 4'b0001,
               OP_CMP = 4'b1010, OP_TST = 4'b1000;

    // EXE_CMD (ALU commands)
    localparam EXE_MOV = 4'b0001, EXE_MVN = 4'b1001, EXE_ADD = 4'b0010,
               EXE_ADC = 4'b0011, 8EXE_SUB = 4'b0100, EXE_SBC = 4'b0101,
               EXE_AND = 4'b0110, EXE_ORR = 4'b0111, EXE_EOR = 4'b1000;

    reg       wb_en, mem_r, mem_w, b, s_o;
    reg [3:0] exe_cmd;

    always @(*) begin
        wb_en = 1'b0; mem_r = 1'b0; mem_w = 1'b0;
        b = 1'b0; s_o = 1'b0; exe_cmd = 4'b0000;

        case (Mode)
            MODE_ARITH: begin
                s_o = S;
                case (Opcode)
                    OP_MOV: begin exe_cmd = EXE_MOV; wb_en = 1'b1; end
                    OP_MVN: begin exe_cmd = EXE_MVN; wb_en = 1'b1; end
                    OP_ADD: begin exe_cmd = EXE_ADD; wb_en = 1'b1; end
                    OP_ADC: begin exe_cmd = EXE_ADC; wb_en = 1'b1; end
                    OP_SUB: begin exe_cmd = EXE_SUB; wb_en = 1'b1; end
                    OP_SBC: begin exe_cmd = EXE_SBC; wb_en = 1'b1; end
                    OP_AND: begin exe_cmd = EXE_AND; wb_en = 1'b1; end
                    OP_ORR: begin exe_cmd = EXE_ORR; wb_en = 1'b1; end
                    OP_EOR: begin exe_cmd = EXE_EOR; wb_en = 1'b1; end
                    OP_CMP: begin exe_cmd = EXE_SUB; end  // flags only, no WB
                    OP_TST: begin exe_cmd = EXE_AND; end  // flags only, no WB
                    default: ;
                endcase
            end

            MODE_MEM: begin
                exe_cmd = EXE_ADD;          // address = Rn + offset
                if (S) begin                // LDR (S=1)
                    mem_r = 1'b1;
                    wb_en = 1'b1;
                end else begin              // STR (S=0)
                    mem_w = 1'b1;
                end
            end

            MODE_BRANCH: b = 1'b1;

            default: ;
        endcase
    end

    assign uncond_MEM_R_EN = mem_r;
    assign uncond_MEM_W_EN = mem_w;

    assign WB_EN    = wb_en;
    assign MEM_R_EN = mem_r;
    assign MEM_W_EN = mem_w;
    assign EXE_CMD  = exe_cmd;
    assign B        = b;
    assign S_OUT    = s_o;

    assign CtrlOut = {wb_en, mem_r, mem_w, exe_cmd, b, s_o};

endmodule