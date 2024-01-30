/*
Constructs a 64'b register named D_FF64, storing 64'b of given data in a register,
	and returning its 64'b data when called
	q is the 64'b output with type logic
	d is the 64'b input with type of logic
	reset sets output to 0
	clk is the clock used for controlling input and output timing

	Timescale was a necessary addition to the module for running
		given regstim simulation file without errors.
*/

`timescale 1 ps / 1 ps

module D_FF64 (q, d, reset, clk); 
	output logic  [63:0] q; 
	input  logic  [63:0] d; 
	input  logic  reset, clk;
	
		
	// internal 64'b temp variable ensures that writing to the register has
		// finished before the output is sent
	logic [63:0] temp;
	
	// generates 64 registers to store each bit of the 64'b from given input d.
		// and outputs to a corresponding bit in output q.
	// each flip flop's input is from a mux2_1 temporary temp bit that
		// acts as an enable for the entire 64'b register
	// each flip flop is also connected to the same clock
	genvar i;
	generate
		for(i=0; i<64; i++) begin : eachFF
			D_FF oneFF (.q(q[i]),  .d(d[i]), .reset(reset), .clk(clk));
		end
	endgenerate
endmodule


module D_FF64_testbench();
	// creates corresponding variables to model decoderTwoIn module
	logic  [63:0] q; 
	logic  [63:0] d; 
	logic  reset, clk; 
	// when reset is HIGH, q=0, otherwise q is d.
	
	// initializes decoderTwoIn module for testing with name dut
	D_FF64 dut (q, d, reset, clk);
	
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
		
		for(i=0; i<10; i++) begin  
			d <= i; 					 			  repeat(2) @(posedge clk);
		end
		
		
		reset <= 1; 					  repeat(2) @(posedge clk); // reset
		reset <= 0;
		d <= 1; 									  repeat(2) @(posedge clk);
		
		reset <= 1;
		d <= 4; 									  repeat(2) @(posedge clk);
		
		reset <= 0;
		d <= 3; 									  repeat(2) @(posedge clk);
		
		$stop; // End the simulation
	end
endmodule 
