`timescale 1ns / 1ps

// vga显示
module vga_sync(
	input vga_clk,				// VGA时钟
	input reset,				// 复位信号

	output hsync,				// 行同步信号 
	output vsync,				// 场同步信号 

	output display_on, 			// 是否显示输出
	output [10:0] pixel_x,	    // 当前像素点横坐标
	output [10:0] pixel_y	    // 当前像素点纵坐标
);
	
	// VGA同步参数
	parameter H_DISPLAY       = 640; 	// 行有效显示 
	parameter H_L_BORDER      =  48; 	// 行左边框
	parameter H_R_BORDER      =  16; 	// 行右边框
	parameter H_SYNC          =  96; 	// 行同步 
	parameter H_MAX           = H_DISPLAY + H_L_BORDER + H_R_BORDER + H_SYNC - 1;
	
	parameter V_DISPLAY       = 480;	// 列有效显示 
	parameter V_T_BORDER      =  33;	// 列上边框
	parameter V_B_BORDER      =  10;	// 列下边框
	parameter V_SYNC          =   2;	// 列同步 
	parameter V_MAX           = V_DISPLAY + V_T_BORDER + V_B_BORDER + V_SYNC - 1;   

	// VGA行场同步信号
	assign hsync = (h_cnt < H_SYNC) ? 1'b0 : 1'b1;
	assign vsync = (v_cnt < V_SYNC) ? 1'b0 : 1'b1;
	
    // 是否显示输出
	assign display_on = (h_cnt >= H_SYNC + H_L_BORDER) && (h_cnt < H_SYNC + H_L_BORDER + H_DISPLAY)
						&& (v_cnt >= V_SYNC + V_T_BORDER) && (v_cnt < V_SYNC + V_T_BORDER + V_DISPLAY);
	
	// 横纵坐标计算
	reg [10:0] h_cnt;
	reg [10:0] v_cnt;
	assign pixel_x = h_cnt - H_SYNC - H_L_BORDER;
	assign pixel_y = v_cnt - V_SYNC - V_T_BORDER;
	
    always @ (posedge vga_clk)
    begin
        if(reset)
        begin
            h_cnt <= 0;
            v_cnt <= 0;
        end
        else
        begin
            if(h_cnt == H_MAX)
            begin
                h_cnt <= 0;
                if(v_cnt == V_MAX)
                    v_cnt <= 0;
                else
                    v_cnt <= v_cnt + 1;
            end
            else
                h_cnt <= h_cnt + 1;
        end
    end

endmodule
