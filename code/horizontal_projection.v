`timescale 1ns / 1ps

module horizontal_projection(
	input				clk,                // 像素时钟
	input				reset,              // 复位信号
	input				vsync,              // 帧同步
	input				href,               // 行参考
	input				clken,              // 像素使能
	input				bin,                // 输入的二值化bit信号（黑色为1，白色为0）
	input      [10:0]   line_left,          // 数字左右框线
	input      [10:0]   line_right,
    output reg [10:0] 	line_top,           // 数字上下框线
    output reg [10:0] 	line_bottom
);

	parameter	DISPLAY_WIDTH  = 10'd640;
	parameter	DISPLAY_HEIGHT = 10'd480;

    /*********************
        线网与寄存器定义
    *********************/
    
    // 行场计数
    reg [10:0]  	x_cnt;      
    reg [10:0]      y_cnt;
    
    // 寄存行水平投影
    reg [9:0]       tot;       
    reg [9:0]       tot1;
    reg [9:0]       tot2;
    reg [9:0]       tot3;
    
    // 寄存上升沿下降沿位置
    reg [10:0]      topline1;
    reg [10:0]      bottomline1;


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

    // 每一行进行计数  
    always@(posedge clk or posedge reset)
    begin
        if(reset)
            tot <= 10'b0;
        else if(clken)
        begin
            if(x_cnt == 0)
                tot <= 10'b0;
            // 只在数字范围内进行投影
            else if(x_cnt > line_left && x_cnt < line_right)
                tot <= tot + bin;
        end
    end

    // 寄存3级 用于后续判断上升下降沿
    always @ (posedge clk or posedge reset) 
    begin
        if(reset) 
        begin
            tot1 <= 10'd0;
            tot2 <= 10'd0;
            tot3 <= 10'b0;
        end
        else if(clken && x_cnt == DISPLAY_WIDTH - 1) 
        begin
            tot1 <= tot;
            tot2 <= tot1;
            tot3 <= tot2;
        end
    end
    
    always @ (posedge clk or posedge reset) 
    begin
        if(reset) 
        begin
            topline1    <= 10'd0;
            bottomline1 <= 10'd0;
        end
        else if(clken) 
        begin
            // 最后一行开始统计上升下降沿
            if(x_cnt == DISPLAY_WIDTH - 1'b1) 
            begin    
                if((tot3 == 10'd0) && (tot > 10'd10))
                    topline1 <= y_cnt - 3;            
                
                if((tot3 > 10'd10) && (tot == 10'd0))
                    bottomline1 <= y_cnt - 3;
            end
        end
    end
    
    // 一帧写入完毕后 再更新线条位置
    always @ (posedge clk or posedge reset) 
    begin
        if(reset) 
        begin
            line_top    <= 10'd0;
            line_bottom <= 10'd0;
        end
        else if(vsync == 0) 
        begin
            line_top    <= topline1;
            line_bottom <= bottomline1;
        end  
    end

endmodule
