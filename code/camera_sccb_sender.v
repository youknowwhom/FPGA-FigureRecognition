`timescale 1ns / 1ps

// 通过sccb发送给摄像头配置信息
module camera_sccb_sender(
    input               clk,        // 时钟，25MHz
    input               reset,
    output reg          sio_c,
    inout               sio_d,
    input               cfg_ok,     // 配置是否写入完毕
    output reg          sccb_ok,    // 是否准备好读取新的8bit
    input [7:0]         reg_addr,   // 要写入的寄存器地址
    input [7:0]         value       // 要写入的值
);
    
    // 从机地址
    parameter [7:0] slave_address = 8'h60;
    
    reg     [20:0]      cfg_cnt = 0;      // 计数器
    reg                 sio_d_ena;        // sio_d是否闲置
    reg     [31:0]      data_temp;        // 暂存数据待输出
    
    initial sccb_ok <= 0;
    
    // 计数器 相当于给clk再分频
    always @ (posedge clk)
    begin
        if(cfg_cnt == 0)
            cfg_cnt <= cfg_ok;
        else
            if(cfg_cnt[20:11] == 31)
                cfg_cnt <= 0;
            else
                cfg_cnt <= cfg_cnt + 1;
    end

    // sccb_ok信号为真时，开始新的8bit的读入 
    always @ (posedge clk)
        sccb_ok = (cfg_cnt == 0) && (cfg_ok == 1);

    // sio_c赋值
    always @ (posedge clk) 
    begin
        // sio_c为高电平，输出开始信号
        if(cfg_cnt[20:11] == 0)
            sio_c <= 1;
        // 开始信号输出结束
        else if(cfg_cnt[20:11] == 1) 
        begin
            if(cfg_cnt[10:9] == 2'b11)
                sio_c <= 0;
            else
                sio_c <= 1;
        end 
        // 准备输出结束信号
        else if(cfg_cnt[20:11] == 29)
        begin
            if(cfg_cnt[10:9] == 2'b00)
                sio_c <= 0;
            else
                sio_c <= 1;
        end 
        // sio_c为高电平，输出结束信号
        else if(cfg_cnt[20:11] == 30 || cfg_cnt[20:11] == 31)
            sio_c <= 1;
        // 其他时候sio_c为均匀的时钟周期 一次01变化输出sio_d上的一位信号
        else 
        begin
            if(cfg_cnt[10:9] == 2'b00)
                sio_c <= 0;
            else if(cfg_cnt[10:9] == 2'b01)
                sio_c <= 1;
            else if(cfg_cnt[10:9] == 2'b10)
                sio_c <= 1;
            else if(cfg_cnt[10:9] == 2'b11)
                sio_c <= 0;
        end
    end

    // 此3位是dont't care位，高阻态
    always @ (posedge clk) begin
        if(cfg_cnt[20:11] == 10 || cfg_cnt[20:11] == 19 || cfg_cnt[20:11] == 28)
            sio_d_ena <= 0;
        else
            sio_d_ena <= 1;
    end
    
    // 输出配置文件数据
    always @ (posedge clk) 
    begin
        if(reset)
            data_temp <= 32'hffffffff;
        else
        begin
            // 开始新8bit配置的装填
            if(cfg_cnt == 0 && cfg_ok == 1)
                // 开始信号，从机地址，寄存器地址，内容，结束信号
                // 1'bx为don't care位
                data_temp <= {2'b10, slave_address, 1'bx, reg_addr, 1'bx, value, 1'bx, 3'b011};
            // 分频
            else if(cfg_cnt[10:0] == 0)
                // 串行依次输出
                data_temp <= {data_temp[30:0], 1'b1};
        end
    end
    
    // 不传输时为三态门的高阻态
    assign sio_d = sio_d_ena ? data_temp[31] : 1'bz;
    
endmodule
