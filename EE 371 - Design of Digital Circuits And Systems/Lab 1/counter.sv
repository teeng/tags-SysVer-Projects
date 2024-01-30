/*
Lab 1

This module defines a 5-bit counter for counting within a set limit of 0 to 25
depending on whether a car enters or leaves

Inputs:
	clk: 1b input clock to control timing for inputs and outputs
	reset: 1b reset signal to set counter to 0
	inc: 1b input representing that a car has entered and the count should increase
	dec: 1b input representing that a car has exited and the count should decrease
Out: 5b output representing the updated count
*/
module counter (clk, reset, inc, dec, out);
	input logic clk, reset;
	input logic inc, dec;
	output logic [4:0] out;
	
	
	// D Flip Flop implementation (DFFs)
	always_ff @(posedge clk) begin
		// on reset, the counter resets to 0
		if (reset) begin
			out <= 5'b0;
		// if not on reset, counter increases to a limit of 25 for every car that enters
			// and counter decreases to a limit of 0 for every car that exits
		end else begin
			if (inc && out < 25) begin
				out <= out + 5'b1;
			end
			if (dec && out > 0) begin
				out <= out - 5'b1;
			end
		end
	end
endmodule

// Test/Simulate counter module
module counter_testbench();
	// creates corresponding variables to model counter module
	logic clk, reset;
	logic inc, dec;
	logic [4:0] out;
	
	// initializes counter module for testing with name dut
	counter dut (.clk, .reset, .inc, .dec, .out);
	
	// Set up a simulated clock to toggle (from low to high or high to low)
	// every 50 time steps
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;//toggle the clock indefinitely
	end 

	// Set up the inputs to the design
	// Tests responses to cars entering or exiting
	// Expected results are that when inc is HIGH, count increases by 1,
		// and when dec is HIGH, count decreases by 1. Otherwise, maintain the same count
	initial begin
			reset <= 1;			 			  @(posedge clk); // reset to 0
			reset <= 0;	inc <= 0;		  @(posedge clk);
			inc <= 1;		  				  @(posedge clk); // count should be 1
			inc <= 0;		  	 repeat(5) @(posedge clk);
			inc <= 1;		  				  @(posedge clk); // now 2
			inc <= 0;		  	 repeat(5) @(posedge clk);
			dec <= 1;		  				  @(posedge clk); // now 1
			dec <= 0;		  	 repeat(5) @(posedge clk);
			inc <= 1;		  				  @(posedge clk); // now 2
			inc <= 0;		  	 repeat(5) @(posedge clk);
			inc <= 1;		  				  @(posedge clk); // now 3
			inc <= 0;		  	 			  @(posedge clk); 
			inc <= 1;		  				  @(posedge clk); // now 4
			inc <= 0;		  	 			  @(posedge clk);
			inc <= 1;		  				  @(posedge clk); // now 5
			inc <= 0;		  	 			  @(posedge clk);
			inc <= 1;		  				  @(posedge clk); // now 6
			inc <= 0;		  	 			  @(posedge clk);
			
			$stop; // End the simulation
		end
endmodule