`timescale 1ns / 1ps
module Condition_Check_TB();
    reg  [3:0] cond, SR;       // SR = {N,Z,C,V}
    wire       ok;
    reg        exp;
    integer c, s, errors = 0;
    wire N = SR[3], Z = SR[2], C = SR[1], V = SR[0];

    Condition_Check uut (.cond(cond), .SR(SR), .cond_ok(ok));

    initial begin
        for (c = 0; c < 16; c = c + 1)
            for (s = 0; s < 16; s = s + 1) begin
                cond = c; SR = s; #1;
                case (c)
                    0:  exp = Z;            1:  exp = !Z;
                    2:  exp = C;            3:  exp = !C;
                    4:  exp = N;            5:  exp = !N;
                    6:  exp = V;            7:  exp = !V;
                    8:  exp = C && !Z;      9:  exp = !C || Z;
                    10: exp = (N == V);     11: exp = (N != V);
                    12: exp = !Z && (N == V); 13: exp = Z || (N != V);
                    14: exp = 1;            default: exp = 0;
                endcase
                if (ok !== exp) begin errors = errors + 1; $display("FAIL cond=%b SR=%b", cond, SR); end
            end
        $display("Condition_Check: %0d error(s)", errors);
        $finish;
    end
endmodule
