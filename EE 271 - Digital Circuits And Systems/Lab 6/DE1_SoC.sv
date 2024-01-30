// Top-level module DE1_SoC that defines the I/Os for the DE-1 SoC
	// board with parameters CLOCK_50 (50 MHz clock), HEX0, HEX1, LEDR, KEY, LEDR, and SW

// The HEX0, HEX1 parameters will be for the 7-segment HEX display on the De-1 SoC board
// The KEY parameter will be for the 4 pushbuttons on the De-1 SoC board.
// The LEDR parameter will be for the 10 red LEDs on the De-1 SoC board
// the SW parameter will be for the 10 switches on the De-1 SoC board
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
	
	// Generate clk off of CLOCK_50, whichClock picks rate/frequency.
	logic reset;
	assign reset = SW[9];
	logic [31:0] div_clk;
	// Select 0.75 Hz clock 
	parameter whichClock = 25; 
	
	// instantiates a clock divider, which will make the clock cycle and its effects
		// more visible in simulation.
	clock_divider cdiv (.clock(CLOCK_50), 
							  .reset(reset),
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
	logic L;
	logic R;
	// Instantiates inputDejammers for both players, which will take the input from the keybuttons
		// and ensure the button was pressed on a clockedge from clkSelect to prevent metastability with LEDRs.
	// Additionally, ensures that if a player holds down a button continuously, it only counts
		// as one button press and not multiple. Overall ensuring stable results to LEDRs.
	// player 1 input is controlled by KEY[3] and will make the playfield light go left if successful.
	// player 2 input is controlled by KEY[0] and will make the playfield light go right if successful.
	inputDejammer player1 (.clk(clkSelect), .reset(reset), .key(!KEY[3]), .tug(L));
	inputDejammer player2 (.clk(clkSelect), .reset(reset), .key(!KEY[0]), .tug(R));
	
	
	// center is used to check if the light is the center light, which will be on at the start of a new game
	// following a reset.
	// for all other playfield lights, center is 0, meaning the light will be off.
	logic center;
	assign center = 1'b0;
	
	// Instantiates victoryLight for led1 and led9, which has the functionality of a playfield light
		// (described below), but will also trigger an output to the HEX display on which
		// player was victorious. A player is victorious if the playfield light was successfully pulled
		// to their side completely (and is pulled off of the playfield).
	victoryLight led1 (.clk(clkSelect), .reset(reset), .player(1), .L(L), .R(R), .NL(LEDR[2]),
							  .NR(0), .hex(HEX0), .lightOn(LEDR[1]));
	victoryLight led9 (.clk(clkSelect), .reset(reset), .player(0), .L(L), .R(R), .NL(0),
							  .NR(LEDR[8]), .hex(HEX1), .lightOn(LEDR[9]));
							  
	// Instantiates a normalLight for led2 through led8, normal playfield lights.
	// These lights are all off except for one, which is shifted left or right depending on
		// which user input landed on a clock edge. If player 1 presses the keybutton on the
		// clockedge for clkSelect, then the playfield light will shift left. The same for player 2
		// but the light will shift right instead.
	// The center light is an instantiated normalLight but with center specified as 1, which
		// will cause it to stay on after reset. All other normalLights have a center specified as 0,
		// making it turn off after reset.
	
	// Each light is controlled by reset (SW[9]) and will only shift on a clockedge of clkSelect.
	// Every light recieves input on which button is pressed, and uses this information to determine
		// whether the current(lightOn) and neighboring lights (NL and NR) are on or off.
	normalLight led2 (.clk(clkSelect), .reset(reset), .L(L), .R(R), .NL(LEDR[3]),
							  .NR(LEDR[1]), .lightOn(LEDR[2]), .center(center));
	normalLight led3 (.clk(clkSelect), .reset(reset), .L(L), .R(R), .NL(LEDR[4]),
							  .NR(LEDR[2]), .lightOn(LEDR[3]), .center(center));						  
	normalLight led4 (.clk(clkSelect), .reset(reset), .L(L), .R(R), .NL(LEDR[5]),
							  .NR(LEDR[3]), .lightOn(LEDR[4]), .center(center));						  
	normalLight led5 (.clk(clkSelect), .reset(reset), .L(L), .R(R), .NL(LEDR[6]),
							  .NR(LEDR[4]), .lightOn(LEDR[5]), .center(1));						  
	normalLight led6 (.clk(clkSelect), .reset(reset), .L(L), .R(R), .NL(LEDR[7]),
							  .NR(LEDR[5]), .lightOn(LEDR[6]), .center(center));						  
	normalLight led7 (.clk(clkSelect), .reset(reset), .L(L), .R(R), .NL(LEDR[8]),
							  .NR(LEDR[6]), .lightOn(LEDR[7]), .center(center));
   normalLight led8 (.clk(clkSelect), .reset(reset), .L(L), .R(R), .NL(LEDR[9]),
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
				// test button press from both KEY[0] and KEY[3], including both buttons pressed together
				SW[9] <= 1;	{KEY[0], KEY[3]} = 2'b00;				repeat(3) @(posedge CLOCK_50);
				SW[9] <= 0;													repeat(3) @(posedge CLOCK_50);
				{KEY[0], KEY[3]} = 2'b01;								 			 @(posedge CLOCK_50);
				{KEY[0], KEY[3]} = 2'b00;								repeat(6) @(posedge CLOCK_50);
				{KEY[0], KEY[3]} = 2'b10;											 @(posedge CLOCK_50);
				{KEY[0], KEY[3]} = 2'b00;								repeat(6) @(posedge CLOCK_50);
				{KEY[0], KEY[3]} = 2'b11;											 @(posedge CLOCK_50);
				{KEY[0], KEY[3]} = 2'b00;								repeat(6) @(posedge CLOCK_50);
				
				// test tapping each key
				SW[9] <= 1; {KEY[0], KEY[3]} = 2'b00;				repeat(3) @(posedge CLOCK_50);
				SW[9] <= 0;													repeat(3) @(posedge CLOCK_50);	
				{KEY[0], KEY[3]} = 2'b00;								repeat(3) @(posedge CLOCK_50);
				{KEY[0], KEY[3]} = 2'b10;								repeat(3) @(posedge CLOCK_50);
				{KEY[0], KEY[3]} = 2'b00;								repeat(3) @(posedge CLOCK_50);
				{KEY[0], KEY[3]} = 2'b01;								repeat(3) @(posedge CLOCK_50);
				{KEY[0], KEY[3]} = 2'b00;								repeat(3) @(posedge CLOCK_50);
				
				// test holding a key
				SW[9] <= 1;													repeat(3) @(posedge CLOCK_50);
				SW[9] <= 0; {KEY[0], KEY[3]} = 2'b01;				repeat(5) @(posedge CLOCK_50);
				
				// test tapping to win to trigger victory
				SW[9] <= 1; {KEY[0], KEY[3]} = 2'b00;				repeat(3) @(posedge CLOCK_50);
				SW[9] <= 0;													repeat(3) @(posedge CLOCK_50);	
				{KEY[0], KEY[3]} = 2'b00;								repeat(3) @(posedge CLOCK_50);
				{KEY[0], KEY[3]} = 2'b10;								repeat(3) @(posedge CLOCK_50);
				{KEY[0], KEY[3]} = 2'b00;								repeat(3) @(posedge CLOCK_50);
				{KEY[0], KEY[3]} = 2'b00;								repeat(3) @(posedge CLOCK_50);
				{KEY[0], KEY[3]} = 2'b10;								repeat(3) @(posedge CLOCK_50);
				{KEY[0], KEY[3]} = 2'b00;								repeat(3) @(posedge CLOCK_50);
				{KEY[0], KEY[3]} = 2'b00;								repeat(3) @(posedge CLOCK_50);
				{KEY[0], KEY[3]} = 2'b10;								repeat(3) @(posedge CLOCK_50);
				{KEY[0], KEY[3]} = 2'b00;								repeat(3) @(posedge CLOCK_50);
				{KEY[0], KEY[3]} = 2'b00;								repeat(3) @(posedge CLOCK_50);
				{KEY[0], KEY[3]} = 2'b10;								repeat(3) @(posedge CLOCK_50);
				{KEY[0], KEY[3]} = 2'b00;								repeat(3) @(posedge CLOCK_50);
				{KEY[0], KEY[3]} = 2'b00;								repeat(3) @(posedge CLOCK_50);
				{KEY[0], KEY[3]} = 2'b10;								repeat(3) @(posedge CLOCK_50);
				{KEY[0], KEY[3]} = 2'b00;								repeat(3) @(posedge CLOCK_50);
				
			$stop; // End the simulation.
		end 
endmodule 