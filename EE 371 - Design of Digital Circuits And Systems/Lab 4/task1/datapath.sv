/*
Lab 3 Task 1

Sub-module datapath that performs bit operations depending on
	control signals sent by bitCount

Parameters:
	clk: 1b clock that controls input and output timing
	reset: 1b signal that controls what occurs at system reset
	data: 8b raw data to count number of bits have value of 1
	enableA: 1b signal to move to next bit of A
	loadA: 1b signal to replace A with whatever is in data
	enableResult: 1b signal to increase result by 1
	loadResult: 1b signal to reset result to 0
	A: 8b input data to count the number of bits with value of 1
	result: 4b count of how many bits in A have value of 1 so far
*/
`timescale 1 ps / 1 ps

module datapath (clk, reset, data, enableA, loadA, enableResult,
					  loadResult, A, result);
	input logic clk, reset, enableA, loadA, enableResult, loadResult;
	input logic [7:0] data;
	output logic [7:0] A;
	output logic [3:0] result;
	
	// at reset, set result to 0,
	// if loadResult is recieved, set result to 0,
		// or if enableResult is HIGH, update result by 1
	// if loadA is recieved, set A with the data input
		// or if enableA is HIGH, bitwise shift A to the right
	always_ff @(posedge clk) begin
		if (reset) 						result <= 0;
		else begin
			if (loadResult)			result <= 0;
			else if (enableResult) 	result <= result + 1'b1;
			
			if (loadA)					A <= data;
			else if (enableA)			A <= A >> 1;
		end
	end	
endmodule


// Test/Simulate datapath functionality
module datapath_testbench();
	// creates corresponding variables to model datapath module
	logic clk, reset, enableA, loadA, enableResult, loadResult;
	logic [7:0] data;
	logic [7:0] A;
	logic [3:0] result;
	
	// initializes datapath module for testing with name dut
	datapath dut (.clk, .reset, .data, .enableA, .loadA, .enableResult,
					  .loadResult, .A, .result);
	
	// set up simulated clock
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		// Forever toggle the clock
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end 
	
	initial begin
		reset <= 1'b1; @(posedge clk); // reset
		reset<= 1'b0;
		
		// upon start, no control signals received from bitCount
		{enableA, loadA, enableResult, loadResult} = 4'b0;		repeat(2) @(posedge clk);
		// first control signal to receive from bitCount would be to loadResult,
			// expect result = 0;
		{enableA, loadA, enableResult, loadResult} = 4'b0001; repeat(2) @(posedge clk);
		data <= 8'b10010101;															 @(posedge clk);
		
		// expected data is loaded into A and result = 0, with both loadA and loadResult HIGH
		{enableA, loadA, enableResult, loadResult} = 4'b0101; repeat(2) @(posedge clk);
		// expect A to bitwise shift to right, following s2 state actions from bitCount
		{enableA, loadA, enableResult, loadResult} = 4'b1000; 			 @(posedge clk);
		// expect enableResult to update by 1, regardless if there is a 1 in LSB
			// (checking for this is controlled by bitCount)
		{enableA, loadA, enableResult, loadResult} = 4'b0010; 			 @(posedge clk);
		
		// expect A to bitwise shift to right, following s2 state actions from bitCount
		{enableA, loadA, enableResult, loadResult} = 4'b1000; 			 @(posedge clk);
		// expect enableResult to update by 1, regardless if there is a 1 in LSB
			// (checking for this is controlled by bitCount)
		{enableA, loadA, enableResult, loadResult} = 4'b0010; 			 @(posedge clk);
		
		// expect A to bitwise shift to right, following s2 state actions from bitCount
		{enableA, loadA, enableResult, loadResult} = 4'b1000; 			 @(posedge clk);
		
		// expect enableResult to update by 1, regardless if there is a 1 in LSB
			// (checking for this is controlled by bitCount)
		{enableA, loadA, enableResult, loadResult} = 4'b0010; 			 @(posedge clk);
		{enableA, loadA, enableResult, loadResult} = 4'b0;		repeat(5) @(posedge clk);
		
	$stop; // End the simulation.
	end
endmodule 