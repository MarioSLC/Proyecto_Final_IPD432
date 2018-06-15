//`timescale 1ns / 1ps
`include "parametros.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.09.2017 22:49:56
// Design Name: 
// Module Name: eq4
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


module eq4(
    input clk,
    input [`bits-1:0] c12,
    input [`bits-1:0] c13,
    input [`bits-1:0] c14,
    input [`bits-1:0] is_beta,
    input [`bits-1:0] psir_alfa,
    input [`bits-1:0] psir_beta,
    input [`bits-1:0] wr,
    output [`bits-1:0] psir_beta_1
);

wire [`bits-1:0] sum1;
wire [`bits-1:0] sum2;
wire [`bits-1:0] sum3_1;
wire [`bits-1:0] sum3;

wire [2*`bits-1:0] sum1_117;
wire [2*`bits-1:0] sum2_117;
wire [2*`bits-1:0] sum3_1_117;
wire [2*`bits-1:0] sum3_117;
wire [2*`bits-1:0] psir_beta_1_117;

    assign sum1 = sum1_117[`bits_frac + `bits:`bits_frac];
    assign sum2 = sum2_117[`bits_frac + `bits:`bits_frac];
    assign sum3_1 = sum3_1_117[`bits_frac + `bits:`bits_frac];
    assign sum3 = sum3_117[`bits_frac + `bits:`bits_frac];
    
assign psir_beta_1_117 = sum1_117+sum2_117+sum3_117;
assign psir_beta_1 = psir_beta_1_117[`bits_frac + `bits:`bits_frac];

multiplicador eq4_mult1(
  .CLK(clk), // input wire CLK
  .A(c12),  // input wire [58 : 0] A
  .B(is_beta),  // input wire [58 : 0] B
  .P(sum1_117)  // output wire [117 : 0] P
);
multiplicador eq4_mult2(
  .CLK(clk), // input wire CLK
  .A(c13),  // input wire [58 : 0] A
  .B(wr),  // input wire [58 : 0] B
  .P(sum3_1_117)  // output wire [117 : 0] P
);
multiplicador eq4_mult3(
  .CLK(clk), // input wire CLK
  .A(sum3_1),  // input wire [58 : 0] A
  .B(psir_alfa),  // input wire [58 : 0] B
  .P(sum3_117)  // output wire [117 : 0] P
);
  multiplicador eq4_mult4(
    .CLK(clk), // input wire CLK
    .A(c14),  // input wire [58 : 0] A
    .B(psir_beta),  // input wire [58 : 0] B
    .P(sum2_117)  // output wire [117 : 0] P
  );
endmodule

