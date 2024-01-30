// module LFSRTen generates random outputs, which will be used
	// for calculating when the computer in the Tug-o-war game
	// will simulate a button press

// clk is the clock used for controlling input and output timing
// reset makes the output set to 0
// out is the random number generated
module LFSRTen (clk, reset, out);
	input logic clk, reset;
	output logic [9:0] out;
	
	// following the implementation of a 10-bit LFSR,
		// the MSB of the random number is the XNOR of the 0th and 3rd bits
		// from the previous random state (left to right order of bits)
	logic q1;
	xnor (q1, out[0], out[3]);
	
	// D Flip Flop implementation (DFFs)
	// Generates the next random number by concatenating the XNOR
		// as the new MSB while shifting the previous output one bit to the right
	always_ff @(posedge clk) begin
		// on reset, any button presses are counted as misses
		if (reset)
			out <= 10'b0;
		else
			// otherwise, attach the XNOR (as the MSB) to the previous state
				// of the flip flops
			out <= {q1, out[9:1]};
	end
	
endmodule


//Test/Simulate the State Machine
module LFSRTen_testbench();
	// creates corresponding variables to model inputDejammer module
	logic clk, reset;
	logic [9:0] out;
	
	// initializes inputDejammer module for testing with name dut
	LFSRTen dut (clk, reset, out);
	
	// Set up a simulated clock to toggle (from low to high or high to low)
	// every 50 time steps
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;//toggle the clock indefinitely
	end 

// Set up the inputs to the design.  Each line represents a clock cycle 
// Simulation sends the state machine into the first 20 possible states,
	// which will be 20 "randomly" generated numbers, following the implementation
	// of a 10-bit LFSR.
	initial begin
			reset <= 1;			 			  @(posedge clk); // Always reset FSMs at start
			reset <= 0;						  @(posedge clk);
								  repeat (20) @(posedge clk);
			$stop; // End the simulation
		end
endmodule