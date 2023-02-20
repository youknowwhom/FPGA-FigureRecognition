`timescale 1ns / 1ps

// 二值化
module binarization(
    input           clk,
    input           reset,
    input           org_href,
    input           org_vsync,
    input           org_clken,
    input [7:0]     grey,
    output reg      bin,
    output reg      out_href,
    output reg      out_vsync,
    output reg      out_clken
    );
    
    // 黑白的临界阈值
    parameter threshold = 50;
    
    // 二值化处理    
    always @ (posedge clk or posedge reset)
    begin
        if(reset)
            bin <= 0;
        else
        begin
            bin = (grey > threshold) ? 1'b1 : 1'b0;
        end
    end
    
    // 延迟一个周期
    always @ (posedge clk or posedge reset)
    begin
        if(reset)
        begin
            out_href  <= 0;
            out_vsync <= 0;
            out_clken <= 0;        
        end
        else
        begin
            out_href  <= org_href;
            out_vsync <= org_vsync;
            out_clken <= org_clken;      
        end
    end
    
endmodule
