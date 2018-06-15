//`timescale 1ns / 1ps
`include "parametros.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.09.2017 00:00:29
// Design Name: 
// Module Name: abc_alfabeta
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


module abc_alfabeta(
    input sa,
    input sb,
    input sc,
    input [58:0] vdc13,
    input [58:0] vdcs3,
    output [58:0] alfa,
    output [58:0] beta
    );

    wire [2:0] s;    
    assign s = {sa,sb,sc};
      
    reg [58:0] out1;
    reg [58:0] out2;    
    
    assign alfa = out1;
    assign beta = out2;
 
 
    ///////////////////////////////////////////////////
    // LOOK-UP-TABLE CONVERTIDOR
    ///////////////////////////////////////////////////  
    always @(*) begin
     case (s)
            3'b001 : begin
                        out1 = -vdc13;    
                        out2 = -vdcs3;
                     end
            3'b010 : begin
                        out1 = -vdc13;
                        out2 = vdcs3;
                     end
            3'b011 : begin
                        out1 = -vdc13*2;
                        out2 = 0;
                     end
            3'b100 : begin
                        out1 = vdc13*2;
                        out2 = 0;
                     end
            3'b101 : begin
                        out1 = vdc13;
                        out2 = -vdcs3;
                     end
            3'b110 : begin
                        out1 = vdc13;
                        out2 = vdcs3;
                     end
            default: begin
                        out1 = 0;
                        out2 = 0;
                     end
          endcase
     
     end
     
     
endmodule
