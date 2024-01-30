/*
 Lab 2 Task 2
 
 Top level module which communicates with DE1_SoC board to manage 
 perihperals and connect them with submodules.  Also contains some 
 internal sequential logic to assist in controlling HEX displays.

 Parameters:
	Inputs:
		CLOCK_50 is internal clock of DE1_SoC board at 50Mhz
		SW is ten different hi/lo switches on DE1_SoC, are used for
			data and address input
		KEY is 4 different push buttons one of which is used as write
			enable and another is used as reset
	Outputs:
		HEX0-5 are six separate 7 segment hex displays which we use to
			display data in, out and write and read addresses
			
 This module uses a two input 32x4 ram to read and write 4 bit words.
 It can display words and addresses in hexidecimal.  It continually
 reads data to output, so reads each word for about 1 second continually
 */
 
 
 module DE1_SoC (CLOCK_50, SW, KEY, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
 
	// declare i/o
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	input  logic [3:0] KEY;  
	input  logic [9:0] SW;
	input  logic CLOCK_50;
	
	// internal logic for output data before 7 segment
	logic [3:0] raw_output;
	logic [4:0] read_address;
	logic [25:0] clock_count;
	
	// instantiate ram block
	ram32x4 RAM (.clock(CLOCK_50), .data(SW[3:0]), .rdaddress(read_address), 
		.wraddress(SW[8:4]), .wren(~KEY[3]), .q(raw_output));
	
	// counter for read address
	// increases read_address about once per second based on 50Mhz clk
	always_ff @(posedge CLOCK_50) begin
		if (~KEY[0]) begin //reset
			read_address <= 5'b00000;
			clock_count <= 26'b00000000000000000000000000;
		end
		else begin
			//if (clock_count<((50)*(2**20)))   // for DE1_SoC
			if (clock_count<(2))  // for testing 
				clock_count <= clock_count + 1;
			else begin
				clock_count <= 26'b00000000000000000000000000;
				if (read_address==5'b11111)
					read_address <= 5'b00000;
				else
					read_address <= read_address + 1;
			end
		end
	end
	
	// connect raw data/address to 7 segment
	seg7 dataOUT (.in(raw_output), .leds(HEX0));
	seg7 dataIN (.in(SW[3:0]), .leds(HEX1));
	
	// convert address to seg 7
	seg7 Waddress (.in(SW[7:4]), .leds(HEX4));
	seg7 Raddress (.in(read_address[3:0]), .leds(HEX2));
	always_comb begin
		if (SW[8])  // Waddress>0F
			HEX5 = 7'b1111001;	// 1
		else			// Waddress<10
			HEX5 = 7'b1000000;	// 0
			
		if (read_address[4])  // Raddress>0F
			HEX3 = 7'b1111001;	// 1
		else			// Raddress<10
			HEX3 = 7'b1000000;	// 0
	end
	
endmodule


// testbench for task 2 overall
`timescale 1 ps / 1 ps 
module DE1_SoC_testbench ();

	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [3:0] KEY;  
	logic [9:0] SW;
	
	logic clk;
	
	// clock setup
	parameter clock_period = 100;
	
	initial begin
		clk <= 0;
		forever #(clock_period /2) clk <= ~clk;
	end
	
	DE1_SoC dut (.CLOCK_50(clk), .SW, .KEY, .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5);
	
	
	initial begin
													@(posedge clk);
		KEY<=4'b1111;
		SW<=10'b0000000000;	KEY[0]<=0;	@(posedge clk);
													@(posedge clk);
									KEY[0]<=1;	@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
		SW[8:4]<=5'b00110; SW[3:0]<=4'b1010;
		KEY[3]<=0;
													@(posedge clk);
		KEY[3]<=1;								@(posedge clk);
													@(posedge clk);
													@(posedge clk);
		SW[8:4]<=5'b10110; SW[3:0]<=4'b0110;
		KEY[3]<=0;
													@(posedge clk);
		KEY[3]<=1;								@(posedge clk);
													@(posedge clk);
													@(posedge clk);
		SW[8:4]<=5'b00010; SW[3:0]<=4'b0011;
		KEY[3]<=0;
													@(posedge clk);
		KEY[3]<=1;								@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
													@(posedge clk);
		
										
		$stop; // end simulation
		
	end  // initial

endmodule
