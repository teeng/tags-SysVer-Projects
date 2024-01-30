// inputDejammer ensures that user input from either player
	// is output only after two flip flops to ensure stability.
	// This ensures stable outputs without having completely random input combinations.
	
// clk is the clock used for controlling input and output timing
// playerIn is whether a player has pressed the button on the clock edge
// tug is the output the button press to be counted.
module inputDejammer (clk, playerIn, tug);
	input logic clk;
	input logic playerIn;
	output logic tug;
	
	// internal wire d1 is used to connect the output of one flip flop to the next
	logic d1;
		
	// D Flip Flop implementation (DFFs) The first flip flop.
	always_ff @(posedge clk) begin
		d1 <= playerIn;
	end
	
	// D Flip Flop implementation (DFFs) The second flip flop sends to output tug
	always_ff @(posedge clk) begin
		tug <= d1;
	end
	
	
endmodule


//Test/Simulate the State Machine
module inputDejammer_testbench();
	// creates corresponding variables to model inputDejammer module
	logic clk;
	logic playerIn;
	logic tug;
	
	// initializes inputDejammer module for testing with name dut
	inputDejammer dut (clk, playerIn, tug);
	
	// Set up a simulated clock to toggle (from low to high or high to low)
	// every 50 time steps
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;//toggle the clock indefinitely
	end 

// Set up the inputs to the design.  Each line represents a clock cycle 
// Simulation shows results for button presses as inputs, expected results
	// are that the inputs are the same as outputs, with a two-clock cycle delay.
	integer i;   
	initial begin
			playerIn <= 0;		 				 repeat(2) @(posedge clk);
			playerIn <= 1;		 				 repeat(2) @(posedge clk);
			playerIn <= 0;						 repeat(2) @(posedge clk); 
			playerIn <= 1;						repeat(10) @(posedge clk); 
		$stop; // End the simulation
	end
endmodule 