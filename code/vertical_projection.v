`timescale 1ns / 1ps

module vertical_projection(
	input				clk,                // 像素时钟
	input				reset,              // 复位信号
	input				vsync,              // 帧同步
	input				href,               // 行参考
	input				clken,              // 像素有效信号
	input				bin,                // 输入的二值化bit信号（黑色为1，白色为0）

    output reg [10:0] 	line_left1,		    // 数字的左右框线
    output reg [10:0] 	line_right1,
    output reg [10:0]   line_left2,
    output reg [10:0]   line_right2,
    output reg [10:0]   line_left3,
    output reg [10:0]   line_right3,
    output reg [10:0]   line_left4,
    output reg [10:0]   line_right4
);

	parameter	DISPLAY_WIDTH  = 10'd640;
	parameter	DISPLAY_HEIGHT = 10'd480;

    /*********************
        线网与寄存器定义
    *********************/
    
    reg [10:0]  	x_cnt;           // 行场计数
    reg [10:0]      y_cnt;
    reg [10:0]  	reg_x_cnt;       // 行场计数寄存
    reg [10:0]      reg_y_cnt;

    reg  		    ram_wr_ena;
    wire [9:0] 	    ram_wr_data;
    wire [9:0] 	    ram_rd_data;

    reg             reg_bin;        // 寄存bit信号

    reg [9:0]       rd_data1;       // 读到的信号寄存数个周期
    reg [9:0]       rd_data2;
    reg [9:0]       rd_data3;
    reg [9:0]       rd_data4;
    reg [9:0]       rd_data5;
    reg [9:0]       rd_data6;
    reg [9:0]       rd_data7;

    reg [10:0]      leftline1;      // 寄存左右框线
    reg [10:0]      rightline1;
    reg [10:0]      leftline2;
    reg [10:0]      rightline2;
    reg [10:0]      leftline3;
    reg [10:0]      rightline3;
    reg [10:0]      leftline4;
    reg [10:0]      rightline4;
    reg [10:0]      lastposline;
    reg [10:0]      lastnegline;
    
    reg [3:0]       posedge_cnt;    // 上升沿计数
    reg [3:0]       negedge_cnt;    // 下降沿计数

    // 输入的二值化信号打一排 用于写入ram
    always@(posedge clk or posedge reset)
    begin
        if(reset)
            reg_bin <= 0;
        else
            reg_bin <= bin;
    end

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

    // 行场计数寄存一个时钟周期 用于写
    always@(posedge clk or posedge reset)
    begin
        if(reset)
        begin
            reg_x_cnt <= 10'd0;
            reg_y_cnt <= 10'd0;
        end
        else 
        begin
            reg_x_cnt <= x_cnt;
            reg_y_cnt <= y_cnt;
        end
    end
    
    // 像素使能信号打一拍 延迟用于写入    
    always @ (posedge clk or posedge reset) 
    begin
        if(reset)
            ram_wr_ena <= 1'b0;
        else 
            ram_wr_ena <= clken;
    end

    // 新的一帧开始时 清空已有的ram信息
    assign ram_wr_data = (y_cnt == 10'd0) ? 10'd0 : (ram_rd_data + reg_bin);
        
    ram_vertical_projection ram_ver (
      .clka(clk),
      .wea(ram_wr_ena),
      .addra(reg_x_cnt),
      .dina(ram_wr_data),
      .clkb(clk),
      .addrb(x_cnt),
      .doutb(ram_rd_data)
    );
    
    // 寄存3级 用于后续判断上升下降沿
    always @ (posedge clk or posedge reset) 
    begin
        if(reset || vsync == 0) 
        begin
            rd_data1 <= 10'd0;
            rd_data2 <= 10'd0;
            rd_data3 <= 10'd0;
            rd_data4 <= 10'd0;
            rd_data5 <= 10'd0;
            rd_data6 <= 10'd0;
            rd_data7 <= 10'd0;
        end
        else if(clken) 
        begin
            rd_data1 <= ram_rd_data;
            rd_data2 <= rd_data1;
            rd_data3 <= rd_data2;
            rd_data4 <= rd_data3;
            rd_data5 <= rd_data4;
            rd_data6 <= rd_data5;
            rd_data7 <= rd_data6;
        end
    end
    
    always @ (posedge clk or posedge reset) 
    begin
        if(reset) 
        begin
            leftline1  <= 10'b0;
            leftline2  <= 10'b0;
            leftline3  <= 10'b0;
            leftline4  <= 10'b0;
            rightline1 <= 10'b0;
            rightline2 <= 10'b0;
            rightline3 <= 10'b0;
            rightline4 <= 10'b0;
            posedge_cnt <= 4'd0;
            negedge_cnt <= 4'd0;
        end
        else if(x_cnt == 1 && y_cnt == 1)
        begin
            leftline1  <= 10'b0;
            leftline2  <= 10'b0;
            leftline3  <= 10'b0;
            leftline4  <= 10'b0;
            rightline1 <= 10'b0;
            rightline2 <= 10'b0;
            rightline3 <= 10'b0;
            rightline4 <= 10'b0;
            posedge_cnt <= 4'd0;
            negedge_cnt <= 4'd0;
        end
        else if(clken) 
        begin
            // 最后一行开始统计上升下降沿
            if(y_cnt == DISPLAY_HEIGHT - 1'b1) 
            begin    
                if((rd_data7 == 10'd0) && (ram_rd_data > 10'd10)
                && (posedge_cnt == 0 || reg_x_cnt - lastposline > 10'd50))
                begin
                    posedge_cnt = posedge_cnt + 1;
                    lastposline <= reg_x_cnt - 2;
                    case(posedge_cnt)
                        4'd1 : leftline1  <= reg_x_cnt - 2;
                        4'd2 : leftline2  <= reg_x_cnt - 2;
                        4'd3 : leftline3  <= reg_x_cnt - 2;
                        4'd4 : leftline4  <= reg_x_cnt - 2;
                    endcase 
                end
                
                if((rd_data7 > 10'd10) && (ram_rd_data == 10'd0)
                && (negedge_cnt == 0 || reg_x_cnt - lastnegline > 10'd50))
                begin
                    negedge_cnt = negedge_cnt + 1;
                    lastnegline <= reg_x_cnt - 2;
                    case(negedge_cnt)
                        4'd1 : rightline1  <= reg_x_cnt - 2;
                        4'd2 : rightline2  <= reg_x_cnt - 2;
                        4'd3 : rightline3  <= reg_x_cnt - 2;
                        4'd4 : rightline4  <= reg_x_cnt - 2;
                    endcase            
                end
            end
        end
    end
    
    // 一帧写入完毕后 再更新线条位置
    always @ (posedge clk or posedge reset) 
    begin
        if(reset) 
        begin
            line_left1  <= 10'd0;
            line_right1 <= 10'd0;
            line_left2  <= 10'd0;
            line_right2 <= 10'd0;
            line_left3  <= 10'd0;
            line_right3 <= 10'd0;
            line_left4  <= 10'd0;
            line_right4 <= 10'd0;
        end
        else if(vsync == 0) 
        begin
            line_left1  <= leftline1;
            line_right1 <= rightline1;
            line_left2  <= leftline2;
            line_right2 <= rightline2;
            line_left3  <= leftline3;
            line_right3 <= rightline3;
            line_left4  <= leftline4;
            line_right4 <= rightline4;
        end  
    end

endmodule
