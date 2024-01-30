/*
Lab 3 Task 1

Sub-module bitCount that controls when certain bit operations should take place
	and should be performed by other sub-module in DE-1 SoC, datapath

Parameters:
	clk: 1b clock that controls input and output timing
	reset: 1b signal that controls what occurs at system reset
	s: 1b start signal for when algorithm should start
	A: 8b data to count number of bits have value of 1
	enableResult: 1b control signal to update result value
	loadResult: 1b control signal to load result = 0, or resetting
	enableA: 1b control signal to shift A to the next bit to analyze
	done: 1b control signal indicating algorithm is complete
*/
`timescale 1 ps / 1 ps

module bitCount (clk, reset, s, A, enableResult, loadResult,
					  enableA, loadA, done);
	input logic clk, reset, s;
	input logic [7:0] A;
	output logic enableA, loadA, enableResult, loadResult, done;
	
	// state machine setup, with states s1, s2, s3 as seen in the given ASM chart
	enum logic [1:0] {s1, s2, s3} ps, ns;
	
	// defining state transitions
	always_comb begin
		case (ps)
		// s1 is in the initial state, and stays unless s is HIGH
		s1: if (s) 		ns = s2;
			 else			ns = s1;
		// s2 is the next state, and stays unless A = 0
		s2: if (!A) 	ns = s3;
			 else			ns = s2;
		// s3 is the final state of the algorithm, and stays unless if start
			// goes low, then the next state will be back to s1
		s3: if (s)		ns = s3;
			 else			ns = s1;
		default: 		ns = s1;
		endcase
	end
	
	// output control signals are mainly controlled by present state and
		// sometimes by additional logic of input signals from the datapath
	assign enableA = (ps == s2);
	assign loadA = (ps == s1) && (s == 1'b0);
	assign enableResult = (ps == s2) && A && (A[0] == 1'b1);
	assign loadResult = (ps == s1);
	assign done = (ps == s3);
	
	// if reset, go to s1, otherwise, go to the next state designated above
	always_ff @(posedge clk) begin
		if (reset) 	ps <= s1;
		else 			ps <= ns;
	end
	
endmodule

// Test/Simulate bitCount functionality
module bitCount_testbench();
	// creates corresponding variables to model bitCount module
	logic clk, reset, s;
	logic [7:0] A;
	logic enableA, loadA, enableResult, loadResult, done;
	
	// initializes bitCount module for testing with name dut
	bitCount dut (.clk, .reset, .s, .A, .enableResult, .loadResult,
					  .enableA, .loadA, .done);
	
	// set up simulated clock
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		// Forever toggle the clock
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end 
	
	initial begin
		reset <= 1'b1; 		 @(posedge clk);
		reset<= 1'b0;
		
		// response to when data A = 8'b10 should be that
		// loadResult goes high to set result to 0
		s <= 1'b0;
		A <= 8'b01; repeat(2) @(posedge clk);
		
		// after s (start) goes high, loadA goes high, and after
		// transitioning to s2, enableA is high to shift A to the right
		// and enableResult is updated if there was a 1 at the LSB.
		s <= 1'b1;	repeat(5) @(posedge clk);
		A <= 8'b0;	repeat(5) @(posedge clk);
		s <= 1'b0;	repeat(3) @(posedge clk);
		
	$stop; // End the simulation.
	end
endmodule 