`timescale 1ns / 1ps

module figure_recognition(
    input [3:0]          v_cnt,
    input [3:0]          h_cnt1,
    input [3:0]          h_cnt2,
    input                h1,
    input                h2,
    output reg [3:0]     figure
    );
    
    always @ (*)
    begin
        case({ v_cnt, h_cnt1, h_cnt2 })
            {4'd2, 4'd2, 4'd2}: figure <= 4'd0;
            {4'd1, 4'd1, 4'd1}: figure <= 4'd1;
            {4'd2, 4'd2, 4'd1}: figure <= 4'd4;
            {4'd3, 4'd1, 4'd2}: 
            begin
                case(h1)
                    1'b0:       figure <= 4'd3;
                    1'b1:       figure <= 4'd6;
                endcase
            end
            {4'd2, 4'd1, 4'd1}: figure <= 4'd7;
            {4'd3, 4'd2, 4'd2}: figure <= 4'd8;
            {4'd3, 4'd2, 4'd1}: figure <= 4'd9;
            {4'd3, 4'd1, 4'd1}:
            begin
                case({ h1, h2 })
                    2'b01:      figure <= 4'd2;
                    2'b00:      figure <= 4'd3;
                    2'b10:      figure <= 4'd5;
                    default:    figure <= 4'hF;
                endcase
            end
            default:            figure <= 4'hF;
        endcase
    end
    
endmodule
