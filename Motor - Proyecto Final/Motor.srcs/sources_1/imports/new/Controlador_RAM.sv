`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.05.2018 01:13:09
// Design Name: 
// Module Name: Controlador_RAM
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


module Controlador_RAM(
    input CLK100MHZ,    
    output ui_clk,
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
    
    
    ////////////////////
    // INTERFAZ
    ///////////////////
    input reset,
    
    input write_request,
    input read_request,
    
    input [26:0] addr,
    input [255:0] data_in,
    output [255:0] data_out,
    
    output ultimo_dato,
    output ready    
    
    );
    
  
    wire CLK200MHZ;

    wire [26:0] app_addr;
    wire [2:0] app_cmd;
    wire app_en;
    wire [127:0] app_rd_data;
    wire app_rd_data_end;
    wire app_rd_data_valid;
    wire app_rdy;
    wire app_sr_active;
    wire app_sr_req;
    wire [127:0]app_wdf_data;
    wire app_wdf_end;
    wire [15:0]app_wdf_mask;
    wire app_wdf_rdy;
    wire app_wdf_wren;
    wire init_calib_complete;
    
    assign app_wdf_end = app_wdf_wren;
    assign app_wdf_mask = 16'b0;
    
    
    
  ////////////////////////////////////
  // CLOCK MIG
  ////////////////////////////////////
      clock_mig clock_mig
      (
      // Clock out ports
      .clk_out1(CLK200MHZ),     // output clk_out1
     // Clock in ports
      .clk_in1(CLK100MHZ));      
  
  
  /////////////////////////////////////
  // MODULO MIG
  /////////////////////////////////////
    mig_7series_0 mig_7series_0 (
      // Memory interface ports
      .ddr2_addr                      (ddr2_addr),  // output [12:0]                       ddr2_addr
      .ddr2_ba                        (ddr2_ba),  // output [2:0]                      ddr2_ba
      .ddr2_cas_n                     (ddr2_cas_n),  // output                                       ddr2_cas_n
      .ddr2_ck_n                      (ddr2_ck_n),  // output [0:0]                        ddr2_ck_n
      .ddr2_ck_p                      (ddr2_ck_p),  // output [0:0]                        ddr2_ck_p
      .ddr2_cke                       (ddr2_cke),  // output [0:0]                       ddr2_cke
      .ddr2_ras_n                     (ddr2_ras_n),  // output                                       ddr2_ras_n
      .ddr2_we_n                      (ddr2_we_n),  // output                                       ddr2_we_n
      .ddr2_dq                        (ddr2_dq),  // inout [15:0]                         ddr2_dq
      .ddr2_dqs_n                     (ddr2_dqs_n),  // inout [1:0]                        ddr2_dqs_n
      .ddr2_dqs_p                     (ddr2_dqs_p),  // inout [1:0]                        ddr2_dqs_p
      .init_calib_complete            (init_calib_complete),  // output                                       init_calib_complete
      .ddr2_cs_n                      (ddr2_cs_n),  // output [0:0]           ddr2_cs_n
      .ddr2_dm                        (ddr2_dm),  // output [1:0]                        ddr2_dm
      .ddr2_odt                       (ddr2_odt),  // output [0:0]                       ddr2_odt
      // Application interface ports
      .app_addr                       (app_addr),  // input [26:0]                       app_addr
      .app_cmd                        (app_cmd),  // input [2:0]                                  app_cmd
      .app_en                         (app_en),  // input                                        app_en
      .app_wdf_data                   (app_wdf_data),  // input [127:0]    app_wdf_data
      .app_wdf_end                    (app_wdf_end),  // input                                        app_wdf_end
      .app_wdf_wren                   (app_wdf_wren),  // input                                        app_wdf_wren
      .app_rd_data                    (app_rd_data),  // output [127:0]   app_rd_data
      .app_rd_data_end                (app_rd_data_end),  // output                                       app_rd_data_end
      .app_rd_data_valid              (app_rd_data_valid),  // output                                       app_rd_data_valid
      .app_rdy                        (app_rdy),  // output                                       app_rdy
      .app_wdf_rdy                    (app_wdf_rdy),  // output                                       app_wdf_rdy
      .app_sr_req                     (1'b0),  // input                                        app_sr_req
      .app_ref_req                    (1'b0),  // input                                        app_ref_req
      .app_zq_req                     (1'b0),  // input                                        app_zq_req
      .app_sr_active                  (),  // output                                       app_sr_active
      .app_ref_ack                    (),//app_ref_ack),  // output                                       app_ref_ack
      .app_zq_ack                     (),//app_zq_ack),  // output                                       app_zq_ack
      .ui_clk                         (ui_clk),  // output                                       ui_clk
      .ui_clk_sync_rst                (),  // output                                       ui_clk_sync_rst
        
      .app_wdf_mask                   (app_wdf_mask),  // input [15:0]  app_wdf_mask
      
      // System Clock Ports
      .sys_clk_i                       (CLK200MHZ),  
      .sys_rst                        (1'b1) // input  sys_rst
      );




    /////////////////////////////////////////
    // FSM CONTROLADOR RAM
    ////////////////////////////////////////        
    FSM_Controlador_RAM FSM_Controlador_RAM(
            // COMUNICACION CON EXTERIOR
            .reset(reset),
            .write_request(write_request),
            .read_request(read_request),
            .addr(addr),
            .data_in(data_in),
            .data_out(data_out),
            .ultimo_dato(ultimo_dato),
            .ready(ready),
            
            // COMUNICACION CON MIG
            .ui_clk(ui_clk),
            .app_rd_data_valid(app_rd_data_valid), 
            .app_rd_data(app_rd_data), 
             
            .app_rdy(app_rdy),
            .app_wdf_rdy(app_wdf_rdy),   
            .app_en(app_en),
            .app_cmd(app_cmd),
            .app_wdf_wren(app_wdf_wren),
            .app_addr(app_addr),
            .app_wdf_data(app_wdf_data)        
        );
endmodule
