`timescale 1ns / 1ps

// vga显示控制 （加数字识别框线）
module vga_control(
    input      [11:0]    org_rgb,           // 原始rgb像素值
    input                display_on,        // 是否显示
    input      [10:0]    pixel_x,           // 当前输出像素的横纵坐标
    input      [10:0]    pixel_y,           
    input                ena,               // 是否显示框线
    input      [10:0]    line_left,         // 各个数字的框线
    input      [10:0]    line_right,
    input      [10:0]    line_top,
    input      [10:0]    line_bottom,
    input      [10:0]    line_left2,
    input      [10:0]    line_right2,
    input      [10:0]    line_top2,
    input      [10:0]    line_bottom2,
    input      [10:0]    line_left3,
    input      [10:0]    line_right3,
    input      [10:0]    line_top3,
    input      [10:0]    line_bottom3,
    input      [10:0]    line_left4,
    input      [10:0]    line_right4,
    input      [10:0]    line_top4,
    input      [10:0]    line_bottom4,
    output reg [11:0]    out_rgb
    );
    
    // 数字辅助线
    wire [10:0] fig_width  = line_right - line_left;
    wire [10:0] fig_height = line_bottom - line_top;
    wire [10:0] fig_vdiv   = line_left + fig_width * 8 / 15;
    wire [10:0] fig_hdiv1  = line_top + fig_height * 3 / 10;
    wire [10:0] fig_hdiv2  = line_top + fig_height * 7 / 10; 
    
    wire [10:0] fig_width_2  = line_right2 - line_left2;
    wire [10:0] fig_height_2 = line_bottom2 - line_top2;
    wire [10:0] fig_vdiv_2   = line_left2 + fig_width_2 * 8 / 15;
    wire [10:0] fig_hdiv1_2  = line_top2 + fig_height_2 * 3 / 10;
    wire [10:0] fig_hdiv2_2  = line_top2 + fig_height_2 * 7 / 10; 
    
    wire [10:0] fig_width_3  = line_right3 - line_left3;
    wire [10:0] fig_height_3 = line_bottom3 - line_top3;
    wire [10:0] fig_vdiv_3   = line_left3 + fig_width_3 * 8 / 15;
    wire [10:0] fig_hdiv1_3  = line_top3 + fig_height_3 * 3 / 10;
    wire [10:0] fig_hdiv2_3  = line_top3 + fig_height_3 * 7 / 10;  
    
    wire [10:0] fig_width_4  = line_right4 - line_left4;
    wire [10:0] fig_height_4 = line_bottom4 - line_top4;
    wire [10:0] fig_vdiv_4   = line_left4 + fig_width_4 * 8 / 15;
    wire [10:0] fig_hdiv1_4  = line_top4 + fig_height_4 * 3 / 10;
    wire [10:0] fig_hdiv2_4  = line_top4 + fig_height_4 * 7 / 10;      
     
    
    always @ (*)
    begin
        if(display_on)
        begin
            if(ena)
            begin
                if((pixel_x == line_left || pixel_x == line_right)
                    && (pixel_y > line_top)
                    && (pixel_y < line_bottom))
                    out_rgb <= 12'hF00;
                else if((pixel_y == line_top || pixel_y == line_bottom) 
                        && (pixel_x > line_left) 
                        && (pixel_x < line_right))            
                    out_rgb <= 12'hF00;
                else if((pixel_x == fig_vdiv)
                        && (pixel_y > line_top)
                        && (pixel_y < line_bottom))
                    out_rgb <= 12'h00F;
                else if((pixel_y == fig_hdiv1 || pixel_y == fig_hdiv2) 
                        && (pixel_x > line_left) 
                        && (pixel_x < line_right))
                    out_rgb <= 12'h00F;
                else if((pixel_x == line_left2 || pixel_x == line_right2)
                    && (pixel_y > line_top2)
                    && (pixel_y < line_bottom2))
                    out_rgb <= 12'hF00;
                else if((pixel_y == line_top2 || pixel_y == line_bottom2) 
                        && (pixel_x > line_left2) 
                        && (pixel_x < line_right2))            
                    out_rgb <= 12'hF00;
                else if((pixel_x == fig_vdiv_2)
                        && (pixel_y > line_top2)
                        && (pixel_y < line_bottom2))
                    out_rgb <= 12'h00F;
                else if((pixel_y == fig_hdiv1_2 || pixel_y == fig_hdiv2_2) 
                        && (pixel_x > line_left2) 
                        && (pixel_x < line_right2))
                    out_rgb <= 12'h00F;
                else if((pixel_x == line_left3 || pixel_x == line_right3)
                        && (pixel_y > line_top3)
                        && (pixel_y < line_bottom3))
                    out_rgb <= 12'hF00;
                else if((pixel_y == line_top3 || pixel_y == line_bottom3) 
                        && (pixel_x > line_left3) 
                        && (pixel_x < line_right3))            
                    out_rgb <= 12'hF00;
                else if((pixel_x == fig_vdiv_3)
                        && (pixel_y > line_top3)
                        && (pixel_y < line_bottom3))
                    out_rgb <= 12'h00F;
                else if((pixel_y == fig_hdiv1_3 || pixel_y == fig_hdiv2_3) 
                        && (pixel_x > line_left3) 
                        && (pixel_x < line_right3))
                    out_rgb <= 12'h00F;
                else if((pixel_x == line_left4 || pixel_x == line_right4)
                        && (pixel_y > line_top4)
                        && (pixel_y < line_bottom4))
                    out_rgb <= 12'hF00;
                else if((pixel_y == line_top4 || pixel_y == line_bottom4) 
                        && (pixel_x > line_left4) 
                        && (pixel_x < line_right4))            
                    out_rgb <= 12'hF00;
                else if((pixel_x == fig_vdiv_4)
                        && (pixel_y > line_top4)
                        && (pixel_y < line_bottom4))
                    out_rgb <= 12'h00F;
                else if((pixel_y == fig_hdiv1_4 || pixel_y == fig_hdiv2_4) 
                        && (pixel_x > line_left4) 
                        && (pixel_x < line_right4))
                    out_rgb <= 12'h00F;
                else
                    out_rgb <= org_rgb;
            end
            else
                out_rgb <= org_rgb;
        end
        else
            out_rgb <= 12'b0;
    end
    
endmodule
