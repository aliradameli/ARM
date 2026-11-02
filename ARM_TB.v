`timescale 1ns / 1ps

module ARM_TB();

    reg clk;
    reg rst;

    // Instantiate the ARM Top-Level Black Box
    ARM uut (
        .clk(clk),
        .rst(rst)
    );

    // Clock generation: 10ns period (toggles every 5ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reset and test stimulus
    initial begin
        rst = 1;
        #22;        // Hold reset high across two rising clock edges
        rst = 0;    // Release reset -> pipeline starts counting & shifting!
        #150;       // Run for 15 clock cycles
        $stop;
    end

endmodule