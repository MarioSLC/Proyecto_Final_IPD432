`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.05.2018 07:36:31
// Design Name: 
// Module Name: FSM_Controlador_RAM
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

// el flag "ultimo_dato" considera que el actual ciclo de reloj es el último ciclo de procesamiento,
// dando aviso que en el siguiente ciclo de reloj el controlador quedará disponible para más comandos. 

// ADDR: para incrementar la dirección cada 256 bits, addr debe aumentar 1 en el quinto bit.
module FSM_Controlador_RAM(
        // COMUNICACION CON EXTERIOR
        input reset,
        input write_request,
        input read_request,
        input [26:0] addr,
        input [255:0] data_in,
        output reg [255:0] data_out,
        output reg ultimo_dato,        
        output reg ready,  
        
        // COMUNICACION CON MIG
        input ui_clk,
        input app_rd_data_valid,
        input [127:0] app_rd_data,     
        input app_rdy,
        input app_wdf_rdy,   
        output reg app_en,
        output reg [2:0] app_cmd,
        output reg app_wdf_wren,
        output reg [26:0] app_addr,
        output reg [127:0] app_wdf_data        
    );
    
    parameter CANTIDAD_DATOS = 2;  
    parameter IDLE = 2'b00;
    parameter LEER = 2'b01;
    parameter ESCRIBIR = 2'b10;
    
    reg [1:0] estado = 0;
    reg [1:0] siguiente_estado; 
    
    
    reg [2:0] contador_data = 0;
    reg [2:0] contador_addr = 0;
    
    reg ready_data = 0;
    reg ready_addr = 0;    

    reg ready_data_reg = 0;
    reg ready_addr_reg = 0;  
    
    /////////////////////
    // LOGICA FSM
    /////////////////////
    always@(*) begin
        siguiente_estado = estado;
        case (estado)
            IDLE: begin
                if (write_request) begin
                    siguiente_estado = ESCRIBIR;
                end
                else if(read_request) begin
                    siguiente_estado = LEER;
                end
            end
            
            ESCRIBIR: begin   
                if (ready_addr && ready_data) begin
                    siguiente_estado = IDLE;
                end
            end 
            
            LEER: begin
                if (ready_data)
                    siguiente_estado = IDLE;
            end
                       
            default: begin
                siguiente_estado = IDLE;
            end
        endcase
    end 
    
    
    ///////////////////////////
    // CAMBIO DE ESTADO
    ///////////////////////////    
    always@(posedge ui_clk) begin
        if(reset) 
            estado <= IDLE;
        else 
            estado <= siguiente_estado;
    end
    
    //////////////////////////////////////////
    // CALCULO DE MEMORIA Y DATOS DE ESCRITURA
    //////////////////////////////////////////    
    always@(*) begin
        app_addr = addr + {21'b0,contador_addr,3'b0};        
        case (contador_data) 
            0: app_wdf_data = data_in[127:0];
            1: app_wdf_data = data_in[255:128];
            default: app_wdf_data = data_in[127:0];
       endcase
    end
    //////////////////////////////////////////
    // DATOS DE LECTURA
    //////////////////////////////////////////      
    always@(posedge ui_clk) begin
        data_out[255:0] <= data_out[255:0];                    
        case(contador_data)
            0: if (app_rd_data_valid) data_out[127:0] <= app_rd_data;
            1: if (app_rd_data_valid) data_out[255:128] <= app_rd_data;
        endcase
    end
    //////////////////////////////////////////
    // CALCULO COMBINACIONAL DE FLAGS
    //////////////////////////////////////////        
    always@(*) begin
         app_cmd = 0;   
         app_en = 0;
         app_wdf_wren = 0;
         ready_addr = 0;
         ready_data = 0;      
         ultimo_dato = 0; 
         case (estado)
             IDLE: begin
                 ultimo_dato = 1;
                 if (write_request) begin
                     ultimo_dato = 0;
                     app_en = 1;
                     app_wdf_wren = 1;
                 end
                 else if(read_request) begin
                     ultimo_dato = 0;
                     app_cmd = 1;    
                     app_en = 1;
                     app_wdf_wren = 1;
                 end
             end
             
             ESCRIBIR: begin   
                ready_addr = ((contador_addr >= (CANTIDAD_DATOS-1) && app_rdy) || ready_addr_reg) ? 1: 0;
                ready_data = ((contador_data >= (CANTIDAD_DATOS-1) && app_wdf_rdy) || ready_data_reg) ? 1: 0;                                
                app_en = ~ready_addr_reg;
                app_wdf_wren = ~ready_data_reg || (ultimo_dato && write_request);
                if (ready_addr && ready_data) begin
                    ultimo_dato = 1;                    
                end    
                                    
             end 
             
             LEER: begin
                 app_cmd = 1;
                 ready_addr = ((contador_addr >= (CANTIDAD_DATOS-1) && app_rdy) || ready_addr_reg) ? 1: 0;                 
                 ready_data = ((contador_data >= (CANTIDAD_DATOS - 1)) && app_rd_data_valid)? 1: 0;    
                 app_en = ~ready_addr_reg; 
                 if (ready_data) begin
                    ultimo_dato = 1;
                 end
             end
                        
             default: begin
                ultimo_dato = 0;
             end
         endcase
     end 
     
    //////////////////////////////////////////
    // CALCULO SECUENCIAL DE CONTADORES
    //////////////////////////////////////////      
    always@(posedge ui_clk) begin    
        ready <= ultimo_dato;    
        if (estado == IDLE) begin
            contador_addr <= 0;
            contador_data <= 0;
            ready_addr_reg <= 0;
            ready_data_reg <= 0;
            if (write_request) begin
                if (app_rdy && contador_addr < (CANTIDAD_DATOS-1)) begin 
                    contador_addr <= 1;    
                end
                if (app_wdf_rdy && contador_data < (CANTIDAD_DATOS-1) ) begin 
                    contador_data <= 1;
                end
            end    
            else if (read_request) begin
                if (app_rdy && contador_addr < (CANTIDAD_DATOS-1)) begin 
                    contador_addr <= contador_addr + 1; 
                end        
            end     
        end 
                                  
        else if (estado == ESCRIBIR) begin
            if (ultimo_dato) begin
                contador_addr <= 0;
                contador_data <= 0;
            end
            
            if (app_rdy && contador_addr < (CANTIDAD_DATOS-1)) begin 
                contador_addr <= contador_addr + 1;
                ready_addr_reg <= 0;
            end
            else if(app_rdy && contador_addr >= (CANTIDAD_DATOS-1)) begin
                ready_addr_reg <= ~ultimo_dato;            
            end
            
            if (app_wdf_rdy && contador_data < (CANTIDAD_DATOS-1) ) begin 
                contador_data <= contador_data + 1;
                ready_data_reg <= 0;  
            end  
            else if(app_wdf_rdy && contador_data >= (CANTIDAD_DATOS-1)) begin
                ready_data_reg <= ~ultimo_dato;            
            end  
        end
        else if (estado == LEER) begin
            if (ultimo_dato) begin        
                contador_addr <= 0;
                contador_data <= 0;
            end
            if (app_rdy && contador_addr < (CANTIDAD_DATOS-1)) begin 
                contador_addr <= contador_addr + 1;
                ready_addr_reg <= 0;
            end       
            else if(app_rdy && contador_addr >= (CANTIDAD_DATOS-1)) begin
                ready_addr_reg <= ~ultimo_dato;            
            end            
            if (app_rd_data_valid && contador_data <= (CANTIDAD_DATOS-1)) begin 
                contador_data <= contador_data + 1;
            end         
        end       
        else begin
            contador_data <= 2'd0;
            contador_addr <= 2'd0;
        end
    end
        
endmodule
