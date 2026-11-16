`timescale 1ns / 1ps

module HazardDetectionUnit (
    input [3:0] src1,
    input [3:0] src2,
    input Two_src,
    input EXE_WB_EN,
    input [3:0] EXE_Dest,
    input MEM_WB_EN,
    input [3:0] MEM_Dest,
    output reg Hazard
);

    always @(*) begin
        Hazard = 1'b0;

        // 1. Hazard with EXE stage
        if (EXE_WB_EN && (src1 == EXE_Dest))
            Hazard = 1'b1;
        if (EXE_WB_EN && Two_src && (src2 == EXE_Dest))
            Hazard = 1'b1;

        // 2. Hazard with MEM stage
        if (MEM_WB_EN && (src1 == MEM_Dest))
            Hazard = 1'b1;
        if (MEM_WB_EN && Two_src && (src2 == MEM_Dest))
            Hazard = 1'b1;
    end

endmodule