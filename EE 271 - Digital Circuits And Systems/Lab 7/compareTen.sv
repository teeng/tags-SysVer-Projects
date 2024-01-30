// module compareTen compares two input values, A and B, and outputs
	// whether A is larger than B
	
// clk is the clock used for controlling input and output timing
// A and B are the 10-bit inputs to be compared
// out is whether A is greater than B
module compareTen (clk, A, B, out);
	input logic clk;
	input logic [9:0] A, B;
	output logic out;
	
	always_ff @(posedge clk) begin
		out <= (A > B); // set output to whether A is larger than B
	end
	
endmodule


//Test/Simulate the State Machine
module compareTen_testbench();
	// creates corresponding variables to model inputDejammer module
	logic clk;
	logic [9:0] A, B;
	logic out;
	
	// initializes compareTen module for testing with name dut
	compareTen dut (clk, A, B, out);
	
	// Set up a simulated clock to toggle (from low to high or high to low)
	// every 50 time steps
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;//toggle the clock indefinitely
	end 

// Set up the inputs to the design.  Each line represents a clock cycle 
// Simulation tests whether output shows properly. First tests both inputs being 0,
	// then A > B, A > B still, then A < B. Output should be low only when A < B and
	// high otherwise.
	initial begin
			A <= 0; B <= 0;  				  repeat (2) @(posedge clk);
			A <= 10; B <= 9;	 				 			 @(posedge clk);
			A <= 100; B <= 90;	 			 			 @(posedge clk);
			A <= 5; B <= 9;	 			  repeat (2) @(posedge clk);
		$stop; // End the simulation
	end
endmodule 