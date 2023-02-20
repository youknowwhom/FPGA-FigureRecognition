`timescale 1ns / 1ps

// 摄像头初始化
module camera_init_top(
    input clk,      // 25MHz时钟
    input reset,    // 复位信号
    // 以下是与摄像头相连的管脚
    output sio_c,
    inout  sio_d,
    output pwdn,
    output ret,
    output xclk
    );
    
    // pwdn高电平有效 ret低电平有效
    assign pwdn = 0;
    assign ret = 1;
    // sio_d高阻态
    pullup up (sio_d);
    // 赋给xclk时钟信号    
    assign xclk = clk;
    
    wire cfg_ok, sccb_ok;
    wire [15: 0] data_sent;
    
    // 实例化配置写入模块
    camera_reg_cfg reg_cfg(
        .clk(clk),
        .reset(reset),
        .data_out(data_sent),
        .cfg_ok(cfg_ok),
        .sccb_ok(sccb_ok)
    );
    
    // 实例化sccb发送模块
    camera_sccb_sender sccb_sender(
        .clk(clk),
        .reset(reset),
        .sio_c(sio_c),
        .sio_d(sio_d),
        .cfg_ok(cfg_ok),
        .sccb_ok(sccb_ok),    
        .reg_addr(data_sent[15:8]),   
        .value(data_sent[7:0])      
    );
   
    
endmodule
