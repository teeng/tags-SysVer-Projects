// module victoryLight defines additional functionality for a victory (edge) light.

// clk is the clock used for controlling input and output timing
// reset turns the lights off on a new round, but maintains the hex display
// resetGame turns the lights off on a new game, which resets the hex display
// player is which player's side this light is on (0 if player1 and 1 if for the computer (player 2))
// L is true when left key is pressed, R is true when the right key
	// is pressed, NL is true when the light on the left is on, and NR
	// is true when the light on the right is on.
// hex is which HEX display should be used to display the victorious player
module victoryLight (clk, reset, resetGame, L, R, NL, NR, hex, lightOn, win);
	input logic clk, reset, resetGame;
	input logic L, R, NL, NR;
	output logic [6:0] hex;
	// when lightOn is true, the light should be on.
	output logic lightOn;
	output logic win;
	
	
	// instantiates a normalLight for basic functionality of a playfield light,
		// specificying that this is not a center light
	normalLight victory (.clk(clk), .reset(reset), .roundWin(win), .L(L), .R(R), .NL(NL),
							  .NR(NR), .lightOn(lightOn), .center(1'b0));
							  
	
	// player 1 wins if the light on their side (LEDR[9]) is on and left button is pressed
	// player 2 wins if the light on their side (LEDR[1]) is on and it simulates a button press
	// any win is determined by whether any button is pressed
		// and this victoryLight, or edge light, is on.
	enum logic [1:0] {roundCont=2'b00, roundWin=2'b01, roundStop=2'b10} ps, ns; 
	// This logic describes all the possible state transitions from ps to ns
	always_comb begin
		// otherwise, depending on whether the Left and Right buttons are pressed,
			// as well as whether the Next Left and Next Right lights are on,
			// turn the light on or off.
		win = ps[0];
		case (ps)
			roundStop: 										ns = roundStop;
			roundWin:		 								ns = roundStop;
			roundCont: if (lightOn && (L | R))		ns = roundWin;
						 else									ns = roundCont;
		endcase
	end
	
	always_ff @(posedge clk) begin
		if (reset)
			ps <= roundCont;
		else
			ps <= ns;
	end
	
	// update the total wins for the respective player that this victory light will trigger a winning
		// round for
	logic [2:0] totalWins;
	// instantiates a 3-bit counter to increment by 1 in the case of a round win.
	counter player (.clk(clk), .reset(resetGame), .win(win), .out(totalWins));
	// the output of the 3-bit counter is sent to the HEX display through instantiated seg7, which
		// takes in the total wins and the HEX to display the value to.
	seg7 vicHex (.count(totalWins), .leds(hex));
	
endmodule

//Test/Simulate the State Machine
module victoryLight_testbench();
	// creates corresponding variables to model victoryLight module
	logic clk, reset, resetGame;
	logic L, R, NL, NR;
	logic [6:0] hex;
	// when lightOn is true, the normal light should be on.
	logic lightOn;
	logic win;
	
	// initializes victoryLight module for testing with name dut
	victoryLight dut (clk, reset, resetGame, L, R, NL, NR, hex, lightOn, win);
	
	// Set up a simulated clock to toggle (from low to high or high to low)
		// every 50 time steps
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;//toggle the clock indefinitely
	end 

// Simulation sends the state machine into various scenarios.
	initial begin
		resetGame <= 1; reset <= 1;								    @(posedge clk); // Always reset FSMs at start
		resetGame <= 0; reset <= 0;	// test player 2 functionality, with a single button press, both button presses,
							// and responses depending on whether the adjacent lights are on.
							// Expected results are that there is no response when only the button
								// is pressed or no buttons are pressed.
							// Expect a win when either the left button is pressed and the next right LED is on,
								// or when the right button is pressed and the next left LED is on.
							// These wins are expected to trigger a change in the output HEX displays, which will
								// have the number of wins recorded.
						{L, R, NL, NR} <= 4'b0000; 		repeat(2) @(posedge clk);
						{L, R, NL, NR} <= 4'b1000; 		repeat(2) @(posedge clk);
						{L, R, NL, NR} <= 4'b1001; 		repeat(2) @(posedge clk);
						{L, R, NL, NR} <= 4'b0110; 		repeat(2) @(posedge clk);
		reset <= 1;															 @(posedge clk); // reset only the round, so the HEX display stays
		reset <= 0;
							// Test expected results again, this time still within one game.
								// So the HEX displays should display a value one more than the previous results.
						{L, R, NL, NR} <= 4'b0000; 		repeat(2) @(posedge clk);
						{L, R, NL, NR} <= 4'b0100; 		repeat(2) @(posedge clk);
						{L, R, NL, NR} <= 4'b1001; 		repeat(2) @(posedge clk);
						{L, R, NL, NR} <= 4'b0110; 		repeat(5) @(posedge clk);
		resetGame <= 1; reset <= 1;								    @(posedge clk); // reset the whole game, so the HEX display resets
		resetGame <= 0; reset <= 0;
							// Test expected results again, this time starting a new game.
						{L, R, NL, NR} <= 4'b0000; 		repeat(2) @(posedge clk);
						{L, R, NL, NR} <= 4'b1001; 		repeat(2) @(posedge clk);
						{L, R, NL, NR} <= 4'b0110; 		repeat(5) @(posedge clk);
		$stop; // End the simulation
	end
endmodule 