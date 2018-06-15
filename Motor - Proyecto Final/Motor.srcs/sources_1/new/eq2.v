//`timescale 1ns / 1ps
`include "parametros.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.09.2017 02:45:36
// Design Name: 
// Module Name: eq2
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


module eq2(
    input clk,
    input [`bits-1:0] c5,
    input [`bits-1:0] c6,
    input [`bits-1:0] c7,
    input [`bits-1:0] c8,
    input [`bits-1:0] is_beta,
    input [`bits-1:0] psir_alfa,
    input [`bits-1:0] psir_beta,
    input [`bits-1:0] wr,
    input [`bits-1:0] vs_beta,
    output [`bits-1:0] is_beta_1
    );
    
    wire [`bits-1:0] sum1;
    wire [`bits-1:0] sum2_1;
    wire [`bits-1:0] sum2;
    wire [`bits-1:0] sum3;
    wire [`bits-1:0] sum4;
    
    wire [2*`bits-1:0] sum1_117;
    wire [2*`bits-1:0] sum2_1_117;
    wire [2*`bits-1:0] sum2_117;
    wire [2*`bits-1:0] sum3_117;
    wire [2*`bits-1:0] sum4_117;
    wire [2*`bits-1:0] is_beta_1_117;
    
    assign sum1 = sum1_117[`bits_frac + `bits:`bits_frac];
    assign sum2_1 = sum2_1_117[`bits_frac + `bits:`bits_frac];
    assign sum2 = sum2_117[`bits_frac + `bits:`bits_frac];
    assign sum3 = sum3_117[`bits_frac + `bits:`bits_frac];
    assign sum4 = sum4_117[`bits_frac + `bits:`bits_frac];      
    
    assign is_beta_1_117 = sum1_117+sum2_117+sum3_117+sum4_117;
    assign is_beta_1 = is_beta_1_117[`bits_frac + `bits:`bits_frac];
    
    multiplicador eq2_mult1(
      .CLK(clk), // input wire CLK
      .A(c5),  // input wire [58 : 0] A
      .B(is_beta),  // input wire [58 : 0] B
      .P(sum1_117)  // output wire [117 : 0] P
    );
    multiplicador eq2_mult2(
      .CLK(clk), // input wire CLK
      .A(c6),  // input wire [58 : 0] A
      .B(wr),  // input wire [58 : 0] B
      .P(sum2_1_117)  // output wire [117 : 0] P
    );
    multiplicador eq2_mult3(
      .CLK(clk), // input wire CLK
      .A(sum2_1),  // input wire [58 : 0] A
      .B(psir_alfa),  // input wire [58 : 0] B
      .P(sum2_117)  // output wire [117 : 0] P
    );
    multiplicador eq2_mult4(
      .CLK(clk), // input wire CLK
      .A(c7),  // input wire [58 : 0] A
      .B(psir_beta),  // input wire [58 : 0] B
      .P(sum3_117)  // output wire [117 : 0] P
    );
    multiplicador eq2_mult5(
      .CLK(clk), // input wire CLK
      .A(c8),  // input wire [58 : 0] A
      .B(vs_beta),  // input wire [58 : 0] B
      .P(sum4_117)  // output wire [117 : 0] P
    );  
    
endmodule
