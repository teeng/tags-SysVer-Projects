/*
 Lab 2 Task 3
 
 FIFO module which instantiates ram and FIFO control module.
 Links variables/logic between them
 
 Parameters:
	Inputs:
		clk and reset are used to manage the system's state
		read and write are each used to either move in or out
			a word from the RAM resepctively.
		inputBus is dependent on the width parameter, and in
			the event of a write is the data that will be written
	Outputs:
		empty and full are one bit signals which indiate the state
			of the FIFO.
		outputBus is similar to inputBus, except is always showing
			the current word about the be removed from the FIFO. Upon
			a read input, the bus is updated to the next word in 
			the queue
 */
 
module FIFO #(
				  parameter depth = 4,
				  parameter width = 8
				  )(
					 input logic clk, reset,
					 input logic read, write,
					 input logic [width-1:0] inputBus,
					output logic empty, full,
					output logic [width-1:0] outputBus
				   );
					
	/* 	Define_Variables_Here		*/
	logic w_en;
	logic [depth-1:0] readAD;
	logic [depth-1:0] writeAD;
	
	/*			Instantiate_Your_Dual-Port_RAM_Here			*/
	ram16x8 RAM (
	.clock(clk),
	.data(inputBus),
	.rdaddress(readAD),
	.wraddress(writeAD),
	.wren(w_en),
	.q(outputBus));
	
	
	/*			FIFO-Control_Module			*/				
	FIFO_Control #(depth) FC (.clk, .reset, 
									  .read, 
									  .write, 
									  .wr_en(w_en),
									  .empty,
									  .full,
									  .readAddr(readAD), 
									  .writeAddr(writeAD)
									 );
	
endmodule 


// testbench for FIFO module
`timescale 1 ps / 1 ps 
module FIFO_testbench();
	
	parameter depth = 4, width = 8;
	
	logic clk, reset;
	logic read, write;
	logic [width-1:0] inputBus;
	logic resetState;
	logic empty, full;
	logic [width-1:0] outputBus;
	
	FIFO #(depth, width) dut (.*);
	
	// initiate clock
	parameter CLK_Period = 100;
	
	initial begin
		clk <= 1'b0;
		forever #(CLK_Period/2) clk <= ~clk;
	end
	
	//
	initial begin
		reset<=1;					@(posedge clk);
		read<=0; write<=0; inputBus<=7'b0000000;		
										@(posedge clk);
		reset<=0;					@(posedge clk);
										@(posedge clk);
										@(posedge clk);
										@(posedge clk);
		read<=1; write<=0; inputBus<=7'b0000000;		
										@(posedge clk);
		read<=0; write<=0; inputBus<=7'b0000000;		
										@(posedge clk);
		read<=1; write<=0; inputBus<=7'b0000000;		
										@(posedge clk);
		read<=0; write<=0; inputBus<=7'b0000000;		
										@(posedge clk);
		read<=0; write<=1; inputBus<=7'b0000110;		
										@(posedge clk);
		read<=0; write<=0; inputBus<=7'b0000000;		
										@(posedge clk);
		read<=0; write<=1; inputBus<=7'b1000000;		
										@(posedge clk);
		read<=0; write<=0; inputBus<=7'b0000000;		
										@(posedge clk);
		read<=0; write<=1; inputBus<=7'b0100000;		
										@(posedge clk);
		read<=0; write<=0; inputBus<=7'b0000000;		
										@(posedge clk);
		read<=0; write<=1; inputBus<=7'b0011000;		
										@(posedge clk);
		read<=0; write<=0; inputBus<=7'b0000000;		
										@(posedge clk);
		read<=1; write<=0; inputBus<=7'b0000000;		
										@(posedge clk);
		read<=0; write<=0; inputBus<=7'b0000000;		
										@(posedge clk);
		read<=1; write<=0; inputBus<=7'b0000000;		
										@(posedge clk);
		read<=0; write<=0; inputBus<=7'b0000000;		
										@(posedge clk);
		read<=0; write<=1; inputBus<=7'b0000011;		
										@(posedge clk);
		read<=0; write<=0; inputBus<=7'b0000000;		
										@(posedge clk);
		read<=1; write<=0; inputBus<=7'b0000000;		
										@(posedge clk);
		read<=0; write<=0; inputBus<=7'b0000000;		
										@(posedge clk);
										


		$stop; // end simulation
		
	end  // initial

	
endmodule 