// module frogLight defines basic movement for the frog.
// also has additionally functionality for center light

// clk is the clock used for controlling input and output timing
// reset will turn the lights off when active, except the specified center
	// light, which will be on.
// roundWin is whether or not the round has been won, meaning
	// that the frog should reset back to the start (the designated center light).
// L is true when left key (KEY[3]) is pressed
// R is true when the right key (KEY[2]) is pressed
// F is true when the right key (KEY[1]) is pressed
// B is true when the right key (KEY[0]) is pressed
// NL is true when the light on the left is on
// NR is true when the light on the right is on
// NF is true when the light forward is on
// NB is true when the light backward is on
// center is an input for whether this light is the center light, 0 if not.
// lightOn is whether the light should be on or not, 1 if on.
module frogLight (clk, reset, roundWin, L, R, F, B, NL, NR, NF, NB, center, lightOn);
	input logic clk, reset, roundWin;
	input logic L, R, F, B, NL, NR, NF, NB, center;
	// when lightOn is true, the normal light should be on.
	output logic lightOn;
	
	// two states for a light, either off or on
	enum logic {off=1'b0, on=1'b1} ps, ns; 
	// This logic describes all the possible state transitions from ps to ns
	always_comb begin
		// by default, if not satisfying any other designated inputs, stay in the present state
		ns = ps;
		// otherwise, depending on whether the Left, Right, Forward, and Backward buttons are pressed,
			// as well as whether the Next Left, Next Right, Next Forward,
			// and Next Backward lights are on, turn the light on or off.
		case (ps)
			off: if ({L, R, F, B, NL, NR, NF, NB} == 8'b10000100) 					ns = on;
				else if ({L, R, F, B, NL, NR, NF, NB} == 8'b01001000) 				ns = on;
				else if ({L, R, F, B, NL, NR, NF, NB} == 8'b00100001) 				ns = on;
				else if ({L, R, F, B, NL, NR, NF, NB} == 8'b00010010) 				ns = on;
			
			on: if ({L, R, F, B, NL, NR, NF, NB} == 8'b10000000) 						ns = off;
				else if ({L, R, F, B, NL, NR, NF, NB} == 8'b01000000) 				ns = off;
				else if ({L, R, F, B, NL, NR, NF, NB} == 8'b00100000) 				ns = off;
				else if ({L, R, F, B, NL, NR, NF, NB} == 8'b00010000) 				ns = off;
		endcase
	end

	// Output logic
	// Output to lightOn matches the present state, which is encoded
		// to represent whether it is HIGH or LOW
	assign lightOn = ps;
	
	// D Flip Flop implementation (DFFs)
	always_ff @(posedge clk) begin
		// if on reset or a roundWin
			// turn the light on if it is the designated center light,
			// otherwise turn off.
		if (reset | roundWin) begin
			if (center)
				ps <= on;
			else
				ps <= off;
		// if not on reset or roundWin, advance to the next state in the state
			// diagram
		end else
			ps <= ns;
	end
	
endmodule


//Test/Simulate the State Machine
module frogLight_testbench();
	// creates corresponding variables to model frogLight module
	logic clk, reset, roundWin;
	logic L, R, F, B, NL, NR, NF, NB, center;
	// when lightOn is true, the normal light should be on.
	logic lightOn;
	
	// initializes frogLight module for testing with name dut
	frogLight dut (clk, reset, roundWin, L, R, F, B, NL, NR, NF, NB, center, lightOn);
	
	// Set up a simulated clock to toggle (from low to high or high to low)
	// every 50 time steps
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;//toggle the clock indefinitely
	end 

// Simulation with different situations
	initial begin
		// Tests general functionality after reset with multiple combinations of button presses,
			// including neither pressed, both pressed, one pressed with neither neighboring lights on,
			// and one pressed with a neighboring light on.
		
		// Expected results include that the light turns on only if an adjacent light is on and the button
			// pressed is opposite of the direction that adjacent light is.
			// Meaning, for the light to turn on when the next left light is on, right button must be pressed.

		// Additionally, button presses should not affect current light when no adjacent lights are on
		// Current light should not turn on if there is no button press even when adjacent lights are on.
		reset <= 1;													 					 @(posedge clk); // Always reset FSMs at start
		reset <= 0; center <= 0; roundWin <= 0;
						{L, R, F, B, NL, NR, NF, NB} <= 4'b0; 		repeat(2) @(posedge clk);
						{L, R, NL, NR} <= 4'b1100; 					repeat(2) @(posedge clk);
						{L, R, NL, NR} <= 4'b1000; 					repeat(2) @(posedge clk);
						{L, R, NL, NR} <= 4'b1001; 					repeat(2) @(posedge clk);
						{L, R, NL, NR} <= 4'b0;
						{F, B, NF, NB} <= 4'b1000; 					repeat(2) @(posedge clk);
						{F, B, NF, NB} <= 4'b1001; 					repeat(5) @(posedge clk);
		// tests response on roundWin.Expected results is that light is off
				// when it is not a center light
		reset <= 0; center <= 0; roundWin <= 1;								 @(posedge clk);
						{L, R, NL, NR} <= 4'b0000; 					repeat(2) @(posedge clk);
						{L, R, NL, NR} <= 4'b0110; 					repeat(2) @(posedge clk);
						{L, R, NL, NR} <= 4'b1001; 					repeat(5) @(posedge clk);
		// test that light is on for reset since it is the designated center light
		reset <= 0; center <= 1;													 @(posedge clk);
						{L, R, NL, NR} <= 4'b0000; 					repeat(2) @(posedge clk);
						{L, R, NL, NR} <= 4'b0110; 					repeat(2) @(posedge clk);
						{L, R, NL, NR} <= 4'b1001; 					repeat(5) @(posedge clk);
		$stop; // End the simulation
	end
endmodule 