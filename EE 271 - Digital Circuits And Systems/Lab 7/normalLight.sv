// module normalLight defines basic functionality for a playfield light.
// also has additionally functionality for center light

// clk is the clock used for controlling input and output timing
// reset will turn the lights off when active, except the specified center
	// light, which will be on.
// roundWin is whether or not the round has been won, meaning all
	// lights should turn off and not respond to any further inputs.
	// This ensures that a new round is started to continue to play
	// the game.
// L is true when left key is pressed, R is true when the right key
	// is pressed, NL is true when the light on the left is on, and NR
	// is true when the light on the right is on. 
// center is an input for whether this light is the center light, 0 if not.
module normalLight (clk, reset, roundWin, L, R, NL, NR, lightOn, center);
	input logic clk, reset, roundWin;
	input logic L, R, NL, NR, center;
	// when lightOn is true, the normal light should be on.
	output logic lightOn;
	
	// two states for a light, either off or on
	enum logic {off=1'b0, on=1'b1} ps, ns; 
	// This logic describes all the possible state transitions from ps to ns
	always_comb begin
		// by default, if not satisfying any other designated inputs, stay in the present state
		ns = ps;
		// otherwise, depending on whether the Left and Right buttons are pressed,
			// as well as whether the Next Left and Next Right lights are on,
			// turn the light on or off.
		case (ps)
			off: if (L && !R && !NL && NR)		ns = on; // 1001
				else if(!L && R && NL && !NR)		ns = on; // 0110
			
			on: if(L && !R && !NL && !NR)			ns = off; // 1000
				else if (!L && R && !NL && !NR)	ns = off; // 0100
				else if(!L && !R && !NL && !NR)	ns = on; // 0000
				else if(L && R && !NL && !NR)		ns = on; // 1100
		endcase
	end

	// Output logic
	// Output to lightOn matches the present state, which is encoded
		// to represent whether it is HIGH or LOW
	assign lightOn = ps;
	
	// D Flip Flop implementation (DFFs)
	always_ff @(posedge clk) begin
		// if on reset, the light is designated as a center light, turn the light on,
			// if not a center light, turn the light off.
		if (reset) begin
			if (center)
				ps <= on;
			else
				ps <= off;
		// if the round has been won, set ps to off state
			// since the next left and next right LEDs are never
			// on when a round is won, this keeps the LEDs in the off state.
		end else if (roundWin)
			ps <= off;
		else
			ps <= ns; //Otherwise, advances to next state in state diagram
	end
	
endmodule


//Test/Simulate the State Machine
module normalLight_testbench();
	// creates corresponding variables to model normalLight module
	logic clk, reset, roundWin;
	logic L, R, NL, NR, center;
	// when lightOn is true, the normal light should be on.
	logic lightOn;
	
	// initializes normalLight module for testing with name dut
	normalLight dut (clk, reset, roundWin, L, R, NL, NR, lightOn, center);
	
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
		reset <= 1; roundWin <= 0;					 					@(posedge clk); // Always reset FSMs at start
		reset <= 0; center <= 0;	 			 						@(posedge clk);
		
		for(i=0; i<16; i++) begin  
			{L, R, NL, NR} <= i; 										@(posedge clk);  
		end
		
		repeat(8) @(posedge clk);
		// Tests general functionality after reset with multiple combinations of button presses,
			// including neither pressed, both pressed, one pressed with neither neighboring lights on,
			// and one pressed with a neighboring light on.
		// Expected results include that the light turns on only if an adjacent light is on and the button
			// pressed is opposite of the direction that adjacent light is.
			// Meaning, for the light to turn on when the next left light is on, right button must be pressed.
		// Additionally, button presses should not affect current light when no adjacent lights are on
		// Current light should not turn on if there is no button press even when adjacent lights are on.
		reset <= 1;	roundWin <= 0;								 		 @(posedge clk); // Always reset FSMs at start
		reset <= 0; {L, R, NL, NR} <= 4'b0000; 		repeat(2) @(posedge clk);
						{L, R, NL, NR} <= 4'b1100; 		repeat(2) @(posedge clk);
						{L, R, NL, NR} <= 4'b1000; 		repeat(2) @(posedge clk);
						{L, R, NL, NR} <= 4'b0100; 		repeat(2) @(posedge clk);
						{L, R, NL, NR} <= 4'b1001; 		repeat(2) @(posedge clk);
		roundWin <= 1; // tests whether lights change on roundWin. Expected results is that they all turn off
						{L, R, NL, NR} <= 4'b0000; 		repeat(2) @(posedge clk);
						{L, R, NL, NR} <= 4'b0110; 		repeat(2) @(posedge clk);
						{L, R, NL, NR} <= 4'b1001; 		repeat(10) @(posedge clk);
		
		$stop; // End the simulation
	end
endmodule 