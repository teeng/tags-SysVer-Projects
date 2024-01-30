/*
 Lab 4 Task 2
 
 Top level module which communicates with DE1_SoC board to manage 
 perihperals and connect them with submodules.  Also contains some 
 internal sequential logic to assist in controlling HEX displays.

 Parameters:
	CLOCK_50: 1b 50Mhz clock that controls timing on the DE-1 SoC board
	LEDR: 10 total LEDRs on the DE-1 SoC board each represented by one bit, so LEDR is a
		10b bus of which LEDR are HIGH or LOW
	HEX0 through HEX5: Six total HEX displays on the DE-1 SoC board that each contain
		seven LEDR segments (so size 7b each), which can be individually set HIGH or LOW.
		Segments are active LOW.
	SW: Ten total switches on the DE-1 SoC board each represented by one bit, so SW is a
		10b bus of which switches are HIGH or LOW.
	KEY: Four total pushbuttons on the DE-1 SoC board each represented by one bit, so KEY is a 
		4b bus of which buttons are being pressed. KEY is active LOW.
		
 This module implements the binary search algorithm using control logic, datapath logic, and
 a 32x8 RAM array.  We use KEY0 as a reset, and SW9 as the start signal.  SW7-0 are used to
 input what data we want to search for in the array, and when we are ready, we toggle SW9 to 
 begin the algorithm.  Then if the data is found, the address will be displayed in hexidecimal
 on HEX1 and HEX0, as well as LEDR9 lighting up to signal a found value.  If the value is not
 found, no HEX will light up, and LEDR8 will light up signaling a failed search.
			
 */
 
`timescale 1 ps / 1 ps
module DE1_SoC (CLOCK_50, SW, KEY, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR);
 
	// declare i/o
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input  logic [3:0] KEY;  
	input  logic [9:0] SW;
	input  logic CLOCK_50;
	
	// internal logic
	logic [7:0] data_input, data_from_array;
	logic [5:0] size;
	logic load_data, data_big, data_small, found_ctrl, notFound_ctrl, check_zero;
	logic found, notFound;
	logic [4:0] curr_addr;
	logic [6:0] hex0;
	
	/* SUBMODULE INSTANTIATIONS */
	// control logic
	binary_search_control controlMod 
		(.clk(CLOCK_50), .reset(~KEY[0]), .start(SW[9]), .data_i(data_input), .data_o(data_from_array), .size,
		.load_data, .data_big, .data_small, .found_ctrl, 
		.notFound_ctrl, .check_zero);
	// datapath logic
	binary_search_datapath datapathMod
		(.clk(CLOCK_50), .reset(~KEY[0]), .data_i(SW[7:0]), .load_data, .data_big, 
		.data_small, .found_ctrl, .notFound_ctrl, .check_zero, 
		.found, .notFound, .address_o(curr_addr), .data_ans(data_input), .size);
	// array 32x8
	ram32x8 arrayMod
		(.address(curr_addr), .clock(CLOCK_50), .data(8'b00000000), .wren(1'b0), .q(data_from_array));
	
	// convert address output to HEX display
	seg7 LSB (.reset(~KEY[0]), .count(curr_addr[3:0]), .setDefault(7'b1111111), .leds(hex0));
	
	// output display logic
	always_comb begin
		HEX2 = 7'b1111111;
		HEX3 = 7'b1111111;
		HEX4 = 7'b1111111;
		HEX5 = 7'b1111111;
		LEDR[7:0] = 8'b00000000;
		if (found) begin	// led9 showing found and hex1 and 0 on
			LEDR[8] = 1'b0;
			LEDR[9] = 1'b1;
			HEX0	  = hex0;								// based on seg7
			if (curr_addr[4])	HEX1 = ~7'b0000110;  // 1
			else					HEX1 = ~7'b0111111;  // 0
		end
		else if (notFound) begin // just led8 on showing not found
			LEDR[8] = 1'b1;
			LEDR[9] = 1'b0;
			HEX0	  = 7'b1111111;
			HEX1	  = 7'b1111111;
		end 
		else begin		// all lights off
			LEDR[8] = 1'b0;
			LEDR[9] = 1'b0;
			HEX0	  = 7'b1111111;
			HEX1	  = 7'b1111111;
		end
	end

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
		// reset
		KEY[0] <= ~1'b1; 							repeat(2) 	@(posedge clk);
		KEY[0] <= ~1'b0; SW[9] <= 1'b0;		repeat(2) 	@(posedge clk);
		
		// test finding 15 expect address 4
		SW[7:0] <= 8'b00001111;					repeat(2) 	@(posedge clk);
		SW[9] <= 1'b1;								repeat(30) 	@(posedge clk);
		SW[9] <= 1'b0;								repeat(15) 	@(posedge clk);
		
		// test finding 220 expect address 30
		SW[7:0] <= 8'b11011100;					repeat(2) 	@(posedge clk);
		SW[9] <= 1'b1;								repeat(30) 	@(posedge clk);
		SW[9] <= 1'b0;								repeat(15) 	@(posedge clk);
		
		// test finding 221 expect notFound
		SW[7:0] <= 8'b11011101;					repeat(2) 	@(posedge clk);
		SW[9] <= 1'b1;								repeat(30) 	@(posedge clk);
		SW[9] <= 1'b0;								repeat(15) 	@(posedge clk);
		
		// test finding 0 expect address 0
		SW[7:0] <= 8'b00000000;					repeat(2) 	@(posedge clk);
		SW[9] <= 1'b1;								repeat(30) 	@(posedge clk);
		SW[9] <= 1'b0;								repeat(15) 	@(posedge clk);

		$stop; // end simulation
		
	end  // initial


endmodule
