// Top-level module DE1_SoC that defines the I/Os for the DE-1 SoC
	// board with parameters CLOCK_50 (50 MHz clock), HEX0, HEX1, LEDR, KEY, LEDR, and SW

// The HEX0, HEX1 parameters will be for the 7-segment HEX display on the DE-1 SoC board
// The KEY parameter will be for the 4 pushbuttons on the DE-1 SoC board.
// The LEDR parameter will be for the 10 red LEDs on the DE-1 SoC board
// the SW parameter will be for the 10 switches on the DE-1 SoC board
module DE1_SoC (CLOCK_50, HEX0, HEX1, KEY, LEDR, SW);
	input  logic         CLOCK_50; // 50MHz clock.
	output logic  [6:0]  HEX0, HEX1;
	output logic  [9:0]  LEDR;
	
	// Key/Buttons are initially True when not pressed, False when pressed
	// However, to standardize and make simulation intuitive across all involved modules
		// Key/Button input was later inverted in inputs below.
	// Therefore, for this module and sub-modules, HIGH represents the button is pressed, LOW represents unpressed
	input  logic  [3:0]  KEY; 
	input  logic  [9:0]  SW;
	
	// resetGame is a reset meant to turn off the necessary lights and return the HEX display back to 0
	// resetGame occurs when SW[9] is high.
	logic resetGame;
	assign resetGame = SW[9];
	
	// resetRound is a reset meant to maintain the HEX display, which shows the number of rounds won for each player.
	logic resetRound;
	
	// internal logic v0 to support gate-level implementation, which will reduce number of gates to a definite amount
	logic resetPress;
	not (resetPress, KEY[0]);
	// resetRound is assigned to KEY[0], where pressing the keybutton will reset the round OR
		// whether resetGame is high, meaning that the entire game should be reset and therefore
		// all lights but center should turn off. This makes it so a new game start will automatically
		// reset the lights as well.
	or (resetRound, resetPress, resetGame);
	
	// Generate clk off of CLOCK_50, whichClock picks rate/frequency.
	logic [31:0] div_clk;
	// Select 768 Hz clock
	parameter whichClock = 16; 
	
	// instantiates a clock divider, which will make the clock cycle and its effects
		// more visible in simulation.
	clock_divider cdiv (.clock(CLOCK_50), 
							  .reset(resetRound),
							  .divided_clocks(div_clk));
	
	// Clock selection; 
	// allows for easy switching between simulation and board clocks 
	logic clkSelect;

	// Uncomment ONE of the following two lines depending on intention
	assign clkSelect = CLOCK_50;          // for simulation
	//assign clkSelect = div_clk[whichClock]; // for synthesis on DE1_SoC board
	
	// logic L and R representing whether the left-most or right-most button was successfully
	// pressed by either player 1 or player 2 respectively. L and R are used for
	// determining the states of all the LEDRs.
	// logic win1 and win2 records whether player 1 or player 2 (the computer) won.
	logic L;
	logic R;
	logic win1;
	logic win2;
	
	// Instantiates inputTug for player 1, which will record whether the player is holding the button down or not
		// (attempting to cheat) while also making sure output is stable by sending through two flip flops.
	// Instantiates a computer player as a competitor, with a difficulty level controlled by SW[8:0] and
		// will simulate a tug on the Tug-O-war rope by "pressing" the right button
	// player 1 input is controlled by KEY[3] and will make the playfield light go left if successful.
	// player 2 input is controlled by computer and will make the playfield light go right if 
		// simulated button press is successful.
	inputTug player1 (.clk(clkSelect), .reset(resetGame), .key(!KEY[3]), .tug(L));
	computer comp (.clk(clkSelect), .reset(resetGame), .SW(SW[8:0]), .tug(R));
	
	// center is used to check if the light is the center light, which will be on at the start of a new game
	// following a reset.
	// for all other playfield lights, center is 0, meaning the light will be off.
	parameter center = 1'b0;
	
	// Instantiates victoryLight for led1 and led9, which has the functionality of a playfield light
		// (described below), but will also trigger an output to the HEX display depdning on which player
		// won however many rounds. There is a maximum of 7 rounds won before the hex display stops
		// incrementing.
	// A player is victorious if the playfield light was successfully pulled
		// to their side completely (and is pulled off of the playfield). This is LED9 for player 1 and LED1 for the computer
	// resetGame and resetRound are both used to control the victoryLights. resetRound allows for the
		// victory light to turn off on a new round, like a normal playfield light
		// resetGame resets the HEX displays to 00 for both players, starting a new game.
	victoryLight led1 (.clk(clkSelect), .reset(resetRound), .resetGame(resetGame), .L(L), .R(R), .NL(LEDR[2]),
							  .NR(1'b0), .hex(HEX0), .lightOn(LEDR[1]), .win(win1));
	victoryLight led9 (.clk(clkSelect), .reset(resetRound), .resetGame(resetGame), .L(L), .R(R), .NL(1'b0),
							  .NR(LEDR[8]), .hex(HEX1), .lightOn(LEDR[9]), .win(win2));
		
	// internal logic win records whether any win was recorded, and therefore the round should not
		// be further played until resetRound is high.
	logic win;
	or (win, win1, win2);
	// Instantiates a normalLight for led2 through led8, normal playfield lights.
	// These lights are all off except for the center, which is shifted left or right depending on
		// which user input landed on a clock edge. If player 1 presses the keybutton on the
		// clockedge for clkSelect, then the playfield light will shift left. The same for player 2
		// but the light will shift right instead.
	// The center light is an instantiated normalLight but with center specified as 1, which
		// will cause it to stay on after reset. All other normalLights have a center specified as 0,
		// making it turn off after a round or game is reset.
	
	// Each light is controlled by resetRound, turning the lights off, except for the center light,
		// on a new round.  Additionally, lights will only shift on a clockedge of clkSelect.
	// Every light receives input on which button is pressed, and uses this information to determine
		// whether the current(lightOn) and neighboring lights (NL and NR) are on or off.
	normalLight led2 (.clk(clkSelect), .reset(resetRound), .roundWin(win), .L(L), .R(R), .NL(LEDR[3]),
							  .NR(LEDR[1]), .lightOn(LEDR[2]), .center(center));
	normalLight led3 (.clk(clkSelect), .reset(resetRound), .roundWin(win), .L(L), .R(R), .NL(LEDR[4]),
							  .NR(LEDR[2]), .lightOn(LEDR[3]), .center(center));						  
	normalLight led4 (.clk(clkSelect), .reset(resetRound), .roundWin(win), .L(L), .R(R), .NL(LEDR[5]),
							  .NR(LEDR[3]), .lightOn(LEDR[4]), .center(center));						  
	normalLight led5 (.clk(clkSelect), .reset(resetRound), .roundWin(win), .L(L), .R(R), .NL(LEDR[6]),
							  .NR(LEDR[4]), .lightOn(LEDR[5]), .center(1'b1));						  
	normalLight led6 (.clk(clkSelect), .reset(resetRound), .roundWin(win), .L(L), .R(R), .NL(LEDR[7]),
							  .NR(LEDR[5]), .lightOn(LEDR[6]), .center(center));						  
	normalLight led7 (.clk(clkSelect), .reset(resetRound), .roundWin(win), .L(L), .R(R), .NL(LEDR[8]),
							  .NR(LEDR[6]), .lightOn(LEDR[7]), .center(center));
   normalLight led8 (.clk(clkSelect), .reset(resetRound), .roundWin(win), .L(L), .R(R), .NL(LEDR[9]),
							  .NR(LEDR[7]), .lightOn(LEDR[8]), .center(center));	

						  
							  
endmodule

// Test and simulate the DE1_SoC module by testing switch inputs for reset
// as well as testing key input to verify design.
module DE1_SoC_testbench();
	logic         CLOCK_50;
	logic  [6:0]  HEX0, HEX1;
	logic  [9:0]  LEDR;
	logic  [3:0]  KEY;
	logic  [9:0]  SW;
   
	// sets up a DE1_SoC named as dut for testbench.
	DE1_SoC dut (CLOCK_50, HEX0, HEX1, KEY, LEDR, SW);
	
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
			CLOCK_50 <= 0;
			// Forever toggle the clock
			forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
	end
	
	// Test the design.
	initial begin
				// test button press from KEY[0]
				// Expected result is that single button presses will shift the center light left once
					// even if held down over multiple clock cycles
				// Game reset, resets all lights and hex displays
				SW[9] <= 1; KEY[0] <= 0;						   					 @(posedge CLOCK_50);
				SW[9] <= 0; KEY[0] <= 1;
				// button is unpressed for player 1, computer is inactive (all switches off)
				KEY[3] <= 1; {SW[8:0]} <= 9'b0;						   repeat(3) @(posedge CLOCK_50);
				 
				KEY[0] <= 0; 													repeat(5) @(posedge CLOCK_50); // reset round
				KEY[0] <= 1; 														   	 @(posedge CLOCK_50);
				// button is unpressed for player 1, computer is lowest level difficulty
				// expected results are that center light now shifts right to follow computer presses
				KEY[3] <= 1; {SW[8:0]} = 9'b000010000;			    	repeat(30) @(posedge CLOCK_50);
				
				KEY[0] <= 0; 													repeat(5) @(posedge CLOCK_50); // reset round
				KEY[0] <= 1; 														   	 @(posedge CLOCK_50);
				// button is unpressed for player 1, computer is on a medium level difficulty
				// expected results are that center light now shifts either left or right depending
					// on button presses and computer presses
				KEY[3] <= 1; {SW[8:0]} = 9'b000010000;			   	repeat(3) @(posedge CLOCK_50);
				// tap player 1 button
				KEY[3] <= 0;							 			 						 @(posedge CLOCK_50);
				KEY[3] <= 1;							 			 						 @(posedge CLOCK_50);
				KEY[3] <= 0;							 			 						 @(posedge CLOCK_50);
				KEY[3] <= 1;							 			 						 @(posedge CLOCK_50);
				KEY[3] <= 0;							 			 						 @(posedge CLOCK_50);
				KEY[3] <= 1;							 			 						 @(posedge CLOCK_50);
				KEY[3] <= 0;							 			 						 @(posedge CLOCK_50);
				KEY[3] <= 1;							 			 						 @(posedge CLOCK_50);
				KEY[3] <= 0;							 			 						 @(posedge CLOCK_50);
				KEY[3] <= 1;							 			 			repeat(2) @(posedge CLOCK_50);
				KEY[3] <= 0;							 			 						 @(posedge CLOCK_50);
				KEY[3] <= 1;							 			 						 @(posedge CLOCK_50);
				
				KEY[0] <= 0; 													repeat(5) @(posedge CLOCK_50); // reset round
				KEY[0] <= 1; 														   	 @(posedge CLOCK_50)
				// button is unpressed for player 1, computer is on maximum difficulty
				// expected results are that center light now shifts right for computer presses
				KEY[3] <= 0; {SW[8:0]} = 9'b111111111;				repeat(30) @(posedge CLOCK_50);
			$stop; // End the simulation.
		end
endmodule