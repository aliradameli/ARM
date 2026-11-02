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
        .probe6(ARM_inst.ID_instruction)    // input wire [31:0] probe6
    );

endmodule