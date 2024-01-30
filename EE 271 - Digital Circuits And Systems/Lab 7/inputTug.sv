// inputTug takes in the input from a player and checks whether their button press
	// was on a clock edge and ensure that
	// holding the button down only counts as one button press

// clk is the clock used for controlling input and output timing
// reset makes any button presses count as misses during the time reset is active
// key is the respective key for each player
// tug is the output of whether the button press is counted or not.
module inputTug (clk, reset, key, tug);
	input logic clk;
	input logic reset;
	input logic key;
	output logic tug;
	
	// internal logic out is whether or not the button counts as a press or not,
		// which is later sent to inputDejammer, which will ensure overall input stability.
	logic out;
	// specifies various states of the button press. A miss is when the button
		// was not pressed on a clockedge. A hit is when the button was pressed on a 
		// clockedge. And a cheat is when the button is held for too long over multiple
		// clock edges (the button was held down).
	enum logic [1:0] {miss=2'b00, hit=2'b01, cheat=2'b10} ps, ns; 
	// This logic describes all the possible state transitions from ps to ns
	always_comb begin
		// out is determined by the LSB of the possible states,
			// therefore, if it is a miss, then out is LOW
			// if it is a hit, then out is HIGH
			// if it is a cheat, then out is LOW
		out = ps[0];
		case (ps)				
			miss: if (!key)							ns = miss;
					 else									ns = hit;
					
			hit: if (!key)								ns = miss;
					 else 	 							ns = cheat;
				  
		   cheat: if (!key)							ns = miss;
					 else									ns = cheat;
		endcase
	end

	
	// D Flip Flop implementation (DFFs)
	always_ff @(posedge clk) begin
		if (reset)
			ps <= miss; // any button presses during reset count as misses
		else
			ps <= ns; // otherwise, advances to next state in state diagram
	end
	
	// instantiates an inputDejammer, which sends previously defined "out" to two additional
		// flip flops to ensure stability. The final result is sent to tug as output.
	inputDejammer metaPlayer (.clk(clk), .playerIn(out), .tug(tug));
	
	
endmodule


//Test/Simulate the State Machine
module inputTug_testbench();
	// creates corresponding variables to model inputDejammer module
	logic clk, reset;
	logic key;
	// when tug is true, the playfield light should shift
	logic tug;
	
	// initializes inputDejammer module for testing with name dut
	inputTug dut (clk, reset, key, tug);
	
	// Set up a simulated clock to toggle (from low to high or high to low)
	// every 50 time steps
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;//toggle the clock indefinitely
	end 

// Set up the inputs to the design.  Each line represents a clock cycle 
// Simulation sends the state machine into possible states of button presses,
	// including single button presses, misses, or holding down the key.
	// Expected results are that whenever a button is pressed, even when holding down,
	// it only ever counts as one button press.
	initial begin
			reset <= 1;										 @(posedge clk);
			reset <= 0;
			key <= 0;		 					repeat(2) @(posedge clk);
			key <= 1;		 				 	repeat(2) @(posedge clk);
			key <= 0;						 	repeat(2) @(posedge clk); 
			key <= 1;							repeat(10) @(posedge clk); 
		$stop; // End the simulation
	end
endmodule 