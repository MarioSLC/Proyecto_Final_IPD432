`timescale 1ns / 1ps
`include "parametros.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.05.2018 08:12:07
// Design Name: 
// Module Name: motor_core
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


module motor_core(
    input clk,
    input en,
    input rst,
    input [`bits-1:0] vdc13,
    input [`bits-1:0] vdcs3,
    input [`bits-1:0] eq1_c1,
    input [`bits-1:0] eq1_c2,
    input [`bits-1:0] eq1_c3,
    input [`bits-1:0] eq1_c4,    

    input [`bits-1:0] eq2_c5,
    input [`bits-1:0] eq2_c6,
    input [`bits-1:0] eq2_c7,
    input [`bits-1:0] eq2_c8,    
    
    input [`bits-1:0] eq3_c9,
    input [`bits-1:0] eq3_c10,
    input [`bits-1:0] eq3_c11,
    
    input [`bits-1:0] eq4_c12,
    input [`bits-1:0] eq4_c13,
    input [`bits-1:0] eq4_c14,
    
    input [`bits-1:0] eq5_c15, 
    input [`bits-1:0] eq5_c16, 
    
    input Sa,
    input Sb,
    input Sc,
    input [`bits-1:0] TL,    
    output reg [`bits-1:0] is_alfa,
    output reg [`bits-1:0] is_beta,    
    output reg [`bits-1:0] psir_alfa,
    output reg [`bits-1:0] psir_beta, 
    output reg [`bits-1:0] wr                
    );    

    wire [`bits-1:0] vs_alfa, vs_beta;
    wire[`bits-1:0] is_alfa_1, is_beta_1, psir_alfa_1, psir_beta_1, wr_1;
    
    // RETARDOS:
    // eq1: 2*retardo_multiplicador
    // eq2: 2*retardo_multiplicador
    // eq3: 2*retardo_multiplicador
    // eq4: 2*retardo_multiplicador
    // eq5: 2*retardo_multiplicador
    
    ////////////////////////////////////////////////////
    // CONVERTIDOR 2L-VSI
    ////////////////////////////////////////////////////
    abc_alfabeta convertidor(.sa(Sa), .sb(Sb), .sc(Sc), .vdc13(vdc13), .vdcs3(vdcs3), .alfa(vs_alfa), .beta(vs_beta));    
                                                         
    ////////////////////////////////////////////////////
    // ECUACIONES ELECTRO-MECÁNICAS DEL MOTOR
    ////////////////////////////////////////////////////
    eq1 eq_1(clk, eq1_c1, eq1_c2, eq1_c3, eq1_c4, is_alfa, psir_alfa, psir_beta, wr, vs_alfa, is_alfa_1);
    eq2 eq_2(clk, eq2_c5, eq2_c6, eq2_c7, eq2_c8, is_beta, psir_alfa, psir_beta, wr, vs_beta, is_beta_1);
    eq3 eq_3(clk, eq3_c9, eq3_c10, eq3_c11, is_alfa, psir_alfa, psir_beta, wr, psir_alfa_1);    
    eq4 eq_4(clk, eq4_c12, eq4_c13, eq4_c14, is_beta, psir_alfa, psir_beta, wr, psir_beta_1);  
    eq5 eq_5(clk, eq5_c15, eq5_c16, is_alfa, is_beta, psir_alfa, psir_beta, wr, TL, wr_1);

    ////////////////////////////////////////////////////
    // ACTUALIZACIÓN VARIABLES DE ESTADO
    ////////////////////////////////////////////////////    
    always @(posedge clk) begin
       is_alfa <= is_alfa;
       is_beta <= is_beta;
       psir_alfa <= psir_alfa;
       psir_beta <= psir_beta;
       wr <= wr;    
       if (rst) begin
           is_alfa <= `bits'd0;  
           is_beta <= `bits'd0;  
           psir_alfa <= `bits'd0;
           psir_beta <= `bits'd0;
           wr <= `bits'd0;       
       end        
       else if (en) begin
           is_alfa <= is_alfa_1;
           is_beta <= is_beta_1;
           psir_alfa <= psir_alfa_1;
           psir_beta <= psir_beta_1;
           wr <= wr_1;
       end
    end   
    
endmodule
