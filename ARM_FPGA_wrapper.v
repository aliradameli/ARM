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
        .clk(clk),                                              // input wire clk
        .probe0(rst),                                           // [0:0]  Trigger
        .probe1(ARM_inst.u_ID_Stage.u_RegisterFile.reg_file[1]), // [31:0] R1
        .probe2(ARM_inst.u_ID_Stage.u_RegisterFile.reg_file[2]), // [31:0] R2
        .probe3(ARM_inst.u_ID_Stage.u_RegisterFile.reg_file[3]), // [31:0] R3
        .probe4(ARM_inst.u_ID_Stage.u_RegisterFile.reg_file[4]), // [31:0] R4
        .probe5(ARM_inst.u_ID_Stage.u_RegisterFile.reg_file[5]), // [31:0] R5
        .probe6(ARM_inst.u_ID_Stage.u_RegisterFile.reg_file[6]), // [31:0] R6
        .probe7(ARM_inst.Hazard),                               // [0:0]  Hazard_Detected
        .probe8(ARM_inst.IF_pc)                                 // [31:0] Current PC
    );

endmodule