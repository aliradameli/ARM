`timescale 1ns / 1ps

module ARM_FPGA_wrapper (
    input clk,
    input key1
);

    wire deb_out, rst;

    debouncer deb_inst (
        .SIGNAL_I(key1),
        .CLK_I(clk),
        .SIGNAL_O(deb_out)
    );

    assign rst = ~deb_out;

    ARM ARM_inst (
        .clk(clk),
        .rst(rst)
    );

    ila_0 ila_inst (
        .clk(clk),                          // input wire clk
        .probe0(rst),                       // input wire [0:0]  probe0
        .probe1(ARM_inst.IF_pc),            // input wire [31:0] probe1
        .probe2(ARM_inst.ID_pc),            // input wire [31:0] probe2
        .probe3(ARM_inst.EXE_pc),           // input wire [31:0] probe3
        .probe4(ARM_inst.MEM_pc),           // input wire [31:0] probe4
        .probe5(ARM_inst.WB_pc),            // input wire [31:0] probe5
        .probe6(ARM_inst.ID_instruction),   // input wire [31:0] probe6
        .probe7(ARM_inst.id_B),                 // [0:0]
        .probe8(ARM_inst.id_S),                 // [0:0]
        .probe9(ARM_inst.id_imm),               // [0:0]
        .probe10(ARM_inst.id_WB_EN),            // [0:0]
        .probe11(ARM_inst.id_Two_src),          // [0:0]
        .probe12(ARM_inst.id_MEM_W_EN),         // [0:0]
        .probe13(ARM_inst.id_MEM_R_EN),         // [0:0]
        .probe14(ARM_inst.id_Dest),             // [3:0]
        .probe15(ARM_inst.id_EXE_CMD),          // [3:0]
        .probe16(ARM_inst.id_src_1),            // [3:0]
        .probe17(ARM_inst.id_src_2),            // [3:0]
        .probe18(ARM_inst.id_Shift_operand),    // [11:0]
        .probe19(ARM_inst.id_Signed_imm_24),    // [23:0]
        .probe20(ARM_inst.id_Val_Rn),           // [31:0]
        .probe21(ARM_inst.id_Val_Rm)            // [31:0]
    );

endmodule