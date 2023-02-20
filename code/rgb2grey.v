`timescale 1ns / 1ps


module rgb2grey(
    input               clk,
    input               reset,
    input               org_href,
    input               org_vsync,
    input               org_clken,
    input [11:0]        org_rgb,
    output reg [7:0]    grey,
    output              out_href,
    output              out_vsync,
    output              out_clken
    );
    
    /*********************
        线网与寄存器定义
    *********************/
    
    // RGB444补齐为RGB888
    wire [7:0] data_r = { org_rgb[11:8], 4'b0 };
    wire [7:0] data_g = { org_rgb[7:4],  4'b0 }; 
    wire [7:0] data_b = { org_rgb[3:0],  4'b0 }; 
    
    reg [15:0] red_0;
    reg [15:0] green_0;
    reg [15:0] blue_0;
    reg [15:0] grey_0;
    
    reg [2:0] post_href;
    reg [2:0] post_vsync;
    reg [2:0] post_clken;
    
    
    // 提取YCbCr的Y通道作为灰度输出
    
    // Step1: 乘法运算
    always @ (posedge clk or posedge reset)
    begin
        if(reset)
        begin
            red_0   <= 16'b0;
            green_0 <= 16'b0;
            blue_0  <= 16'b0;
        end
        else
        begin
            red_0   <= data_r * 8'd77;
            green_0 <= data_g * 8'd150;
            blue_0  <= data_b * 8'd29;
        end
    end
    
    // Step2: 加法运算
    always @ (posedge clk or posedge reset)
    begin
        if(reset)
            grey_0 <= 16'b0;
        else
            grey_0 <= red_0 + green_0 + blue_0;
    end
    
    // Step3: 移位运算
    always @ (posedge clk or posedge reset)
    begin
        if(reset)
            grey <= 8'b0;
        else
            grey <= grey_0[15:8];
    end    
    
    // 延迟3个时钟周期 
    always @ (posedge clk or posedge reset)
    begin
        if(reset)
        begin
            post_href  <= 3'b0;
            post_vsync <= 3'b0;
            post_clken <= 3'b0;
        end
        else
        begin
            post_href  <= { post_href[1:0],  org_href };
            post_vsync <= { post_vsync[1:0], org_vsync };
            post_clken <= { post_clken[1:0], org_clken };
        end
    end
    
    assign out_href = post_href[2];
    assign out_vsync = post_vsync[2];
    assign out_clken = post_clken[2];
    
endmodule
