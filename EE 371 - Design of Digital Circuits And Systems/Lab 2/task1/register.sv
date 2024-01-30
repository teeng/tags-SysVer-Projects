/*
Lab 2 Task 1

Constructs a variable WIDTH register, storing the given data until reset
	clk is the 1b clock used for controlling input and output timing
	reset is the 1b control signal which will set output to 0 if HIGH
	writeEnable is a control for the register and enables storing
	d is the WIDTH size input to store
	q is the WIDTH size output that should match d if writeEnable is HIGH and
		reset is LOW
*/

`timescale 1 ps / 1 ps

module  register #(parameter WIDTH=4) (clk, reset, writeEnable, d, q); 
	output logic  [WIDTH-1:0] q; 
	input  logic  [WIDTH-1:0] d; 
	input  logic  writeEnable, clk, reset;
	
	// output is synchronous and controlled by a clock
	always_ff @(posedge clk) begin
		if (reset) begin
			q <= '0; // set output to 0 regardless
		end else if (writeEnable) begin
			q <= d; // set output equal to d if write is enabled
		end
	
	end
endmodule


module register_testbench();
	// creates corresponding variables to model register module
	logic  [3:0] q; 
	logic  [3:0] d; 
	logic  writeEnable, clk, reset; 
	
	// initializes register module for testing with name dut
	register dut (.clk, .reset, .writeEnable, .d, .q);
	
	// Set up a simulated clock to toggle (from low to high or high to low)
	// every 50 time steps
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;//toggle the clock indefinitely
	end 	

	// when writeEnable is HIGH, q=d, otherwise q is reset.
	integer i;
	initial begin
		reset <= 1;												@(posedge clk);
		reset <= 0; writeEnable <= 0;					 	@(posedge clk);
		
		// d goes from 0 to 10 with writeEnable HIGH, so
		// q should also go from 0 to 10, with a delay of one clock cycle
		writeEnable <= 1;
		for(i=0; i<10; i++) begin  
			d <= i; 					 			  repeat(2) @(posedge clk);
		end
		
		// q should not change value
		writeEnable <= 0; 					  repeat(2) @(posedge clk);
		
		// d is set to 1 with writeEnable high, q should be set to 1 after one clock cycle
		writeEnable <= 1; d <= 1;			  repeat(2) @(posedge clk);
		// writeEnable LOW, q should not change
		writeEnable <= 0; d <= 4; 			  repeat(2) @(posedge clk);
		// writeEnable HIGH< q should be set to 3 after one clock cycle
		writeEnable <= 1; d <= 3;			  repeat(2) @(posedge clk);
		
		$stop; // End the simulation
	end
endmodule 
