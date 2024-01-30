/*
Lab 3 Task 1

Top-level module DE1_SoC that defines the I/Os for the DE-1 SoC board

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
		
This module overall counts the number of bits that have a value of 1
in a given data input set by SW7 through 0. Once desired data is set, setting SW9 to HIGH
will initiate the algorithm. Algorithm is complete when LEDR9 is on and count is displayed
on HEX0 on the DE-1 SoC board. SW9 can then be set to LOW to enter new data.
*/

`timescale 1 ps / 1 ps

module DE1_SoC (CLOCK_50, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, SW, KEY);
	input logic CLOCK_50;
	input  logic [9:0] SW;
	input  logic [3:0] KEY;
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	
	// Setting HEX1 through HEX5 off
	assign HEX5 = '1;
	assign HEX4 = '1;
	assign HEX3 = '1;
	assign HEX2 = '1;
	assign HEX1 = '1;
	
	// reset controlled by pressing KEY0
	logic reset;
	assign reset = ~KEY[0];
	
	// syncing and avoiding metastability of SW[9] input by delaying
		// two clock cycles. Output is s (start)
	logic sTemp, s;
	always_ff @(posedge CLOCK_50) begin
		if (reset) s <= 1'b0;
		else begin
			sTemp <= SW[9];
			s <= sTemp;
		end
	end
	
	// internal variable A is the input data loaded in
	// internal variable result is the number of bits in A that have value of 1
	logic [7:0] A;
	logic [3:0] result;
	// internal control signals
	logic enableResult, loadResult, enableA, loadA, done;
	
	// module bitCount is main controller for the algorithm, determining when and what
		// operations should occur depending on inputs received from the datapath module below
	// Inputs:
		// clk: 1b to control input and output timing
		// reset: 1b to control what occurs at system reset
		// s: 1b signal to start the algorithm
	// Outputs:
		// A: 8b input data to count the number of bits with value of 1
		// enableResult: 1b control signal to update result value
		// loadResult: 1b control signal to load result = 0, or resetting
		// enableA: 1b control signal to shift A to the next bit to analyze
		// done: 1b control signal indicating algorithm is complete
	bitCount controller (.clk(CLOCK_50), .reset(reset), .s(s), .A(A),
								.enableResult(enableResult), .loadResult(loadResult),
								.enableA(enableA), .loadA(loadA), .done(done));
	
	// datapath module computes bit operations in response to control signals by bitCount
	// Inputs:
		// clk: 1b to control input and output timing
		// reset: 1b to control what occurs at system reset
		// data: 8b data input to count number of bits equal to 1 in
		// enableA: 1b signal to move to next bit of A
		// loadA: 1b signal to replace A with whatever is in data
		// enableResult: 1b signal to increase result by 1
		// loadResult: 1b signal to reset result to 0
	// Outputs:
		// A: 8b input data to count the number of bits with value of 1
		// result: 4b count of how many bits in A have value of 1 so far
	datapath d (.clk(CLOCK_50), .reset(reset), .data(SW[7:0]), .enableA(enableA),
					.loadA(loadA), .enableResult(enableResult), .loadResult(loadResult),
					.A(A), .result(result));
	
	// seg7 displays the value of result to HEX0 of the DE-1 SoC board
	// Inputs:
		// reset: 1b to control what occurs at system reset
		// count: 4b number to display
		// setDefault: 7b value for setting output leds
			// if no other conditions satisfied (here, turn all leds off)
	// Output:
		// leds: 7b for which segments are on or off of the given hex, segments are active LOW
	seg7 hex0 (.reset(reset), .count(result), .setDefault('1), .leds(HEX0));
	// LEDR9 turns on if the algorithm is complete
	assign LEDR[9] = done;
	
endmodule


// Testbench for DE1_SoC module to verify outputs
module DE1_SoC_testbench();
	// creates corresponding variables to model DE1_SoC module
	logic CLOCK_50;
	logic [9:0] SW;
	logic [3:0] KEY;
	logic [9:0] LEDR;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	

	// initializes DE1_SoC module for testing with name dut
	DE1_SoC dut (.CLOCK_50, .LEDR, .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .SW, .KEY);
	
	// Set up clock for simulation
	parameter CLOCK_PERIOD=100;
	initial begin
		CLOCK_50 <= 0;
		// Forever toggle the clock
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
	end 
	
	
	initial begin
		// reset
		KEY[0] <= ~1'b1; 										 @(posedge CLOCK_50);
		KEY[0] <= ~1'b0; SW[9] <= 1'b0;		repeat(2) @(posedge CLOCK_50);
		
		// set data as below, expected result = 4, which should
			// be represented on HEX0, and LEDR9 should turn on
		SW[7:0] <= 8'b11001010;					repeat(2) @(posedge CLOCK_50);
		SW[9] <= 1'b1;								repeat(15) @(posedge CLOCK_50);
		SW[9] <= 1'b0;								repeat(15) @(posedge CLOCK_50);
		
		// set data as below, expected result = 5, which should be
			// represented on HEX0, and LEDR9 should turn on
		SW[7:0] <= 8'b10011101;					repeat(2) @(posedge CLOCK_50);
		SW[9] <= 1'b1;								repeat(15) @(posedge CLOCK_50);
		SW[9] <= 1'b0;								repeat(15) @(posedge CLOCK_50);
	
	$stop;
	end
endmodule