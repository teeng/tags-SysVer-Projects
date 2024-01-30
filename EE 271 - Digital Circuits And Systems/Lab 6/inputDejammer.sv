// inputDejammer ensures that user input from either player1 or player2,
	// controlling the keybuttons, is only valid on a clock edge
	// and that holding the button down only counts as one button press.
	// This ensures stable outputs without having completely random input combinations.
// key is the respective key for each player
// tug is the output of whether the button press is counted or not.
module inputDejammer (clk, reset, key, tug);
	input logic clk, reset;
	input logic key;
	output logic tug;
	
	// specifies various states of the button press. A miss is when the button
		// was not pressed on a clockedge. A hit is when the button was pressed on a 
		// clockedge. And a cheat is when the button is held for too long over multiple
		// clock edges (the button was held down).
	enum logic [1:0] {miss=2'b00, hit=2'b01, cheat=2'b10} ps, ns; 
	// This logic describes all the possible state transitions from ps to ns
	always_comb begin
		// tug is determined by the LSB of the possible states,
			// therefore, if it is a miss, then tug is LOW
			// if it is a hit, then tug is HIGH
			// if it is a cheat, then tug is LOW
		tug = ps[0];
		case (ps)				
			miss: if (!key)							ns = miss;
					else									ns = hit;
					
			hit: if (!key)								ns = miss;
				  else 									ns = cheat;
				  
		   cheat: if (!key)							ns = miss;
					 else									ns = cheat;
		endcase
	end

	// D Flip Flop implementation (DFFs)
	always_ff @(posedge clk) begin
		// on reset, any button presses are counted as misses
		if (reset)
			ps <= miss;
		else
			ps <= ns; //Otherwise, advances to next state in state diagram
	end
	
endmodule


//Test/Simulate the State Machine
module inputDejammer_testbench();
	// creates corresponding variables to model inputDejammer module
	logic clk, reset;
	logic key;
	// when tug is true, the playfield light should shift
	logic tug;
	
	// initializes inputDejammer module for testing with name dut
	inputDejammer dut (clk, reset, key, tug);
	
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
	integer i;   
	initial begin
			reset <= 1;									 @(posedge clk); // Always reset FSMs at start
			reset <= 0;	key <= 0;					 @(posedge clk);
			key <= 1;		 							 @(posedge clk);
			key <= 0;									 @(posedge clk); 
			key <= 1;						repeat(5) @(posedge clk); 
		$stop; // End the simulation
	end
endmodule 