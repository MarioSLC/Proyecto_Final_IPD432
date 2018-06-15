//`timescale 1ns / 1ps
`include "parametros.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
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


module eq1(
    input clk,
    input [`bits-1:0] c1,
    input [`bits-1:0] c2,
    input [`bits-1:0] c3,
    input [`bits-1:0] c4,
    input [`bits-1:0] is_alfa,
    input [`bits-1:0] psir_alfa,
    input [`bits-1:0] psir_beta,
    input [`bits-1:0] wr,
    input [`bits-1:0] vs_alfa,
    output [`bits-1:0] is_alfa_1
    );
    
    wire [`bits-1:0] sum1;
    wire [`bits-1:0] sum2;
    wire [`bits-1:0] sum3_1;
    wire [`bits-1:0] sum3;
    wire [`bits-1:0] sum4;
    
    wire [2*`bits-1:0] sum1_117;
    wire [2*`bits-1:0] sum2_117;
    wire [2*`bits-1:0] sum3_1_117;
    wire [2*`bits-1:0] sum3_117;
    wire [2*`bits-1:0] sum4_117;
    wire [2*`bits-1:0] is_alfa_1_117;
    
    assign sum1 = sum1_117[`bits_frac + `bits:`bits_frac];
    assign sum2 = sum2_117[`bits_frac + `bits:`bits_frac];
    assign sum3_1 = sum3_1_117[`bits_frac + `bits:`bits_frac];
    assign sum3 = sum3_117[`bits_frac + `bits:`bits_frac];
    assign sum4 = sum4_117[`bits_frac + `bits:`bits_frac];      
    
    assign is_alfa_1_117 = sum1_117+sum2_117+sum3_117+sum4_117;
    assign is_alfa_1 = is_alfa_1_117[`bits_frac + `bits:`bits_frac];
    
    multiplicador eq1_mult1(
      .CLK(clk), // input wire CLK
      .A(c1),  // input wire [58 : 0] A
      .B(is_alfa),  // input wire [58 : 0] B
      .P(sum1_117)  // output wire [117 : 0] P
    );
    multiplicador eq1_mult2(
      .CLK(clk), // input wire CLK
      .A(c2),  // input wire [58 : 0] A
      .B(psir_alfa),  // input wire [58 : 0] B
      .P(sum2_117)  // output wire [117 : 0] P
    );
    multiplicador eq1_mult3(
      .CLK(clk), // input wire CLK
      .A(c3),  // input wire [58 : 0] A
      .B(wr),  // input wire [58 : 0] B
      .P(sum3_1_117)  // output wire [117 : 0] P
    );
    multiplicador eq1_mult4(
      .CLK(clk), // input wire CLK
      .A(sum3_1),  // input wire [58 : 0] A
      .B(psir_beta),  // input wire [58 : 0] B
      .P(sum3_117)  // output wire [117 : 0] P
    );
    multiplicador eq1_mult5(
      .CLK(clk), // input wire CLK
      .A(c4),  // input wire [58 : 0] A
      .B(vs_alfa),  // input wire [58 : 0] B
      .P(sum4_117)  // output wire [117 : 0] P
    );  
    
endmodule
