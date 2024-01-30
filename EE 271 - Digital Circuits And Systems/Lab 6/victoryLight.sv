// module victoryLight defines additinoal functionality for a victory (edge) light.

// clk is the clock used for controlling input and output timing
// reset provides a potential route for reset on the lights
// player is which player's side this light is on (0 if player1 and 1 if player2)
// L is true when left key is pressed, R is true when the right key
	// is pressed, NL is true when the light on the left is on, and NR
	// is true when the light on the right is on.
// hex is which HEX display should be used to display the victorious player
module victoryLight (clk, reset, player, L, R, NL, NR, hex, lightOn);
	input logic clk, reset;
	input logic player;
	input logic L, R, NL, NR;
	output logic [6:0] hex;
	// when lightOn is true, the light should be on.
	output logic lightOn;
	
	// instantiates a normalLight for basic functionality of a playfield light,
		// specificying that this is not a center light
	normalLight victory (.clk(clk), .reset(reset), .L(L), .R(R), .NL(NL),
							  .NR(NR), .lightOn(lightOn), .center(1'b0));
							  
	
	// player 1 wins if the light on their side (LEDR[9]) is on and left button is pressed
	// player 2 wins if the light on their side (LEDR[1]) is on and right button is pressed
	// playerWin is set to directly equal 1 or 2, depending on which player won
	logic [1:0] playerWin;
	always_ff @(posedge clk) begin
		if (!player) begin
			if (lightOn && L)
				playerWin <= 2'b01;
			else
				playerWin <= 2'b00;
		end else begin
			if (lightOn && R)
				playerWin <= 2'b10;
			else
				playerWin <= 2'b00;
		end
	end

	// instantiates a seg7 module to control the respective hex display depending on which player won,
		// as recorded by playerWin.
	seg7 vicHex (.playerWin(playerWin), .hex(hex));

endmodule

//Test/Simulate the State Machine
module victoryLight_testbench();
	// creates corresponding variables to model victoryLight module
	logic clk, reset;
	logic player;
	logic L, R, NL, NR;
	logic [6:0] hex;
	// when lightOn is true, the normal light should be on.
	logic lightOn;
	
	// initializes victoryLight module for testing with name dut
	victoryLight dut (clk, reset, player, L, R, NL, NR, hex, lightOn);
	
	// Set up a simulated clock to toggle (from low to high or high to low)
		// every 50 time steps
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;//toggle the clock indefinitely
	end 

// Simulation sends the state machine into various scenarios.
	integer i;   
	initial begin
		reset <= 1;												 			 @(posedge clk); // Always reset FSMs at start
		reset <= 0;	// test player 2 functionality, with a single button press, both button presses,
							// and responses depending on whether the adjacent lights are on.
						{player, L, R, NL, NR} <= 5'b10000; 		repeat(3) @(posedge clk);
						{player, L, R, NL, NR} <= 5'b11000; 		repeat(3) @(posedge clk);
						{player, L, R, NL, NR} <= 5'b10100; 		repeat(3) @(posedge clk);
						{player, L, R, NL, NR} <= 5'b10110; 		repeat(3) @(posedge clk);
						{player, L, R, NL, NR} <= 5'b11000; 		repeat(3) @(posedge clk);
						{player, L, R, NL, NR} <= 5'b10110; 		repeat(3) @(posedge clk);
						{player, L, R, NL, NR} <= 5'b10100; 		repeat(5) @(posedge clk);
		
		reset <= 1;												 			 @(posedge clk); // Always reset FSMs at start
		reset <= 0;
						// player 1 functionality, with a single button press, both button presses,
							// and responses depending on whether the adjacent lights are on. 
						{player, L, R, NL, NR} <= 5'b00000; 		repeat(3) @(posedge clk);
						{player, L, R, NL, NR} <= 5'b00100; 		repeat(3) @(posedge clk);
						{player, L, R, NL, NR} <= 5'b01000; 		repeat(3) @(posedge clk);
						{player, L, R, NL, NR} <= 5'b01001; 		repeat(3) @(posedge clk);
						{player, L, R, NL, NR} <= 5'b00100; 		repeat(3) @(posedge clk);
						{player, L, R, NL, NR} <= 5'b01001; 		repeat(3) @(posedge clk);
						{player, L, R, NL, NR} <= 5'b01000; 		repeat(5) @(posedge clk);
		$stop; // End the simulation
	end
endmodule 