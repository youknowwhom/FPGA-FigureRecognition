`timescale 1ns / 1ps

// 7¶ÎÊıÂë¹Ü²âÊÔÄ£¿é
module display7_tb(
    );
    
    reg clk;
    wire [7:0] ena;
    wire [6:0] segment;
    
    initial
    begin
        clk = 0;
        forever #1 clk = ~clk;
    end
    
    display7 dis7(
        .clk,
        .num1(4'h7),
        .num2(4'h3),
        .num3(4'hF),
        .num4(4'h0),
        .enable(ena),
        .segment(segment)
   );
    
endmodule
