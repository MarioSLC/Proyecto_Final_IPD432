`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.11.2017 11:14:05
// Design Name: 
// Module Name: deb
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


module deb(
    input clk,
    input boton,
    output boton_valido
    );
    
    reg [31:0] cuenta = 'd0;
    
    always@(posedge clk) begin
        if(boton) begin
            cuenta <= (cuenta < 99_999_998)? cuenta + 1: 49_999_999;
        end
        else cuenta <= 'd0;
    end    
    assign boton_valido = (cuenta == 3_000_000);
endmodule

