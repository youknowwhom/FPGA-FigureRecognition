`timescale 1ns / 1ps

// 摄像头传输画面
module camera_get_img(
    input               pclk,           // 1像素周期为2个pclk
    input               reset,          // 复位信号
    input               href,           // 行参考信号
    input               vsync,          // 帧同步
    input      [7:0]    data_in,        // 从摄像头读入的RGB565信息(两个pclk)
    output reg [11:0]   data_out,      // 输出的一像素RGB444
    output reg          pix_ena,       // 新的像素输出
    output reg [18:0]   ram_out_addr   // 应该写入的RAM地址
);

    reg [15:0] rgb565 = 0;
    reg [1:0]  bit_status = 0;     // 两个pclk对应一次输出
    reg [18:0] ram_next_addr;
    
    initial ram_next_addr <= 0;
    
    always@ (posedge pclk) 
    begin
        // 开始输出新的一帧 从头写入RAM
        if(vsync == 0) 
        begin
            ram_out_addr <= 0;
            ram_next_addr <= 0;
            bit_status <= 0;
        end 
        else 
        begin
            // RGB565取高位压缩为RGB444
            data_out <= { rgb565[15:12], rgb565[10:7], rgb565[4:1] };
            ram_out_addr <= ram_next_addr;
            pix_ena <= bit_status[1];
            // 两个pclk输出一次
            bit_status <= {bit_status[0], (href && !bit_status[0])};
            // 两字节信息 拼成16bit的RGB565
            rgb565 <= { rgb565[7:0], data_in };    
            if(bit_status[1] == 1)
                ram_next_addr <= ram_next_addr + 1;
        end
    end
    
endmodule


