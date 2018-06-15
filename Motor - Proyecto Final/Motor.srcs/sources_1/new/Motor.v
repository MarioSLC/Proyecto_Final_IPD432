//`timescale 1ns / 1ps
`include "parametros.v"

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.09.2017 01:42:00
// Design Name: 
// Module Name: Motor
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


module Motor(
    input CLK100MHZ,
    output uart_tx,
    input  uart_rx,    
    input  uart_rts,
    output uart_cts,
	input [15:0] sw, 
	input BTNC,
	inout [7:0] JA,
	output [7:0] JB,
    output [15:0] led,
    output RGB_1_Red,
    output RGB_1_Green,
    output RGB_1_Blue,
    output RGB_2_Red,
    output RGB_2_Green,
    output RGB_2_Blue,    
    output [6:0] seg,
    output [7:0] an, 
    output dp,
    
    //////////////////////////////
    //MEMORIA RAM
    //////////////////////////////
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
    output [0:0] ddr2_odt
    );
              
    
    parameter N_DIV = 15;
    parameter LOGIC_CLOCK = 50000000;
    parameter MAX_CUENTA_INTERNA = LOGIC_CLOCK/50;
    parameter IDLE = 4'd1;
    parameter RECONFIG_MOTOR = 4'd2;
    parameter RECONFIG_TRIGGER = 4'd3;
    parameter RUN = 4'd4;
    parameter DOWN_DATA = 4'd5;
      
    wire clk;
    wire ui_clk;
    assign clk = ui_clk;    
    
    wire trigger_enable;
    wire trigger_on;
    
    ///////////////////////////////////
    // DEBOUNCER
    ///////////////////////////////////
    deb deb(
        .clk(clk),
        .boton(BTNC),
        .boton_valido(trigger_enable)
        );       
    wire [7:0] rx_data, tx_data;
    wire rx_ready, tx_start, tx_busy;
    
    ///////////////////////////////////
    // PERIFERICO UART
    ///////////////////////////////////        
    uart_basic #(
        .CLK_FREQUENCY(LOGIC_CLOCK),
        //.BAUD_RATE(921600)
        .BAUD_RATE(115200)
    ) uart_basic_inst (
        .clk(clk),
        .reset(),
        
        // UART
        .rx(uart_rx),
        .tx(uart_tx),
        .CTS(uart_cts),
        .RTS(uart_rts),
        
        // FPGA
        .rx_data(rx_data),
        .rx_ready(rx_ready),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_busy(tx_busy)        
    );    
    
    wire on, reconfig_ready;
    wire [4:0] reconfig_dir;
    wire [63:0] reconfig_data;
    wire [3:0] estado_ext;
    wire [5:0] trigger_config;
    wire [`bits-1:0] trigger_level;
    wire [255:0] data_trigger;
    
    
    // ESTADOS LEDS:
    // | 15 | 14 | 13 | 12 |
    //   0    0    0    1   : IDLE
    //   0    0    1    0   : RECONFIG_MOTOR
    //   0    0    1    1   : RECONFIG_TRIGGER
    //   0    1    0    0   : RUN
    //   0    1    0    1   : DOWN_DATA
    
    assign led[15:12] = estado_ext;
    wire down_ready;
    wire data_sent;
    wire data_ready;
    wire trigger_end;
    wire reset_trigger;
    wire blink_led;
    reg [31:0] blink_counter = 0;
    assign RGB_1_Green = (flag_trigger && ~trigger_end && trigger_on)? 1:0;
    //assign RGB_1_Red = (estado_ext == RUN && trigger_end)? 1:0;
    
    assign RGB_2_Green = (estado_ext == DOWN_DATA && blink_led)? 1:0;
    assign RGB_2_Red = (estado_ext == RUN && down_ready  && ~trigger_on)? 1:0;
    assign RGB_2_Blue = (estado_ext == RUN && down_ready && trigger_on)? 1:0; 
    always@(posedge clk) begin
        blink_counter <= (blink_counter > 'd49_999_999)? 0: blink_counter + 1;
    end
    assign blink_led = (blink_counter >= 'd25_000_000)? 1:0;   
    ///////////////////////////////////
    // CONTROLADOR GENERAL
    ///////////////////////////////////    
    Command_Decoder Command_Decoder(
        .clk(clk),
        .rx_ready(rx_ready),
        .rx_data(rx_data),
        .tx_busy(tx_busy),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .trigger_end(trigger_end),
        .down_ready(down_ready),
        .estado_ext(estado_ext),
        .on(on),
       
        .reconfig_ready(reconfig_ready),
        .reconfig_dir(reconfig_dir),
        .reconfig_data(reconfig_data),
        .trigger_config(trigger_config),
        .trigger_level(trigger_level),
        .data_sent(data_sent),
        .data_ready(data_ready),
        .data_trigger(data_trigger),
        .reset_trigger(reset_trigger)
        
    );    
    ////////////////////////////////////////////////
    ////////////////////////////////////////////////                
            
    ////////////////////////////////////////////////
    // REGISTROS DE CONFIGURACIÓN
    ////////////////////////////////////////////////
    reg [`bits-1:0] eq1_c1 = 0;
    reg [`bits-1:0] eq1_c2 = 0;
    reg [`bits-1:0] eq1_c3 = 0;
    reg [`bits-1:0] eq1_c4 = 0;
                             
    reg [`bits-1:0] eq2_c5 = 0;
    reg [`bits-1:0] eq2_c6 = 0;
    reg [`bits-1:0] eq2_c7 = 0;
    reg [`bits-1:0] eq2_c8 = 0;
    
    reg [`bits-1:0] eq3_c9 = 0;  
    reg [`bits-1:0] eq3_c10 = 0;
    reg [`bits-1:0] eq3_c11 = 0;
                              
    reg [`bits-1:0] eq4_c12 = 0;
    reg [`bits-1:0] eq4_c13 = 0;
    reg [`bits-1:0] eq4_c14 = 0;
                              
    reg [`bits-1:0] eq5_c15 = 0;  
    reg [`bits-1:0] eq5_c16 = 0;  
    
    reg [`bits-1:0] vdc13 = 0;
    reg [`bits-1:0] vdcs3 = 0;
    
    always@(posedge clk) begin
        case(reconfig_dir)
            5'd1: eq1_c1 <= (reconfig_ready)? reconfig_data[58:0]: eq1_c1;
            5'd2: eq1_c2 <= (reconfig_ready)? reconfig_data[58:0]: eq1_c2;
            5'd3: eq1_c3 <= (reconfig_ready)? reconfig_data[58:0]: eq1_c3;
            5'd4: eq1_c4 <= (reconfig_ready)? reconfig_data[58:0]: eq1_c4;
            5'd5: eq2_c5 <= (reconfig_ready)? reconfig_data[58:0]: eq2_c5;
            5'd6: eq2_c6 <= (reconfig_ready)? reconfig_data[58:0]: eq2_c6;
            5'd7: eq2_c7 <= (reconfig_ready)? reconfig_data[58:0]: eq2_c7;
            5'd8: eq2_c8 <= (reconfig_ready)? reconfig_data[58:0]: eq2_c8;
            5'd9: eq3_c9 <= (reconfig_ready)? reconfig_data[58:0]: eq3_c9;
            5'd10: eq3_c10 <= (reconfig_ready)? reconfig_data[58:0]: eq3_c10;
            5'd11: eq3_c11 <= (reconfig_ready)? reconfig_data[58:0]: eq3_c11;
            5'd12: eq4_c12 <= (reconfig_ready)? reconfig_data[58:0]: eq4_c12;
            5'd13: eq4_c13 <= (reconfig_ready)? reconfig_data[58:0]: eq4_c13;
            5'd14: eq4_c14 <= (reconfig_ready)? reconfig_data[58:0]: eq4_c14;
            5'd15: eq5_c15 <= (reconfig_ready)? reconfig_data[58:0]: eq5_c15;
            5'd16: eq5_c16 <= (reconfig_ready)? reconfig_data[58:0]: eq5_c16;           
            5'd17: vdc13 <= (reconfig_ready)? reconfig_data[58:0]: vdc13;
            5'd18: vdcs3 <= (reconfig_ready)? reconfig_data[58:0]: vdcs3;
            default: vdc13 <= vdc13;
        endcase    
    end
    ////////////////////////////////////////////////
    ////////////////////////////////////////////////        
    
    ///////////////////////////////////////////////////
    // REFERENCIA INTERNA
    ///////////////////////////////////////////////////    
    reg [20:0] cuenta2 = 21'b0;
    wire Sa_int, Sb_int, Sc_int;
    always @(posedge clk) begin
        cuenta2 <= (cuenta2 <= MAX_CUENTA_INTERNA)? cuenta2 + 1:0;
    end
    assign Sa_int = (cuenta2 < MAX_CUENTA_INTERNA/2 && ~sw[13])? 1:0;
    assign Sb_int = (MAX_CUENTA_INTERNA/3 < cuenta2 && cuenta2 < MAX_CUENTA_INTERNA*5/6 && ~sw[13])? 1:0;
    assign Sc_int = ((MAX_CUENTA_INTERNA/6 < cuenta2 && cuenta2 < MAX_CUENTA_INTERNA*2/3)||sw[13] )? 0:1;
    ///////////////////////////////////////////////////
    ///////////////////////////////////////////////////        
    
    ////////////////////////////////////////////////
    // VARIABLES MOTOR
    ////////////////////////////////////////////////
    wire [`bits-1:0] is_alfa, is_beta, psir_alfa, psir_beta, wr;
    reg rst_motor = 'd0;
    reg [`bits-1:0] disp = `bits'd0;
    reg [`bits-1:0] disp_w;
    reg [7:0] JA_reg;
    reg [63:0] cuenta = 'b0;
    wire [`bits-1:0] TL;
    wire en;    
    wire Sa, Sb, Sc;
    assign Sa = (sw[11])? JA_reg[0] : Sa_int;
    assign Sb = (sw[11])? JA_reg[1] : Sb_int;
    assign Sc = (sw[11])? JA_reg[2] : Sc_int;
    
    assign JA[4] = Sa_int;
    assign JA[5] = Sb_int;
    assign JA[6] = Sc_int;
    
    assign led[2:0] = {Sa,Sb,Sc};    
    
    assign led[3] = flag_trigger;            
    assign led[4] = trigger_end;
    assign led[6] = uart_rts;
    assign led[7] = uart_cts;
    
    assign TL[58:46] = 'd0;
    assign TL[45:0] = 46'd0;
    ////////////////////////////////////////////////
    ////////////////////////////////////////////////           
    
    ///////////////////////////////////////////////////
    // GENERADOR ENABLE
    ///////////////////////////////////////////////////
    always @(posedge clk) begin
        JA_reg[0] <= JA[0];
        JA_reg[1] <= JA[1];
        JA_reg[2] <= JA[2];
        JA_reg[4] <= Sa_int;
        JA_reg[5] <= Sb_int;
        JA_reg[6] <= Sc_int;
        if (cuenta < N_DIV-1)
            cuenta <= cuenta + 1;
        else
            cuenta <= 0;              
    end
    assign en = ((cuenta == 0) && on);
    ///////////////////////////////////////////////////
    ///////////////////////////////////////////////////        
    
    ////////////////////////////////////////////////////
    // NUCLEO MOTOR
    ///////////////////////////////////////////////////
    motor_core motor_core(
        clk,
        en,
        rst_motor,
        vdc13,
        vdcs3,
        eq1_c1,
        eq1_c2,
        eq1_c3,
        eq1_c4,       
        eq2_c5,
        eq2_c6,
        eq2_c7,
        eq2_c8,           
        eq3_c9,
        eq3_c10,
        eq3_c11,       
        eq4_c12,
        eq4_c13,
        eq4_c14,       
        eq5_c15, 
        eq5_c16,        
        Sa,
        Sb,
        Sc,
        TL,    
        is_alfa,
        is_beta,    
        psir_alfa,
        psir_beta, 
        wr                
        ); 
    ///////////////////////////////////////////////////
    ///////////////////////////////////////////////////
    

    ///////////////////////////////////////////////////
    // DISPLAY DE VARIABLES
    ///////////////////////////////////////////////////
    wire [19:0] bcdout;
    reg  [31:0] x;    
    always @(posedge clk) begin
        rst_motor <= 0;   
        if(sw[14]) begin
            rst_motor <= 1;
        end
        if (sw[15]) begin
            if (disp_w[`bits-1]) begin
                disp[`bits-1] <= 1'b1;
                disp[`bits-2:0] <= ~disp_w[`bits-2:0] + 'd1;
            end
            else begin
                disp <= disp_w;
            end
        end
    end    
    
    always @(*) begin
        if(disp[`bits - 1] == 1'b1)     	
    	begin
    	     x[31:28] = 'hA;//'hC;
        end
        else begin
            x[31:28] = 0;//'hC;
        end
        x[27:24] = 0; //hundreds;
        x[23:20] = 0;// tens;
        x[19:16] = 0;//ones;
        x[15:12] = bcdout[15:12];//'hC;
        x[11:8] = bcdout[11:8]; //hundreds;
        x[7:4] = bcdout[7:4];// tens;
        x[3:0] = bcdout[3:0];//ones;
    end        
    always @(*) begin
         case (sw[5:3])
          3'b000 : disp_w = is_alfa;
          3'b001 : disp_w = is_beta;
          3'b010 : disp_w = psir_alfa;
          3'b011 : disp_w = psir_beta;
          3'b100 : disp_w = wr;
          default: disp_w = `bits'd0;
        endcase
    end    
    bin_to_decimal u1 (
    .B({4'b0,disp[`bits - 2:`bits_frac]}), 
    .bcdout(bcdout)
    );    
    seg7decimal u7 (    
    .x(x),
    .clk(clk),
    .a_to_g(seg),
    .an(an),
    .dp(dp)
    );
    ///////////////////////////////////////////////////
    ///////////////////////////////////////////////////      

    //////////////////////////////////////////////
    // TRIGGER CONTROL
    //////////////////////////////////////////////    
    wire [0:0] en_log;    
    reg [20:0] cuenta_log = 'd0;
    reg [20:0] max_cuenta_log;
    assign en_log[0] = ((cuenta_log == 0) && en)?1:0;
    
    // DOWNSAMPLING DEL PASO DE TIEMPO DE SIMULACION
    always @(*) begin
        case({sw[2],sw[1],sw[0]})
            3'b000 : max_cuenta_log = 'd19; // 1MHZ
            3'b001 : max_cuenta_log = 'd49; // 500KHZ
            3'b010 : max_cuenta_log = 'd199; // 250KHZ
            3'b011 : max_cuenta_log = 'd499; // 100KHZ 
            3'b100 : max_cuenta_log = 'd1_999; // 50KHZ
            3'b101 : max_cuenta_log = 'd3_999; // 25KHZ
            3'b110 : max_cuenta_log = 'd9_999; // 10KHZ
            3'b111 : max_cuenta_log = 'd19_999; // 5KHZ
            default: max_cuenta_log = 'd9_999;
        endcase            
    end
    always @(posedge clk) begin
        if(en) begin
            cuenta_log <= (cuenta_log < max_cuenta_log)? cuenta_log + 1:0;
        end
    end    
    
    wire flag_trigger;
    wire en_trigger;
    
    assign en_trigger = (sw[12])? en_log[0]: en;
    Trigger_Control Trigger_Control(
        .CLK100MHZ(CLK100MHZ),    
        .ui_clk(ui_clk),
        .trigger_end(trigger_end),    
        .flag_trigger(flag_trigger),
        .trigger_config(trigger_config),
        .trigger_level(trigger_level),
        .reset_trigger(reset_trigger),
        .trigger_enable(trigger_enable),
        .data_sent(data_sent),
        .data_ready(data_ready),
        .down_ready(down_ready),
        .data_trigger(data_trigger),
        .trigger_on(trigger_on),
        
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
        
        .Sa(Sa),
        .Sb(Sb),
        .Sc(Sc),   
        .is_alfa(is_alfa),    
        .is_beta(is_beta),    
        .psir_alfa(psir_alfa),
        .psir_beta(psir_beta),
        .wr(wr),
        .TL(TL),
        .en(en_trigger),
        .on(on)           
        );
        
  ////////////////////////////////////////
  // VARIABLES ANALOGICAS CON SIGNO
  ////////////////////////////////////////    
  
  wire [31:0] is_alfa_mod;
  wire [31:0] is_beta_mod;
  wire [31:0] wr_mod;
  wire [31:0] psir_alfa_mod;
                                                                      // [         entero           ] << 5
  assign is_alfa_mod = ($signed(is_alfa[`bits-1:`bits-1-31]) >>> 14); // [(is_alfa[58:58-31]) >> 19 ] << 5  
  assign is_beta_mod = ($signed(is_beta[`bits-1:`bits-1-31]) >>> 14); // [(is_beta[58:58-31]) >> 19 ] << 5 
  assign wr_mod = ($signed(wr[`bits-1:`bits-1-31]) >>> 18);           // [     (wr[58:58-31]) >> 19 ] << 1

    ////////////////////////////////////////
    // MODULADORES DE VARIABLES ANALOGICAS
    ////////////////////////////////////////
     Modulador_PWM  #(
       .CLK_FREQUENCY(LOGIC_CLOCK),
       .FREQ_PWM(10000),
       .CUENTA_INICIAL(0),
       .DEBUG(0)
       ) 
       Modulador_PWM1(
     .clk(clk),
     .entrada(is_alfa_mod),
     .enable(1'b1),
     .en_log(en_log),
     .salida_PWM(JB[0])
     );   
     
    Modulador_PWM  #(
       .CLK_FREQUENCY(LOGIC_CLOCK),
       .FREQ_PWM(10000),
       .CUENTA_INICIAL(0),
       .DEBUG(0)
        )         
        Modulador_PWM2(
    .clk(clk),
    .entrada(is_beta_mod),
    .enable(1'b1),
    .en_log(en_log),
    .salida_PWM(JB[1])
    );   
    
    Modulador_PWM #(
           .CLK_FREQUENCY(LOGIC_CLOCK),
           .FREQ_PWM(10000),
           .CUENTA_INICIAL(0),
           .DEBUG(0)
        )      
        Modulador_PWM3(
    .clk(clk),
    .entrada(wr_mod),
    .enable(1'b1),
    .en_log(en_log),
    .salida_PWM(JB[2])
    );         
    
    
    
endmodule
