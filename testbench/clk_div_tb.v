`timescale 1ns / 1ps

// ≤‚ ‘ ±÷”∑÷∆µƒ£øÈ
module clk_div_tb(
    );
    
    reg clk_in;
    wire clk_vga;
    wire clk_sccb;
    
    initial
    begin
        clk_in = 0;
        forever #5 clk_in = ~clk_in;
    end
    
    clk_divider clk_div(
    .clk_in1(clk_in),
    .clk_vga(clk_vga),
    .clk_sccb(clk_sccb)
    );
    
endmodule
