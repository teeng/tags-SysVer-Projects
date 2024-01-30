/*
Constructs a D Flip-Flop named D_FF
	q is 1'b output for D_FF with type reg
	d is 1'b input for D_FF
	reset is 1'b control that will set output to 0 if reset is HIGH
	clk is the clock used for controlling input and output timing
	
	Timescale was a necessary addition to the module for running
		given regstim simulation file without errors.
*/

`timescale 1 ps / 1 ps

module D_FF (q, d, reset, clk);
	output reg q; 
	input d, reset, clk; 

	always_ff @(posedge clk) 
	if (reset) 
		q <= 0;  // On reset, set to 0 
	else 
		q <= d; // Otherwise out = d 
endmodule

module D_FF_testbench();
	// creates corresponding variables to model decoderTwoIn module
	logic q; 
	logic d; 
	logic  reset, clk; 
	// when writeEnable is HIGH, q=d, otherwise q is reset.
	
	// initializes decoderTwoIn module for testing with name dut
	D_FF dut (q, d, reset, clk);
	
	// Set up a simulated clock to toggle (from low to high or high to low)
	// every 50 time steps
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;//toggle the clock indefinitely
	end 	

// Simulation sends the state machine into all combinations of inputs first
	integer i;
	initial begin
	
		reset <= 1;					 					@(posedge clk); // Always reset FSMs at start
		reset <= 0;
		
		d <= 1;								repeat(3)@(posedge clk);
		d <= 0;								repeat(3)@(posedge clk);
		d <= 1;								repeat(3)@(posedge clk);
		d <= 0;								repeat(3)@(posedge clk);
		
		$stop; // End the simulation
	end
endmodule 