`timescale 1ns / 1ps

module FSK_demodulate(
    input reset,
    input fsk_signal, //接收的fsk信号
    input clk_bitTransferRate,//控制每个bit传输的时钟
    output reg [13:0] Hamcode
);

    reg [13:0] dataout_recoding; // 解调得到的14bit信号
    reg [3:0] serialSignalCount_ctr; //负责计算接收到的串行信号的数据
reg serialConversion_flag;  //控制串并转换的开关
    reg [2:0] pulseCount_ctr; // 用于计算接收到的脉冲数目

always @(posedge fsk_signal or posedge reset)
begin
    if (reset) begin
        serialSignalCount_ctr <= 4'd13; 
        serialConversion_flag <= 1'b0;
        pulseCount_ctr <= 3'b000;
    end
    else begin
        if (clk_bitTransferRate) begin 
            if (serialConversion_flag) begin
                // 接收的FSK信号共存储了14bit信息，接收完停止接收
                if (serialSignalCount_ctr == 4'd13) begin
                    serialSignalCount_ctr <= 4'd0;
                end
                // 继续接收下个信号
                else begin
                    serialSignalCount_ctr <= serialSignalCount_ctr + 1;
                end
            end
            // 统计接收到的脉冲数
            pulseCount_ctr <= pulseCount_ctr + 1;
            serialConversion_flag <= 1'b0;
        end
        else begin // 当clk_bitTransferRate为低电平时根据接收到的脉冲数决定为‘1’或‘0’
            if (pulseCount_ctr > 3) begin
                if (!serialConversion_flag) begin
                    dataout_recoding[serialSignalCount_ctr] <= 1'b1; //如果收到的过零数大于4就判断为收到的是1信号
                    serialConversion_flag <= 1'b1; 
            end
            else begin
                if (!serialConversion_flag) begin
                    dataout_recoding[serialSignalCount_ctr] <= 1'b0; //如果收到的过零数小于4就判断为收到的是0信号
                    serialConversion_flag <= 1'b1;
                end
            end
            pulseCount_ctr <= 3'b000;
        end
        // the component for recoding
            if (serialSignalCount_ctr == 4'd0) begin // 14bit信号全部接收完时输出
            Hamcode <= dataout_recoding[13:0]; 
        end
    end
end

endmodule
