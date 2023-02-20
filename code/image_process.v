`timescale 1ns / 1ps

// 图像处理（转灰度图，二值化）
module image_process(
    input               clk,
    input               reset,
    input               href,
    input               vsync,
    input               clken,
    input       [11:0]  rgb,
    output              bin,
    output              post_href,
    output              post_vsync,
    output              post_clken,
    output      [11:0]  data_out,
    output reg  [18:0]  data_out_addr
    );
    
    // 线网定义
    wire [7:0] grey;
    wire post_href0,  post_href1;
    wire post_vsync0, post_vsync1;
    wire post_clken0, post_clken1;
    
    initial data_out_addr <= 0;
    
    // 线网连接
    assign data_out = bin ? 12'hFFF : 12'h000;
    assign post_href  = post_href1;
    assign post_vsync = post_vsync1;
    assign post_clken = post_clken1;
    
    always @ (posedge clk)
    begin
        if(post_vsync1 == 0)
        begin
            data_out_addr <= 0;
        end
        else if(post_clken1)
        begin
            data_out_addr <= data_out_addr + 1;
        end
    end
    
    // rgb转灰度模块实例化
    rgb2grey rgb2grey_inst(
        .clk(clk),
        .reset(reset),
        .org_href(href),
        .org_vsync(vsync),
        .org_clken(clken),
        .org_rgb(rgb),
        .grey(grey),
        .out_href(post_href0),
        .out_vsync(post_vsync0),
        .out_clken(post_clken0)
    );
    
    // 灰度图二值化模块实例化
    binarization bin_inst(
        .clk(clk),
        .reset(reset),
        .org_href(post_href0),
        .org_vsync(post_vsync0),
        .org_clken(post_clken0),
        .grey(grey),
        .bin(bin),
        .out_href(post_href1),
        .out_vsync(post_vsync1),
        .out_clken(post_clken1)
    );
    
endmodule
