`timescale 1ns / 1ps

module ID_Stage_TB();

    reg clk = 0;
    reg rst;
    reg [31:0] instr;
    reg hazard;
    reg [3:0] SR;

    wire [31:0] PC;
    wire [31:0] Val_Rn;
    wire [31:0] Val_Rm;

    wire WB_EN;
    wire MEM_R_EN;
    wire MEM_W_EN;
    wire B;
    wire S;
    wire imm;
    wire Two_src;

    wire [3:0] EXE_CMD;
    wire [3:0] Dest;
    wire [3:0] src_1;
    wire [3:0] src_2;

    wire [11:0] Shift_operand;
    wire [23:0] Signed_imm_24;

    integer errors = 0;

    ID_Stage uut (
        .clk(clk),
        .rst(rst),
        .PC_in(32'd0),
        .Instruction(instr),
        .Hazard(hazard),
        .SR(SR),
        .WB_Dest(4'd0),
        .WB_Value(32'd0),
        .WB_WB_EN(1'b0),
        .PC(PC),
        .WB_EN(WB_EN),
        .MEM_R_EN(MEM_R_EN),
        .MEM_W_EN(MEM_W_EN),
        .EXE_CMD(EXE_CMD),
        .B(B),
        .S(S),
        .Val_Rn(Val_Rn),
        .Val_Rm(Val_Rm),
        .imm(imm),
        .Shift_operand(Shift_operand),
        .Signed_imm_24(Signed_imm_24),
        .Dest(Dest),
        .src_1(src_1),
        .src_2(src_2),
        .Two_src(Two_src)
    );

    always #5 clk = ~clk;

    task check(
        input [255:0] name,
        input e_wb,
        input e_mr,
        input e_mw,
        input [3:0] e_cmd,
        input e_b,
        input e_s,
        input e_two
    );
        begin
            #1;
            if ({WB_EN, MEM_R_EN, MEM_W_EN, EXE_CMD, B, S, Two_src} !==
                {e_wb, e_mr, e_mw, e_cmd, e_b, e_s, e_two}) begin

                errors = errors + 1;

                $display(
                    "FAIL %0s: WB=%b MR=%b MW=%b CMD=%b B=%b S=%b Two=%b",
                    name,
                    WB_EN,
                    MEM_R_EN,
                    MEM_W_EN,
                    EXE_CMD,
                    B,
                    S,
                    Two_src
                );

            end else begin
                $display(
                    "PASS %0s: Rn=%0d Rm=%0d Dest=%0d",
                    name,
                    Val_Rn,
                    Val_Rm,
                    Dest
                );
            end
        end
    endtask

    initial begin

        rst = 1;
        hazard = 0;
        SR = 4'b0000;
        instr = 32'd0;

        #12 rst = 0;

        instr = 32'b1110_00_1_1101_0_0000_0000_000000010100;
        check("MOV R0, #20", 1, 0, 0, 4'b0001, 0, 0, 0);

        instr = 32'b1110_00_1_1101_0_0000_0001_101000000001;
        check("MOV R1, #4096", 1, 0, 0, 4'b0001, 0, 0, 0);

        instr = 32'b1110_00_1_1101_0_0000_0010_000100000011;
        check("MOV R2, #0xC0000000", 1, 0, 0, 4'b0001, 0, 0, 0);

        instr = 32'b1110_00_0_0100_1_0010_0011_000000000010;
        check("ADD R3, R2, R2", 1, 0, 0, 4'b0010, 0, 1, 1);

        instr = 32'b1110_00_0_0101_0_0000_0100_000000000000;
        check("ADC R4, R0, R0", 1, 0, 0, 4'b0011, 0, 0, 1);

        instr = 32'b1110_00_0_0010_0_0100_0101_000100000100;
        check("SUB R5, R4, R4, LSL #2", 1, 0, 0, 4'b0100, 0, 0, 1);

        instr = 32'b1110_00_0_0110_0_0000_0110_000010100000;
        check("SBC R6, R0, R0, LSR #1", 1, 0, 0, 4'b0101, 0, 0, 1);

        instr = 32'b1110_00_0_1100_0_0101_0111_000101000010;
        check("ORR R7, R5, R2, ASR #2", 1, 0, 0, 4'b0111, 0, 0, 1);

        instr = 32'b1110_00_0_0000_0_0111_1000_000000000011;
        check("AND R8, R7, R3", 1, 0, 0, 4'b0110, 0, 0, 1);

        instr = 32'b1110_00_0_1111_0_0000_1001_000000000110;
        check("MVN R9, R6", 1, 0, 0, 4'b1001, 0, 0, 1);

        instr = 32'b1110_00_0_0001_0_0100_1010_000000000101;
        check("EOR", 1, 0, 0, 4'b1000, 0, 0, 1);

        instr = 32'b1110_00_0_1010_1_1000_0000_000000000110;
        check("CMP R8, R6", 0, 0, 0, 4'b0100, 0, 1, 1);

        instr = 32'b1110_00_0_1000_1_1001_0000_000000001000;
        check("TST R9, R8", 0, 0, 0, 4'b0110, 0, 1, 1);

        instr = 32'b1110_01_0_0100_0_0000_0001_000000000000;
        check("STR R1, [R0], #0", 0, 0, 1, 4'b0010, 0, 0, 1);

        instr = 32'b1110_01_0_0100_1_0000_1011_000000000000;
        check("LDR R11, [R0], #0", 1, 1, 0, 4'b0010, 0, 0, 1);

        instr = 32'b1011_10_1_0_111111111111111111110111;
        SR = 4'b0000;
        check("BLT, N == V (killed)", 0, 0, 0, 4'b0000, 0, 0, 0);

        SR = 4'b1000;
        check("BLT, N != V (taken)", 0, 0, 0, 4'b0000, 1, 0, 0);

        SR = 4'b0000;
        instr = 32'b1110_10_1_0_111111111111111111111111;
        check("B #-1", 0, 0, 0, 4'b0000, 1, 0, 0);

        instr = 32'b0001_00_0_0100_0_0001_0001_000000000001;
        SR = 4'b0100;
        check("ADDNE, Z=1 (killed)", 0, 0, 0, 4'b0000, 0, 0, 1);

        SR = 4'b0000;
        check("ADDNE, Z=0 (runs)", 1, 0, 0, 4'b0010, 0, 0, 1);

        instr = 32'b1110_00_1_1101_0_0000_0000_000000010100;
        hazard = 1;
        check("MOV with Hazard", 0, 0, 0, 4'b0000, 0, 0, 0);
        hazard = 0;

        instr = 32'b1110_01_0_0100_0_0000_0111_000000000110;
        #1;

        if (src_2 !== 4'd7 || Val_Rm !== 32'd7 || Val_Rn !== 32'd0) begin
            errors = errors + 1;
            $display("FAIL STR src2 mux");
        end else begin
            $display("PASS STR src_2 = Dest (R7 = %0d)", Val_Rm);
        end

        instr = 32'b1110_00_0_0100_0_0000_0100_000000000011;
        #1;

        if (src_2 !== 4'd3 || Val_Rm !== 32'd3) begin
            errors = errors + 1;
            $display("FAIL ADD src2 mux");
        end else begin
            $display("PASS ADD src_2 = Rm (R3 = %0d)", Val_Rm);
        end

        $display("------------------------------");
        $display("%0d error(s)", errors);
        $display("------------------------------");

        $finish;

    end

endmodule