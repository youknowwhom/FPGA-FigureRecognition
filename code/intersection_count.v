`timescale 1ns / 1ps

module intersection_count(
    input				clk,
    input               reset,
    input               vsync,
    input               href,
    input               clken,
    input               bin,                // 输入的二值化bit信号（黑色为1，白色为0）
    input   [10:0]      line_top,           // 识别出的数字定位框线
    input   [10:0]      line_bottom,
    input   [10:0]      line_left,
    input   [10:0]      line_right,
    output reg [3:0]    v_cnt,              // 与竖直分割线的交点个数
    output reg [3:0]    h_cnt1,             // 与水平分割线1的交点个数
    output reg [3:0]    h_cnt2,             // 与水平分割线2的交点个数
    output reg          h1,                 // 最后一与水平分割线的交点个数个交点在中轴线左侧还是右侧
    output reg          h2
    );

    // 参数定义 画面宽高
    parameter    DISPLAY_WIDTH  = 10'd640;
    parameter    DISPLAY_HEIGHT = 10'd480;
    
    // 行场计数
    reg  [10:0] x_cnt;      
    reg  [10:0] y_cnt;
    
    reg         v_reg0, v_reg1, v_reg2, v_reg3;
    reg         h1_reg0, h1_reg1, h1_reg2, h1_reg3;
    reg         h2_reg0, h2_reg1, h2_reg2, h2_reg3;
    
    // 寄存与割线的交点个数
    reg [3:0]   vcnt;
    reg [3:0]   hcnt1;
    reg [3:0]   hcnt2;
    reg         h1_pst;
    reg         h2_pst;
    
    // 辅助计算的参考数值
    wire [10:0] fig_width  = line_right - line_left;
    wire [10:0] fig_height = line_bottom - line_top;
    wire [10:0] fig_vdiv   = line_left + fig_width * 8 / 15;
    wire [10:0] fig_hdiv1  = line_top + fig_height * 3 / 10;
    wire [10:0] fig_hdiv2  = line_top + fig_height * 7 / 10;  

    // 对行场方向分别计数用于投影    
    always@(posedge clk or posedge reset)
    begin
        if(reset)
            begin
                x_cnt <= 10'd0;
                y_cnt <= 10'd0;
            end
        else
            if(vsync == 0)
            begin
                x_cnt <= 10'd0;
                y_cnt <= 10'd0;
            end
            else if(clken) 
            begin
                if(x_cnt < DISPLAY_WIDTH - 1) 
                begin
                    x_cnt <= x_cnt + 1'b1;
                    y_cnt <= y_cnt;
                end
                else 
                begin
                    x_cnt <= 10'd0;
                    y_cnt <= y_cnt + 1'b1;
                end
            end
    end
    
    // 寄存竖直中轴割线上的像素
    always@(posedge clk or posedge reset)
    begin
        if(reset)
        begin
            v_reg0 <= 1'b0;
            v_reg1 <= 1'b0;
            v_reg2 <= 1'b0;
            v_reg3 <= 1'b0;
        end
        // 新的一帧开始 清空计数
        else if(x_cnt == 1 && y_cnt == 1)
        begin
            v_reg0 <= 1'b0;
            v_reg1 <= 1'b0;
            v_reg2 <= 1'b0;
            v_reg3 <= 1'b0;
        end
        else if(clken)
        begin
            // 新的一帧开始
            if((x_cnt == fig_vdiv) && (y_cnt > line_top) && (y_cnt < line_bottom))
            begin
                v_reg0 <= v_reg1;
                v_reg1 <= v_reg2;
                v_reg2 <= v_reg3;
                v_reg3 <= bin;
            end
        end
    end
    
    
    // 寄存水平第一条割线上的像素
    always@(posedge clk or posedge reset)
    begin
        if(reset)
        begin
            h1_reg0 <= 1'b0;
            h1_reg1 <= 1'b0;
            h1_reg2 <= 1'b0;
            h1_reg3 <= 1'b0;
        end
        // 新的一帧开始 清空计数
        else if(x_cnt == 1 && y_cnt == 1)
        begin
            h1_reg0 <= 1'b0;
            h1_reg1 <= 1'b0;
            h1_reg2 <= 1'b0;
            h1_reg3 <= 1'b0;
        end
        else if(clken)
        begin
            // 新的一帧开始
            if((y_cnt == fig_hdiv1) && (x_cnt > line_left) && (x_cnt < line_right))
            begin
                h1_reg0 <= h1_reg1;
                h1_reg1 <= h1_reg2;
                h1_reg2 <= h1_reg3;
                h1_reg3 <= bin;
            end
        end
    end
    
    // 寄存水平第二条割线上的像素
    always@(posedge clk or posedge reset)
    begin
        if(reset)
        begin
            h2_reg0 <= 1'b0;
            h2_reg1 <= 1'b0;
            h2_reg2 <= 1'b0;
            h2_reg3 <= 1'b0;
        end
        // 新的一帧开始 清空计数
        else if(x_cnt == 1 && y_cnt == 1)
        begin
            h2_reg0 <= 1'b0;
            h2_reg1 <= 1'b0;
            h2_reg2 <= 1'b0;
            h2_reg3 <= 1'b0;
        end
        else if(clken)
        begin
            // 新的一帧开始
            if((y_cnt == fig_hdiv2) && (x_cnt > line_left) && (x_cnt < line_right))
            begin
                h2_reg0 <= h2_reg1;
                h2_reg1 <= h2_reg2;
                h2_reg2 <= h2_reg3;
                h2_reg3 <= bin;
            end
        end
    end
    
    // 竖直中轴线交点计数
    always@(posedge clk or posedge reset)
    begin
        if(reset)
            vcnt <= 4'b0;
        // 新的一帧开始
        else if((x_cnt == 1) && (y_cnt == 1))
            vcnt <= 4'b0;
        else if(clken)
        begin
            // 多加几个像素点是以减小干扰
            if(v_reg0 == 0 && v_reg1 == 0 && v_reg2 == 0 && v_reg3 == 1 
            && (x_cnt == fig_vdiv) 
            && (y_cnt > line_top) && (y_cnt < line_bottom))
            begin
                vcnt <= vcnt + 1;
            end
        end
    end
    
    // 水平第一条割线交点计数
    always@(posedge clk or posedge reset)
    begin
        if(reset)
            hcnt1 <= 4'b0;
        // 新的一帧开始
        else if((x_cnt == 1) && (y_cnt == 1))
            hcnt1 <= 4'b0;
        else if(clken)
        begin
           //多加几个像素点是以减小干扰
           if(h1_reg0 == 0 && h1_reg1 == 0 && h1_reg2 == 0 && h1_reg3 == 1 
           && (y_cnt == fig_hdiv1) 
           && (x_cnt > line_left) && (x_cnt < line_right))
           begin
               hcnt1 <= hcnt1 + 1;
               h1_pst = (x_cnt < fig_vdiv);
           end
        end
    end
    
    // 水平第二条割线交点计数
    always@(posedge clk or posedge reset)
    begin
        if(reset)
            hcnt2 <= 4'b0;
        // 新的一帧开始
        else if((x_cnt == 1) && (y_cnt == 1))
            hcnt2 <= 4'b0;
        else if(clken)
        begin
           //多加几个像素点是以减小干扰
           if(h2_reg0 == 0 && h2_reg1 == 0 && h2_reg2 == 0 && h2_reg3 == 1 
           && (y_cnt == fig_hdiv2) 
           && (x_cnt > line_left) && (x_cnt < line_right))
           begin
               hcnt2 <= hcnt2 + 1;
               h2_pst = (x_cnt < fig_vdiv);
           end
        end
    end
    
    always@(posedge clk or posedge reset)
    begin
        if(reset)
        begin
            v_cnt  <= 4'b0;
            h_cnt1 <= 4'b0;
            h_cnt2 <= 4'b0;
            h1     <= 1'b0;
            h2     <= 1'b0;
        end
        else if(vsync == 0)
        begin
            v_cnt  <= vcnt;
            h_cnt1 <= hcnt1;
            h_cnt2 <= hcnt2;
            h1     <= h1_pst;
            h2     <= h2_pst;
        end
    end
    
endmodule
