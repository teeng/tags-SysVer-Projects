// module counter defines a 3-bit counter for counting 7 total won rounds
	// for one player

// clk is the clock used for controlling input and output timing
// reset makes the count reset to 0
// win is whether a round was won
// out is the total times the player has won in the current game
module counter (clk, reset, win, lose, out);
	input logic clk, reset;
	input logic win, lose;
	output logic [2:0] out;
	
	
	// D Flip Flop implementation (DFFs)
	always_ff @(posedge clk) begin
		// on reset, the counter resets to 0
		if (reset)
			out <= 3'b0;
		else
			// if a round was won and the total number of times a player has won
				// is less than 7, then increase the total wins by 1.
			if (win && out < 7)
				out <= out + 1;
			// if a round was LOST and the total number of times a player has won
				// is more than 0, then decrease the total wins by 1.
			else if (lose && out > 0)
				out <= out - 1;
			else
				// otherwise, maintain the same win count.
				out <= out;
	end
		
endmodule


//Test/Simulate the State Machine
module counter_testbench();
	// creates corresponding variables to model inputDejammer module
	logic clk, reset;
	logic win, lose;
	logic [2:0] out;
	
	// initializes inputDejammer module for testing with name dut
	counter dut (clk, reset, win, lose, out);
	
	// Set up a simulated clock to toggle (from low to high or high to low)
	// every 50 time steps
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;//toggle the clock indefinitely
	end 

	// Set up the inputs to the design.  Each line represents a clock cycle
	// Tests responses to won rounds, or rounds that have not been won yet.
	// Expected results are that when a win is recorded, the count increases by 1 with a max of 7,
	// If a loss is recorded, the count decreases by 1, with a minimum of 0.
	initial begin
			reset <= 1;			 			  			  @(posedge clk); // Always reset FSMs at start
			reset <= 0;	win <= 0; lose <= 0;		  @(posedge clk);
			win <= 1;		  				  			  @(posedge clk);
			win <= 0;		  	 			 repeat(2) @(posedge clk);
			lose <= 1;		  				  			  @(posedge clk);
			lose <= 0;		  	 			 repeat(2) @(posedge clk);
			lose <= 1;		  				  			  @(posedge clk);
			lose <= 0;		  	 			 repeat(2) @(posedge clk);
			win <= 1;		  				  			  @(posedge clk);
			win <= 0;		  	 			 repeat(2) @(posedge clk);
			win <= 1;		  				  			  @(posedge clk);
			win <= 0;		  	 			 repeat(2) @(posedge clk);
			win <= 1;		  				  			  @(posedge clk);
			win <= 0;		  	 			 repeat(2) @(posedge clk);
			win <= 1;		  				  			  @(posedge clk);
			win <= 0;		  	 			 repeat(2) @(posedge clk);
			win <= 1;		  				  			  @(posedge clk);
			win <= 0;		  	 			 repeat(2) @(posedge clk);
			win <= 1;		  				  			  @(posedge clk);
			win <= 0;		  	 			 repeat(2) @(posedge clk);
			win <= 1;		  				  			  @(posedge clk);
			win <= 0;		  	 			 repeat(2) @(posedge clk);
			win <= 1;		  				  			  @(posedge clk);
			win <= 0;		  	 			 repeat(2) @(posedge clk);
			
			$stop; // End the simulation
		end
endmodule