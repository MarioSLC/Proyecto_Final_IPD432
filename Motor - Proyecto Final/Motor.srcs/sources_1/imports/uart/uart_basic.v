/*
 * uart_basic.v
 * 2017/02/01 - Felipe Veas <felipe.veasv at usm.cl>
 *
 * Universal Asynchronous Receiver/Transmitter.
 */

`timescale 1ns / 1ps

module uart_basic
#(
	parameter CLK_FREQUENCY = 100000000,
	parameter BAUD_RATE = 115200
)(
	input clk,
	
	// UART
    input reset,
    input rx,
    output tx,
    output CTS,
    input RTS,
        
    // FPGA
    output [7:0] rx_data,
    output reg rx_ready,   
    input tx_start,
    input [7:0] tx_data,
    output tx_busy	
	
);

	wire baud8_tick;
	wire baud_tick;

	reg rx_ready_sync;
	wire rx_ready_pre;
    wire tx_busy_temp;
    // SIEMPRE DISPONIBLE PARA RECIBIR
    assign CTS = 0;
    // tx_busy CONSIDERA EL ESTADO DEL RECEPTOR
    assign tx_busy = tx_busy_temp || RTS;
    
	uart_baud_tick_gen #(
		.CLK_FREQUENCY(CLK_FREQUENCY),
		.BAUD_RATE(BAUD_RATE),
		.OVERSAMPLING(8)
	) baud8_tick_blk (
		.clk(clk),
		.enable(1'b1),
		.tick(baud8_tick)
	);

	uart_rx uart_rx_blk (
		.clk(clk),
		.reset(reset),
		.baud8_tick(baud8_tick),
		.rx(rx),
		.rx_data(rx_data),
		.rx_ready(rx_ready_pre)
	);

	always @(posedge clk) begin
		rx_ready_sync <= rx_ready_pre;
		rx_ready <= ~rx_ready_sync & rx_ready_pre;
	end


	uart_baud_tick_gen #(
		.CLK_FREQUENCY(CLK_FREQUENCY),
		.BAUD_RATE(BAUD_RATE),
		.OVERSAMPLING(1)
	) baud_tick_blk (
		.clk(clk),
		.enable(tx_busy_temp),
		.tick(baud_tick)
	);

	uart_tx uart_tx_blk (
		.clk(clk),
		.reset(reset),
		.baud_tick(baud_tick),
		.tx(tx),
		.tx_start(tx_start),
		.tx_data(tx_data),
		.tx_busy(tx_busy_temp)
	);

endmodule
