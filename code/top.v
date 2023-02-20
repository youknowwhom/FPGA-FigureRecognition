`timescale 1ns / 1ps

module top(
    input               clk,
    input               reset,

    // 摄像头
    output              camera_sio_c,   
    inout               camera_sio_d,   
    output              camera_ret,   
    output              camera_pwdn,   
    output              camera_xclk,   
    input               camera_pclk,
    input               camera_href,
    input               camera_vsync,   
    input [7:0]         camera_data,
    
    // VGA
    output [11:0]       vga_rgb,
    output              vga_hsync,
    output              vga_vsync,
    
    // 蓝牙
    input               bluetooth_rxd,
    
    // 7段数码管
    output [7:0]        display7_enable,
    output [6:0]        display7_segment,
    
    // LED灯
    output [7:0]        led
    
    );

    
    
    /*********************
        线网与寄存器定义
    *********************/
    
    // 时钟
    wire clk_vga;
    wire clk_sccb;
    
    // VGA显示
    wire        vga_display_on;
    wire [10:0] vga_pix_x;
    wire [10:0] vga_pix_y;
    
    // 显示模式选择
    wire        mode_binarization;
    wire        mode_frameline;
    
    // 摄像头读取
    wire        camera_pix_ena;
    wire [11:0] camera_data_out;
    wire [18:0] camera_data_addr;
    
    
    // 图像处理
    wire        post_href;
    wire        post_vsync;
    wire        post_clken;
    wire [11:0] post_data_out;
    wire [18:0] post_data_addr;
    wire        bin;

    // RAM读写
    wire        ram_write_ena;
    wire [11:0] ram_write_value;
    wire [18:0] ram_write_addr;
    wire        ram_read_ena;
    wire [11:0] ram_read_value;
    wire [18:0] ram_read_addr;
    
    // 蓝牙
    wire [7:0]  bluetooth_data;
    wire        bluetooth_flag;

    // 数字框线
    wire [10:0] line_left;
    wire [10:0] line_left2;
    wire [10:0] line_left3;
    wire [10:0] line_left4;
    wire [10:0] line_right;
    wire [10:0] line_right2;
    wire [10:0] line_right3;
    wire [10:0] line_right4;
    wire [10:0] line_top;
    wire [10:0] line_top2;
    wire [10:0] line_top3;
    wire [10:0] line_top4;
    wire [10:0] line_bottom;
    wire [10:0] line_bottom2;
    wire [10:0] line_bottom3;
    wire [10:0] line_bottom4;
     
    // 交点特征
    wire [3:0]  intersection_v;
    wire [3:0]  intersection_h1;
    wire [3:0]  intersection_h2;
    wire        intersection_h1_pst;
    wire        intersection_h2_pst;
    wire [3:0]  intersection_v_2;
    wire [3:0]  intersection_h1_2;
    wire [3:0]  intersection_h2_2;
    wire        intersection_h1_pst_2;
    wire        intersection_h2_pst_2;
    wire [3:0]  intersection_v_3;
    wire [3:0]  intersection_h1_3;
    wire [3:0]  intersection_h2_3;
    wire        intersection_h1_pst_3;
    wire        intersection_h2_pst_3;
    wire [3:0]  intersection_v_4;
    wire [3:0]  intersection_h1_4;
    wire [3:0]  intersection_h2_4;
    wire        intersection_h1_pst_4;
    wire        intersection_h2_pst_4;
    
    // 7段数码管
    wire [3:0]  display7_num1;
    wire [3:0]  display7_num2;
    wire [3:0]  display7_num3;
    wire [3:0]  display7_num4;
    
    /*********************
           线网连接
    *********************/
    
    assign led = bluetooth_data;
    
    // 显示模式选择
    assign mode_binarization = (bluetooth_data[7:4] == 4'hF);   // 高四位为1111表示显示二值化图像
    assign mode_frameline    = (bluetooth_data[3:0] == 4'hF);   // 低四位为1111表示显示辅助框线
    
    // RAM
    assign ram_write_value = mode_binarization ? post_data_out : camera_data_out;
    assign ram_write_addr  = mode_binarization ? post_data_addr : camera_data_addr;
    assign ram_write_ena   = mode_binarization ? post_clken : camera_pix_ena;
    
    assign ram_read_addr = vga_display_on ? (vga_pix_y * 640 + vga_pix_x) : 12'b0; //地址计算

    
     /*********************
          模块实例化
    *********************/
    
    // 实例化系统时钟分频
    clk_divider clk_div(
        .clk_in1(clk),
        .clk_vga(clk_vga),
        .clk_sccb(clk_sccb)
    );
    
    // 实例化蓝牙接收模块
    bluetooth_uart_receive bluetooth(
        .clk(clk),
        .reset(reset),
        .rxd(bluetooth_rxd),
        .data_out(bluetooth_data),
        .data_flag(bluetooth_flag)
    );
    
    // 实例化摄像头初始化模块
    camera_init_top camera_init(
        .clk(clk_sccb),
        .reset(reset),
        .sio_c(camera_sio_c),
        .sio_d(camera_sio_d),
        .pwdn(camera_pwdn),
        .ret(camera_ret),
        .xclk(camera_xclk)
    );
    
    // 实例化摄像头传输画面模块
    camera_get_img get_img(
        .pclk(camera_pclk),
        .reset(reset),
        .href(camera_href),
        .vsync(camera_vsync),
        .data_in(camera_data),
        .data_out(camera_data_out),
        .pix_ena(camera_pix_ena),
        .ram_out_addr(camera_data_addr)
        );
    
    // 实例化图像处理模块
    image_process img_process(
        .clk(camera_pclk),
        .reset(reset),
        .href(camera_href),
        .vsync(camera_vsync),
        .clken(camera_pix_ena),
        .rgb(camera_data_out),
        .bin(bin),
        .post_href(post_href),
        .post_vsync(post_vsync),
        .post_clken(post_clken),
        .data_out(post_data_out),
        .data_out_addr(post_data_addr)
    );
    
    // 实例化垂直投影模块
    vertical_projection ver_projection(
        .clk(camera_pclk),
        .reset(reset),
        .vsync(post_vsync),
        .href(post_href),
        .clken(post_clken),
        .bin(~bin),
        .line_left1(line_left),
        .line_right1(line_right),
        .line_left2(line_left2),
        .line_right2(line_right2),
        .line_left3(line_left3),
        .line_right3(line_right3),
        .line_left4(line_left4),
        .line_right4(line_right4)
    );
    
    // 实例化水平投影模块1
    horizontal_projection hor_projection(
        .clk(camera_pclk),
        .reset(reset),
        .vsync(post_vsync),
        .href(post_href),
        .clken(post_clken),
        .bin(~bin),
        .line_left(line_left),
        .line_right(line_right),
        .line_top(line_top),
        .line_bottom(line_bottom)
    );
    
    // 实例化水平投影模块2
    horizontal_projection hor_projection2(
        .clk(camera_pclk),
        .reset(reset),
        .vsync(post_vsync),
        .href(post_href),
        .clken(post_clken),
        .bin(~bin),
        .line_left(line_left2),
        .line_right(line_right2),
        .line_top(line_top2),
        .line_bottom(line_bottom2)
    );

    // 实例化水平投影模块3
    horizontal_projection hor_projection3(
        .clk(camera_pclk),
        .reset(reset),
        .vsync(post_vsync),
        .href(post_href),
        .clken(post_clken),
        .bin(~bin),
        .line_left(line_left3),
        .line_right(line_right3),
        .line_top(line_top3),
        .line_bottom(line_bottom3)
    );
    
    // 实例化水平投影模块4
    horizontal_projection hor_projection4(
        .clk(camera_pclk),
        .reset(reset),
        .vsync(post_vsync),
        .href(post_href),
        .clken(post_clken),
        .bin(~bin),
        .line_left(line_left4),
        .line_right(line_right4),
        .line_top(line_top4),
        .line_bottom(line_bottom4)
    );    
    
    // 实例化交点特征统计模块1
    intersection_count count1(
        .clk(camera_pclk),
        .reset(reset),
        .vsync(post_vsync),
        .href(post_href),
        .clken(post_clken),
        .bin(~bin),
        .line_top(line_top),
        .line_bottom(line_bottom),
        .line_left(line_left),
        .line_right(line_right),
        .v_cnt(intersection_v),
        .h_cnt1(intersection_h1),
        .h_cnt2(intersection_h2),
        .h1(intersection_h1_pst),
        .h2(intersection_h2_pst)
    );
    
    // 实例化交点特征统计模块2
    intersection_count count2(
        .clk(camera_pclk),
        .reset(reset),
        .vsync(post_vsync),
        .href(post_href),
        .clken(post_clken),
        .bin(~bin),
        .line_top(line_top2),
        .line_bottom(line_bottom2),
        .line_left(line_left2),
        .line_right(line_right2),
        .v_cnt(intersection_v_2),
        .h_cnt1(intersection_h1_2),
        .h_cnt2(intersection_h2_2),
        .h1(intersection_h1_pst_2),
        .h2(intersection_h2_pst_2)
    );

    // 实例化交点特征统计模块3
    intersection_count count3(
        .clk(camera_pclk),
        .reset(reset),
        .vsync(post_vsync),
        .href(post_href),
        .clken(post_clken),
        .bin(~bin),
        .line_top(line_top3),
        .line_bottom(line_bottom3),
        .line_left(line_left3),
        .line_right(line_right3),
        .v_cnt(intersection_v_3),
        .h_cnt1(intersection_h1_3),
        .h_cnt2(intersection_h2_3),
        .h1(intersection_h1_pst_3),
        .h2(intersection_h2_pst_3)
    );
    
    // 实例化交点特征统计模块4
    intersection_count count4(
        .clk(camera_pclk),
        .reset(reset),
        .vsync(post_vsync),
        .href(post_href),
        .clken(post_clken),
        .bin(~bin),
        .line_top(line_top4),
        .line_bottom(line_bottom4),
        .line_left(line_left4),
        .line_right(line_right4),
        .v_cnt(intersection_v_4),
        .h_cnt1(intersection_h1_4),
        .h_cnt2(intersection_h2_4),
        .h1(intersection_h1_pst_4),
        .h2(intersection_h2_pst_4)
    );
    
    // 实例化数字判断模块
    figure_recognition fig_recogn(
        .v_cnt(intersection_v),
        .h_cnt1(intersection_h1),
        .h_cnt2(intersection_h2),
        .h1(intersection_h1_pst),
        .h2(intersection_h2_pst),
        .figure(display7_num1)
    );
    
    // 实例化数字判断模块2
    figure_recognition fig_recogn2(
        .v_cnt(intersection_v_2),
        .h_cnt1(intersection_h1_2),
        .h_cnt2(intersection_h2_2),
        .h1(intersection_h1_pst_2),
        .h2(intersection_h2_pst_2),
        .figure(display7_num2)
    );    

    
    // 实例化数字判断模块3
    figure_recognition fig_recogn3(
        .v_cnt(intersection_v_3),
        .h_cnt1(intersection_h1_3),
        .h_cnt2(intersection_h2_3),
        .h1(intersection_h1_pst_3),
        .h2(intersection_h2_pst_3),
        .figure(display7_num3)
    );
    
    // 实例化数字判断模块4
    figure_recognition fig_recogn4(
        .v_cnt(intersection_v_4),
        .h_cnt1(intersection_h1_4),
        .h_cnt2(intersection_h2_4),
        .h1(intersection_h1_pst_4),
        .h2(intersection_h2_pst_4),
        .figure(display7_num4)
    );            
    
    // 实例化双端口ram
    ram ram_inst (
        .clka(clk),
        .wea(ram_write_ena),
        .addra(ram_write_addr),
        .dina(ram_write_value),
        .clkb(clk),
        .enb(1'b1),
        .addrb(ram_read_addr),
        .doutb(ram_read_value)
    );
    
    // 实例化VGA显示
    vga_sync vga_display(
        .vga_clk(clk_vga),
        .reset(reset),
        .hsync(vga_hsync), 
        .vsync(vga_vsync),
        .display_on(vga_display_on),
        .pixel_x(vga_pix_x),
        .pixel_y(vga_pix_y)
    );
    
    // 实例化vga显示控制模块
    vga_control vga_ctrl(
        .org_rgb(ram_read_value),
        .display_on(vga_display_on),
        .pixel_x(vga_pix_x),
        .pixel_y(vga_pix_y),
        .ena(mode_frameline),
        .line_left(line_left),
        .line_left2(line_left2),
        .line_left3(line_left3),
        .line_left4(line_left4),
        .line_right(line_right),
        .line_right2(line_right2),
        .line_right3(line_right3),
        .line_right4(line_right4),
        .line_top(line_top),
        .line_top2(line_top2),
        .line_top3(line_top3),
        .line_top4(line_top4),
        .line_bottom(line_bottom),
        .line_bottom2(line_bottom2),
        .line_bottom3(line_bottom3),
        .line_bottom4(line_bottom4),
        .out_rgb(vga_rgb)
    );
    
    // 实例化7段数码管显示模块
    display7 display7_seg(
        .clk(clk),
        .num1(display7_num1),
        .num2(display7_num2),
        .num3(display7_num3),
        .num4(display7_num4),
        .enable(display7_enable), 
        .segment(display7_segment)
    );
    
endmodule
