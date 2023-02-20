`timescale 1ns / 1ps

// 蓝牙信息接收
module bluetooth_uart_receive(
    input clk,                      // 系统时钟
    input reset,                    // 复位信号
    input rxd,                      // 串行输入数据
    output reg [7:0] data_out,      // 并行输出数据
    output reg data_flag            // 并行数据输出信号
    );

    parameter CLK_FREQ = 100000000;            // 系统时钟频率
    parameter UART_BPS = 9600;                 // 串口波特率
    localparam BPS_CNT = CLK_FREQ / UART_BPS;
 
	// 寄存器与线网定义
    reg rxd_reg1;		// 打三拍 消除亚稳态
    reg rxd_reg2;
	reg rxd_reg3;
	wire start_flag;	// 稳定下降沿信号
    reg [14:0] clk_cnt;
    reg [3:0] bit_cnt;
    reg work_flag;		// 开始8bit的串转并
    reg [7:0] rx_data;

	// 稳定下降沿 开始接收
    assign start_flag = (~rxd_reg2) & rxd_reg3;    

    always @(posedge clk or negedge reset) 
	begin 
        if(reset) 
            { rxd_reg1, rxd_reg2, rxd_reg3 } <= 3'b111;     
        else 
            { rxd_reg1, rxd_reg2, rxd_reg3 } <= { rxd, rxd_reg1, rxd_reg2 };  
    end

    // 开始读入8bit信号的设置
    always @(posedge clk or negedge reset) 
	begin         
        if(reset)                                  
            work_flag <= 1'b0;
        else 
		begin
			// 开始读入8bit
            if(start_flag)
                work_flag <= 1'b1;
			// 当前8bit读入完毕 等待新信号
            else if((bit_cnt == 9) && (clk_cnt == BPS_CNT / 2))
                work_flag <= 1'b0;
            else
                work_flag <= work_flag;
        end
    end
    
    // 根据波特率与时钟频率计时
    always @(posedge clk or negedge reset) 
	begin         
        if(reset) 
		begin                             
            clk_cnt <= 0;                                  
            bit_cnt <= 0;
        end 
		else if(work_flag) 
		begin
			if(clk_cnt < BPS_CNT - 1) 
			begin
				clk_cnt <= clk_cnt + 1'b1;
				bit_cnt <= bit_cnt;
			end 
			else 
			begin
				clk_cnt <= 0;
				bit_cnt <= bit_cnt + 1'b1;
			end
		end 
		else 
		begin
			clk_cnt <= 0;
			bit_cnt <= 0;
		end
    end
    
    // 串行输入转并行
    always @(posedge clk or negedge reset) 
	begin 
        if(reset)  
            rx_data <= 8'b0;                                     
        else if(work_flag)
			// 周期正中读入较稳定 校验位舍弃
            if(clk_cnt == BPS_CNT / 2 && bit_cnt != 9) 
				rx_data <= { rxd_reg3, rx_data[7:1] };
            else 
                rx_data <= rx_data;
        else
            rx_data <= 8'b0;
    end
        
	// 8bit发送结束 并行输出
    always @(posedge clk or negedge reset) 
	begin        
        if(reset)
            data_out <= 8'b0;                               
        else if(bit_cnt == 9)    
            data_out <= rx_data; 
		else
			data_out <= data_out;
    end

	// 输出标志位拉高
    always @(posedge clk or negedge reset) 
	begin        
        if(reset)                            
            data_flag <= 0;
        else if(bit_cnt == 9) 
            data_flag <= 1;
        else                                 
            data_flag <= 0; 
    end

endmodule