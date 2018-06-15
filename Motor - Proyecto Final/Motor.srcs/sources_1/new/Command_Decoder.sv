`timescale 1ns / 1ps
`include "parametros.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.05.2018 01:31:48
// Design Name: 
// Module Name: Command_Decoder
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


module Command_Decoder(
    input clk,
    input rx_ready,
    input [7:0] rx_data,
    input tx_busy,    
    output reg tx_start,
    output reg [7:0] tx_data,    
    input trigger_end,
    input down_ready,
    
    output [3:0] estado_ext,
    output reg on,
    
    output reg reconfig_ready,
    output reg [4:0] reconfig_dir,
    output reg [63:0] reconfig_data,
    output reg [5:0] trigger_config,
    output reg [`bits-1:0] trigger_level,
    output reg data_sent,
    output reg reset_trigger,
    input data_ready,
    input [255:0] data_trigger 
    
    
    );
    
    parameter IDLE = 4'd1;
    parameter RECONFIG_MOTOR = 4'd2;
    parameter RECONFIG_TRIGGER = 4'd3;
    parameter RUN = 4'd4;
    parameter DOWN_DATA = 4'd5;
    
    reg [3:0] estado = IDLE;
    reg [3:0] sig_estado = 0;
    reg [7:0] ult_comando = 0;
    reg reconfig_trigger_ready = 'd0;
    reg [4:0] reconfig_contador = 0;
    reg [6:0] contador_envio = 0;
    reg [63:0] trigger_level_temp = 0;
    reg last_sent = 'd0;
    reg last_sending = 'd0;
    
    wire [255:0] data_trigger_temp;
    assign data_trigger_temp = (data_trigger << contador_envio*7);
    assign estado_ext = estado;
    
    // TRANSICIONES DESDE IDLE:
    // 3'b001: RECONFIG_MOTOR
    // 3'b010: RECONFIG_TRIGGER 
    // 3'b011: RUN
    // 3'b100: DOWN_DATA   
    
    
    ////////////////////////////////////////
    // CALCULO DE TRANSICIONES DE ESTADO
    ////////////////////////////////////////    
    always_comb begin
        on = 0;
        sig_estado = estado;
        reset_trigger = 1;
        case (estado)
            IDLE: begin
                if (rx_ready) begin
                    if (rx_data[7:5] == 3'b010) begin
                        sig_estado = RECONFIG_MOTOR;
                    end
                    else if (rx_data[7:5] == 3'b011) begin
                        sig_estado = RECONFIG_TRIGGER;
                    end
                    else if (rx_data[7:5] == 3'b100) begin
                        sig_estado = RUN;
                    end                                                        
                    else if (rx_data[7:5] == 3'b101) begin
                        sig_estado = DOWN_DATA;
                    end
                    else if (rx_data[7:5] == 3'b111) begin
                    
                    end                                                        
                end           
            end            
            RECONFIG_MOTOR: begin
                if (reconfig_ready) begin
                    sig_estado = IDLE;
                end
            end
            RECONFIG_TRIGGER: begin
                if (reconfig_trigger_ready) begin
                    sig_estado = IDLE;
                end
            end
            RUN: begin
                on = 1;
                reset_trigger = 0;
                if(rx_data[7:5] == 3'b001) begin
                    sig_estado = IDLE;
                end
                else if(trigger_end) begin
                    sig_estado = DOWN_DATA;
                end
            end
            DOWN_DATA: begin
                on = 1;
                reset_trigger = 0;
                if(last_sent) begin
                    sig_estado = RUN;
                end
            end
        endcase
    end
    
    ////////////////////////////////////////
    // TRANSICION AL SIGUIENTE ESTADO
    ////////////////////////////////////////       
    always@(posedge clk) begin
        estado <= sig_estado;
    end
    
    
    ////////////////////////////////////////
    // CALCULO DE SEÑALES Y CONTROL DE DATOS
    ////////////////////////////////////////
    always@(posedge clk) begin
        // IDLE
        if((estado == IDLE)) begin
            reconfig_contador <= 0;
            reconfig_data <= 0;
            reconfig_ready <= 0;
            reconfig_trigger_ready <= 0;
            ult_comando <= 0;
            last_sent <= 0;
            last_sending <= 0;
            data_sent <= 0;
            if((rx_data[7:5] == 3'b001) || (rx_data[7:5] == 3'b010) && rx_ready) begin
                ult_comando <= rx_data;
                reconfig_dir <= rx_data[4:0];
            end 
        end
        
        // RECONFIG_MOTOR
        else if(estado == RECONFIG_MOTOR) begin
            if(rx_ready && reconfig_contador < 8) begin
                reconfig_data <= (reconfig_data >> 8) + {rx_data,56'd0};
                reconfig_contador <= reconfig_contador + 1;                
            end
            if(reconfig_contador >= 8) begin
                reconfig_ready <= (~reconfig_ready)?1:0;
                if (reconfig_ready) begin
                    reconfig_contador <= 0;
                    reconfig_data <= 0;
                    ult_comando <= 0;
                end    
            end
        end
        
        // RECONFIG_TRIGGER
        else if(estado == RECONFIG_TRIGGER) begin
            if(rx_ready && reconfig_contador < 9) begin
                if(reconfig_contador >= 1) begin
                    trigger_level_temp <= (trigger_level_temp >> 8) + {rx_data,56'd0};
                    reconfig_contador <= reconfig_contador + 1;             
                end
                else begin
                    trigger_config <= rx_data[5:0];
                    reconfig_contador <= reconfig_contador + 1;  
                end   
            end
            if(reconfig_contador >= 9) begin
                trigger_level <= trigger_level_temp[`bits-1:0];
                reconfig_trigger_ready <= (~reconfig_trigger_ready)?1:0;
                if (reconfig_trigger_ready) begin
                    trigger_level_temp <= 0;
                    reconfig_contador <= 0;
                    reconfig_data <= 0;
                    ult_comando <= 0;
                end    
            end
        end
        
        // DOWN_DATA        
        else if(estado == DOWN_DATA) begin
            tx_start <= 1'b0;
            data_sent <= 0;
            if (data_ready & ~data_sent) begin                
                if (~tx_busy && ~tx_start && contador_envio < 37) begin
                    data_sent <= 0;
                    contador_envio <= (contador_envio < 37)? contador_envio + 1: contador_envio;
                    tx_start <= (contador_envio < 37 && ~last_sent)? 1'b1:0;
                    if(~last_sending) begin
                        if(contador_envio == 0)
                            tx_data <= {1'b1, data_trigger_temp[255:249]};
                        else
                            tx_data <= {1'b0, data_trigger_temp[255:249]};
                    end
                    else begin
                        tx_data <= 8'hFF;
                    end                                
                end                   
                else if(~tx_busy && contador_envio >= 37 && ~tx_start) begin
                    data_sent <= 1;
                    contador_envio <= 0;
                    last_sending <= down_ready;
                    last_sent <= last_sending;
                end
            end
        end
    end
    
endmodule
