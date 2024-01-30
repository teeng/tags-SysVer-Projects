/*
 Lab 2 Task 3
 
 Top level module which communicates with DE1_SoC board to manage 
 perihperals and connect them with submodules.  Also contains some 
 internal sequential logic to assist in controlling HEX displays.

 Parameters:
	Inputs:
		CLOCK_50 is internal clock of DE1_SoC board at 50Mhz
		SW is ten different hi/lo switches on DE1_SoC, are used for
			data input
		KEY is 4 different push buttons one of which is used as write,
			read, and reset input
	Outputs:
		HEX0-5 are six separate 7 segment hex displays which we use to
			display data in, out
		LEDR are ten separate LEDs, we use LED9 to refer to full, and LED8
			to refer to empty.
			
 This module uses a two input 16x8 ram to read and write 8 bit words.
 It also uses submodules implementing a FIFO buffer.  This buffer uses
 the size of the given RAM as its word size.  This eliminates the use of
 addresses for the user and acts as a queue, reading words in the order
 they came in through the write.  This also means the FIFO can be full
 or empty, and this state is displayed on the LEDRs.
 */
 
 
module DE1_SoC (CLOCK_50, SW, KEY, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR);
 
	// declare i/o
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input  logic [3:0] KEY;  
	input  logic [9:0] SW;
	input  logic CLOCK_50;
	
	// raw internal signals
	logic [7:0] data_out;
	logic readControl, writeControl;
	
	// instantiate FIFO
	FIFO fifo1 (
					 .clk(CLOCK_50), .reset(~KEY[0]),
					 .read(readControl), .write(writeControl),
					 .inputBus(SW[7:0]),
					 .empty(LEDR[8]), .full(LEDR[9]),
					 .outputBus(data_out)
				   );
					
	// convert raw data to 7 segment display
	seg7 dataOUT1 (.in(data_out[7:4]), .leds(HEX1));
	seg7 dataOUT0 (.in(data_out[3:0]), .leds(HEX0));
	
	seg7 dataIN1 (.in(SW[7:4]), .leds(HEX5));
	seg7 dataIN0 (.in(SW[3:0]), .leds(HEX4));
	
	// clear unused HEX
	assign HEX2 = '1;
	assign HEX3 = '1;
	
	// ensure user input is only true on read/write for one clock cycle
	user_input read1  (.clk(CLOCK_50), .reset(~KEY[0]), .in(~KEY[1]), .out(readControl));
	user_input write1 (.clk(CLOCK_50), .reset(~KEY[0]), .in(~KEY[2]), .out(writeControl));
	
endmodule



// tesetbench for task 3 overall 
`timescale 1 ps / 1 ps 
module DE1_SoC_testbench ();

	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [3:0] KEY;  
	logic [9:0] SW, LEDR;
	
	logic clk;
	
	// clock setup
	parameter clock_period = 100;
	
	initial begin
		clk <= 0;
		forever #(clock_period /2) clk <= ~clk;
	end
	
	DE1_SoC dut (.CLOCK_50(clk), .SW, .KEY, .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .LEDR);
	
	
	initial begin
													@(posedge clk);
		KEY<=4'b1111;
		SW<=10'b0000000000;	KEY[0]<=0;	@(posedge clk);
													@(posedge clk);
									KEY[0]<=1;	@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
		KEY[1]<=0; KEY[2]<=1; SW[7:0]<=7'b0000000;		
										@(posedge clk);
		KEY[1]<=1; KEY[2]<=1; SW[7:0]<=7'b0000000;		
										@(posedge clk);
		KEY[1]<=0; KEY[2]<=1; SW[7:0]<=7'b0000000;		
										@(posedge clk);
		KEY[1]<=1; KEY[2]<=1; SW[7:0]<=7'b0000000;		
										@(posedge clk);
		KEY[1]<=1; KEY[2]<=0; SW[7:0]<=7'b0000110;		
										@(posedge clk);
		KEY[1]<=1; KEY[2]<=1; SW[7:0]<=7'b0000000;		
										@(posedge clk);
		KEY[1]<=1; KEY[2]<=0; SW[7:0]<=7'b1000000;		
										@(posedge clk);
		KEY[1]<=1; KEY[2]<=1; SW[7:0]<=7'b0000000;		
										@(posedge clk);
		KEY[1]<=1; KEY[2]<=0; SW[7:0]<=7'b0100000;		
										@(posedge clk);
		KEY[1]<=1; KEY[2]<=1; SW[7:0]<=7'b0000000;		
										@(posedge clk);
		KEY[1]<=1; KEY[2]<=0; SW[7:0]<=7'b0011000;		
										@(posedge clk);
		KEY[1]<=1; KEY[2]<=1; SW[7:0]<=7'b0000000;		
										@(posedge clk);
		KEY[1]<=0; KEY[2]<=1; SW[7:0]<=7'b0000000;		
										@(posedge clk);
		KEY[1]<=1; KEY[2]<=1; SW[7:0]<=7'b0000000;		
										@(posedge clk);
		KEY[1]<=0; KEY[2]<=1; SW[7:0]<=7'b0000000;		
										@(posedge clk);
		KEY[1]<=1; KEY[2]<=1; SW[7:0]<=7'b0000000;		
										@(posedge clk);
		KEY[1]<=1; KEY[2]<=0; SW[7:0]<=7'b0000011;		
										@(posedge clk);
		KEY[1]<=1; KEY[2]<=1; SW[7:0]<=7'b0000000;		
										@(posedge clk);
		KEY[1]<=0; KEY[2]<=1; SW[7:0]<=7'b0000000;		
										@(posedge clk);
		KEY[1]<=1; KEY[2]<=1; SW[7:0]<=7'b0000000;		
										@(posedge clk);
		
										
		$stop; // end simulation
		
	end  // initial


endmodule
