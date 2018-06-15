`timescale 1ns / 1ps
`include "parametros.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.05.2018 06:29:53
// Design Name: 
// Module Name: Trigger_Control
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


module Trigger_Control(
    input CLK100MHZ,          
    output ui_clk,    
    output reg trigger_end = 'd0,  
    output reg flag_trigger = 'd0,   
    input [5:0] trigger_config,
    input [`bits-1:0] trigger_level,
    input reset_trigger,
    input trigger_enable,
    input data_sent,
    output reg data_ready,
    output reg down_ready,
    output reg [255:0] data_trigger,
    output reg trigger_on = 1,
    ////////////////////      
    // SALIDAS PINES RAM      
    ////////////////////      
    output [12:0] ddr2_addr,  
    output [2:0] ddr2_ba,     
    output ddr2_cas_n,        
    output [0:0] ddr2_ck_n,   
    output [0:0] ddr2_ck_p,   
    output [0:0] ddr2_cke,    
    output ddr2_ras_n,        
    output ddr2_we_n,         
    inout [15:0] ddr2_dq,     
    inout [1:0] ddr2_dqs_n,   
    inout [1:0] ddr2_dqs_p,   
    output [0:0] ddr2_cs_n,   
    output [1:0] ddr2_dm,     
    output [0:0] ddr2_odt,
    
    // VARIABLES MOTOR
    input Sa,
    input Sb,
    input Sc,
    input [`bits-1:0] is_alfa,    
    input [`bits-1:0] is_beta,    
    input [`bits-1:0] psir_alfa,  
    input [`bits-1:0] psir_beta,  
    input [`bits-1:0] wr,
    input [`bits-1:0] TL,
    input en,
    input on                 
    );
    
    parameter CANTIDAD_DATOS = 10000;
    
    wire reset = 1'b0;
    reg write_request = 1'b0;
    reg read_request = 1'b0;
    reg [255:0] data_in;
    wire [255:0] data_out;
    
    wire ultimo_dato;
    wire ready;
    
    
    reg [`bits-1:0] data_trigg = 'd0;
    reg [`bits-1:0] data_trigg_1 = 'd0;
     
    reg [26:0] addr = 'd0;
    reg [26:0] contador_debug = 'd0;
    
    reg trigger_condition;
    reg flag_sending = 'd0;
    reg first_send = 'd0;
    reg [26:0] addr_condition = 'd0;
    reg [26:0] addr_last = 'd0;
    reg [26:0] contador_trigger = 'd0;
    wire [26:0] addr_RAM;   

    assign addr_RAM = {14'd0 ,addr , 4'd0};
    
    always@(posedge ui_clk) begin
        data_trigg_1 <= data_trigg;
        write_request <= 0;
        read_request <= 0;
        first_send <= 1;
        data_ready <= 1;
        down_ready <= 1;
        if (trigger_enable) begin        
            trigger_on <= 1;
            flag_trigger <= 0;
            trigger_end <= 0;
            contador_trigger <= 0;
            addr <= 0;            
        end 
        
        if (trigger_on) begin   
            if(reset_trigger) begin
                flag_trigger <= 0;
                trigger_end <= 0;
                data_trigg_1 <= 0;
                contador_trigger <= 0;
                addr <= 0;
            end
            ///////////////////////////////////////
            // ESCRITURA CONTINUA DE DATOS
            ///////////////////////////////////////                         
            else if(~trigger_end && on) begin
                if(trigger_condition) begin
                    addr_condition <= addr;
                    flag_trigger <= 1;    
                end
                if(en) begin 
                    write_request <= 1;
                    addr <= (addr >= CANTIDAD_DATOS - 1)? 0: addr + 1;
                    data_in <= {Sa, Sb, Sc,
                                is_alfa   [`bits-1:17],    
                                is_beta   [`bits-1:17],    
                                psir_alfa [`bits-1:17],  
                                psir_beta [`bits-1:17],  
                                wr        [`bits-1:17],         
                                TL        [`bits-1:17],
                                1'b0  
                                };                 
                    if(flag_trigger) begin
                        if (contador_trigger < CANTIDAD_DATOS/2) begin
                            contador_trigger <= contador_trigger + 1;
                        end
                        else begin
                            trigger_end <= 1;
                            down_ready <= 0;
                        end
                    end
                end
            end
            
            ///////////////////////////////////////
            // FIN DE TRIGGER
            ///////////////////////////////////////            
            else if(trigger_end) begin
                data_ready <= 0;
                down_ready <= 0;
                flag_sending <= 0;
                first_send <= 0;
                if (first_send) begin
                    addr_last <= addr;
                    contador_debug <= 0;
                end
                if((first_send || data_sent) && ready && ~write_request && ~read_request && ~down_ready) begin
                    read_request <= 1;
                    addr <= (addr >= CANTIDAD_DATOS - 1)? 0: addr + 1;
                    flag_sending <= 1;
                    contador_debug <= contador_debug + 1;
                end
                else if(ultimo_dato) begin                
                    data_trigger <= (~ready)? data_out: data_trigger;
                    data_ready <= 1;
                    if( addr + 1 == addr_last) begin
                        trigger_on <= 0;
                        down_ready <= 1;
                        trigger_end <= 0;
                    end    
                end  
            end  
        end  
    end
    
    /////////////////////////////////////////////////////////////
    //  CONFIGURACION TRIGGER
    /////////////////////////////////////////////////////////////
    always@(*) begin
        case(trigger_config[2:0])
            3'd0: data_trigg = is_alfa;
            3'd1: data_trigg = is_beta;
            3'd2: data_trigg = psir_alfa;
            3'd3: data_trigg = psir_beta;
            3'd4: data_trigg = wr;
            3'd5: data_trigg = TL;
            default: data_trigg = wr;
        endcase
        case(trigger_config[5:3])
            3'd0: trigger_condition = (($signed(data_trigg) >= $signed(trigger_level) && $signed(data_trigg_1) <= $signed(trigger_level)) || ($signed(data_trigg) <= $signed(trigger_level) && $signed(data_trigg_1) >= $signed(trigger_level)))? 1:0;
            3'd1: trigger_condition = ($signed(data_trigg) <= $signed(trigger_level))? 1:0;
            3'd2: trigger_condition = ($signed(data_trigg) < $signed(trigger_level))? 1:0;
            3'd3: trigger_condition = ($signed(data_trigg) >= $signed(trigger_level))? 1:0;
            3'd4: trigger_condition = ($signed(data_trigg) > $signed(trigger_level))? 1:0;
            default: trigger_condition = ($signed(data_trigg) >= $signed(trigger_level))? 1:0;
        endcase       
    end
    
    /////////////////////////////////////////////////////////////
    //  CONTROLADOR RAM
    /////////////////////////////////////////////////////////////    
    Controlador_RAM Controlador_RAM(
             .CLK100MHZ(CLK100MHZ),    
             .ui_clk(ui_clk),
             
             .ddr2_addr(ddr2_addr),
             .ddr2_ba(ddr2_ba),
             .ddr2_cas_n(ddr2_cas_n),
             .ddr2_ck_n(ddr2_ck_n),
             .ddr2_ck_p(ddr2_ck_p),      
             .ddr2_cke(ddr2_cke),       
             .ddr2_ras_n(ddr2_ras_n),           
             .ddr2_we_n(ddr2_we_n),
             .ddr2_dq(ddr2_dq),
             .ddr2_dqs_n(ddr2_dqs_n),      
             .ddr2_dqs_p(ddr2_dqs_p),
             .ddr2_cs_n(ddr2_cs_n),                    
             .ddr2_dm(ddr2_dm),                     
             .ddr2_odt(ddr2_odt),
             
             .reset(reset),
           
             .write_request(write_request),
             .read_request(read_request),
           
             .addr(addr_RAM),
             .data_in(data_in),
             .data_out(data_out),
           
             .ultimo_dato(ultimo_dato),
             .ready(ready)    
            
            );
endmodule
