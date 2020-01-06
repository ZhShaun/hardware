`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/01/03 19:31:01
// Design Name: 
// Module Name: paddle
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define padWidth 10
`define padHeight 10

module ble_paddle(
    input clk,
    input rst,
    input [7:0] data_out,
    input rx_done,
    input [9:0] v_cnt, h_cnt,
    output reg [7:0] ble_x, ble_y,
    output reg [9:0] ble_speed_x, ble_speed_y,
    output reg isLeft, isUp,
    output reg valid,
    output wire [11:0] pixel
    );
    
    reg flag;
    reg [7:0] next_ble_x, next_ble_y;
    
    assign pixel = 12'hfff;
    
    always @ (*) begin
        if(((v_cnt>>1) >= ble_y - `padHeight &&  (v_cnt>>1) <= ble_y + `padHeight && (h_cnt>>1) >= ble_x - `padWidth && (h_cnt>>1) <= ble_x + `padWidth)) begin
            valid = 1'b1;
        end else begin
            valid = 1'b0;
        end
    end
    
    always @ (*) begin
        next_ble_x = ble_x;
        next_ble_y = ble_y;
    end
    
    always @ (posedge clk or posedge rst)
      begin
        if(rst) begin
            ble_x = 20;
            ble_y = 119;
            ble_speed_x = 10'b0;
            ble_speed_y = 10'b0;
            isLeft = 1'b0;
            isUp = 1'b0;
            flag = 1'b0;
        end else begin
            if(rx_done) begin
                if(flag == 1'b0) begin
                    ble_x = data_out;
                    ble_y = next_ble_y; 
                    if(ble_x < next_ble_x) begin
                        isLeft = 1'b1;
                        ble_speed_x = next_ble_x - ble_x;
                    end else begin
                        isLeft = 1'b0;
                        ble_speed_x = ble_x - next_ble_x;
                    end
//                    tmp_led[7:0] = left_pad_x;
//                    tmp_led[15:8] = left_pad_y;
                    flag = 1'b1;
                end else begin
                    ble_y = data_out;
                    ble_x = next_ble_x;
                    if(ble_y < next_ble_y) begin
                        isUp = 1'b1;
                        ble_speed_y = next_ble_y - ble_y;
                    end else begin
                        isUp = 1'b0;
                        ble_speed_y = ble_y - next_ble_y;
                    end
                    ble_speed_y = ble_y - next_ble_y;
//                    tmp_led[15:8] = left_pad_y;
//                    tmp_led[7:0] = left_pad_x;
                    flag = 1'b0;
                end 
            end else begin
                ble_x = next_ble_x;
                ble_y = next_ble_y;
                ble_speed_x = ble_speed_x;
                ble_speed_y = ble_speed_y;
            end
        end
      end
endmodule
