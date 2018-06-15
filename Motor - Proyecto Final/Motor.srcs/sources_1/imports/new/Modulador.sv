`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.05.2018 04:31:02
// Design Name: 
// Module Name: Modulador_PWM
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


module Modulador_PWM
    #(
    parameter CLK_FREQUENCY = 100000000,
    parameter FREQ_PWM = 10000,
    parameter [31:0] CUENTA_INICIAL = 0,
    parameter [31:0] CUENTA_MAXIMA = CLK_FREQUENCY/(2*FREQ_PWM),
    parameter DEBUG = 0 
    )(
    input clk,
    input [31:0] entrada,
    input enable,
    input en_log,
    output reg salida_PWM
    );
    
    reg [31:0] contador = CUENTA_INICIAL;
    reg up_down = 0;
    reg [31:0] registro_comparacion = 5000;
    
    
    always@(posedge clk) begin
        salida_PWM <= ($signed(registro_comparacion) > $signed(contador))? 1:0;
        if(up_down == 0) begin
            contador <= contador + 1;
            up_down <= (contador >= CUENTA_MAXIMA - 1)? 1:0;
        end
        else begin
            contador <= (contador > 0)? contador - 1 : 0;
            up_down <= (contador > 1)? 1:0;
        end
    end
    
    always @(posedge clk) begin
        if (contador == 0) begin
            registro_comparacion <= entrada + CUENTA_MAXIMA/2;
        end
    end
    generate
    if (DEBUG == 1) begin
        analizador_PWM analizador_PWM (
            .clk(clk), // input wire clk
        
            .probe0(en_log), // input wire [31:0] probe0
            .probe1(contador[31:0]), // input wire [31:0] probe0
            .probe2(entrada[31:0]), // input wire [31:0] probe0
            .probe3(registro_comparacion[31:0]), // input wire [31:0] probe0
            .probe4(salida_PWM)
        );
    end
    endgenerate
endmodule
