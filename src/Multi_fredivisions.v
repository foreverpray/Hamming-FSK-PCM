`timescale 1ns / 1ps

module Multi_fredivision(
    input clkIn,
    input reset,
    output reg clk_bitTransferRate, 
    output reg FSK_clk,
    output reg [3:0] counter2,
    output reg clkforAD,
    output reg [4:0] counter_serialAD, 
    output reg [8:0] counterforAD,
    output reg clk_character_rate, 
    output reg [7:0] counterAD 
);

always @(posedge clkIn or posedge reset)
begin
    if (reset) begin
        clk_bitTransferRate <= 1'b0;
        FSK_clk <= 1'b0;
        counter2 <= 4'b0;
        clkforAD <= 1'b0;
        counter_serialAD <= 5'b0;
        counterforAD <= 9'b0;
        counterAD <= 8'b0;
        clk_character_rate <= 1'b0;
    end
    else begin
        if (clkIn) begin
            FSK_clk <= ~FSK_clk; // 将clkIn 2分频得到FSK_clk，用于控制FSK信道的信号传输
            
            if (counter_serialAD == 4'b1111) begin // 将clkIn 32分频得到clk_bitTransferRate，作为控制每个bit传输的时钟
                counter_serialAD <= 5'b0;
                clk_bitTransferRate <= ~clk_bitTransferRate;
            end
            else begin
                counter_serialAD <= counter_serialAD + 1;
            end

            if (counterAD == 8'd223) begin // 将clkIn 32x14=448分频得到clk_character_rate，作为控制每个byte传输的时钟
                counterAD <= 8'b0;
                clk_character_rate <= ~clk_character_rate;
            end
            else begin
                counterAD <= counterAD + 1;
            end

        end
    end
end

endmodule
