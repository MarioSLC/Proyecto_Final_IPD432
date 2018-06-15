//`timescale 1ns / 1ps
`include "parametros.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: pol
// 
// Create Date: 19.09.2017 02:45:36
// Design Name: 
// Module Name: eq1
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


module eq5(
    input clk,
    input [`bits-1:0] c15, 
    input [`bits-1:0] c16, 
    input [`bits-1:0] is_alfa,
    input [`bits-1:0] is_beta,    
    input [`bits-1:0] psir_alfa,
    input [`bits-1:0] psir_beta,
    input [`bits-1:0] wr,
    input [`bits-1:0] TL,
    output [`bits-1:0] wr_1
    );
    
    wire [`bits-1:0] Te;  
    wire [`bits-1:0] sum1;
    wire [`bits-1:0] sum2;
    wire [`bits-1:0] sum3;
    wire [`bits-1:0] sum4;
    
    wire [2*`bits-1:0] sum1_117;
    wire [2*`bits-1:0] sum2_117;
    wire [2*`bits-1:0] sum3_117;
    wire [2*`bits-1:0] sum4_117;
    
    assign sum1 = sum1_117[`bits_frac + `bits:`bits_frac];
    assign sum2 = sum2_117[`bits_frac + `bits:`bits_frac];
    assign sum3 = sum3_117[`bits_frac + `bits:`bits_frac];
    assign sum4 = sum4_117[`bits_frac + `bits:`bits_frac];    
    
    assign wr_1 = sum3 + sum4 + wr;
    assign Te = sum1 - sum2;
    multiplicador eq5_mult1(
      .CLK(clk), // input wire CLK
      .A(is_beta),  // input wire [58 : 0] A
      .B(psir_alfa),  // input wire [58 : 0] B
      .P(sum1_117)  // output wire [117 : 0] P
    );
    multiplicador eq5_mult2(
      .CLK(clk), // input wire CLK
      .A(is_alfa),  // input wire [58 : 0] A
      .B(psir_beta),  // input wire [58 : 0] B
      .P(sum2_117)  // output wire [117 : 0] P
    );
    multiplicador eq5_mult3(
      .CLK(clk), // input wire CLK
      .A(c15),  // input wire [58 : 0] A
      .B(Te),  // input wire [58 : 0] B
      .P(sum3_117)  // output wire [117 : 0] P
    );
    multiplicador eq5_mult4(
      .CLK(clk), // input wire CLK
      .A(c16),  // input wire [58 : 0] A
      .B(TL),  // input wire [58 : 0] B
      .P(sum4_117)  // output wire [117 : 0] P
    );
    
endmodule
