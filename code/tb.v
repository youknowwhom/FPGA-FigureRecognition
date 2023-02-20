////`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////////
////// Company: 
////// Engineer: 
////// 
////// Create Date: 2023/02/09 15:55:06
////// Design Name: 
////// Module Name: tb
////// Project Name: 
////// Target Devices: 
////// Tool Versions: 
////// Description: 
////// 
////// Dependencies: 
////// 
////// Revision:
////// Revision 0.01 - File Created
////// Additional Comments:
////// 
//////////////////////////////////////////////////////////////////////////////////////


//module tb();
//    reg pclk;
//    reg camera_href;
//    reg camera_vsync;
//    wire camera_pix_ena;
//    wire href;
//    wire vsync;
    
//    wire ram_write_ena;
//    wire [18:0] addr1;
//    wire [18:0] addr2;
    
   
//    initial
//    begin
//        pclk = 0;
//        forever #5 pclk = ~pclk;
//    end
    
//    initial
//    begin
//        camera_href = 1;
//        forever begin
//            #20;
//            camera_href = ~camera_href;
//            #5;
//            camera_href = ~camera_href;
//        end
//    end
    
//    initial
//    begin
//        camera_vsync = 1;
//        forever begin
//            #60;
//            camera_vsync = ~camera_vsync;
//            #5;
//            camera_vsync = ~camera_vsync;
//        end
//    end
    
//    // 实例化摄像头传输画面模块
//    camera_get_img get_img(
//        .pclk(pclk),
//        .reset(1'b0),
//        .href(camera_href),
//        .vsync(camera_vsync),
//        .data_in(8'b0),
//        .data_out(camera_data_out),
//        .pix_ena(camera_pix_ena),
//        .ram_out_addr(addr1)
//        );
    
//    // 实例化图像处理模块
//    image_process img_process(
//        .clk(pclk),
//        .reset(1'b0),
//        .href(camera_href),
//        .vsync(camera_vsync),
//        .clken(camera_pix_ena),
//        .rgb(camera_data_out),
//        .bin(),
//        .post_href(href),
//        .post_vsync(vsync),
//        .post_clken(),
//        .data_out_addr(addr2)
//        );
    
    
//endmodule
