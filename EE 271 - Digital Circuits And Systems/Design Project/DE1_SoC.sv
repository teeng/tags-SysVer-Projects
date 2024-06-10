// Top-level module that defines the I/Os for the DE-1 SoC board
// Creates and controls a game of Frogger, where a frog starting in the
	// 5th row from the top of the LED Array will need to reach the
	// uppermost row of the LED Array without running into any of the
	// moving cars. The frog can move freely across the 5*6 playfield,
	// granted that it doesn't run into a car.
// HEX0 keeps track of the number of victories, with a maximum of 7,
	// and upon a victory, the player can play again automatically.
	// If the frog runs into a car, then the victories is subtracted
	// by 1, the lowest being 0. All other HEXs are off.
// KEY[3] controls the frog by moving it one LED left
// KEY[2] controls the frog by moving it one LED right
// KEY[1] controls the frog by moving it one LED forward
// KEY[0] controls the frog by moving it one LED backward
// SW[9] resets the game, meaning that the score drops to 0.
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW, LEDR, GPIO_1, CLOCK_50);
	output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0]  LEDR;
	input  logic [3:0]  KEY;
	input  logic [9:0]  SW;
	output logic [35:0] GPIO_1;
	input logic CLOCK_50;

	// Turn off HEX displays except for HEX0, which displays the score
	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;

	/* Set up system base clock to 1526 Hz (50 MHz / 2**(14+1))
	===========================================================*/
	logic [31:0] div_clk;
	parameter sysClock = 14; // 1526 Hz clock signal
	parameter busClock = 23; // 3 Hz clock signal

	// SYSTEM_CLOCK is for all functionality such as button presses,
		// resets, general frog movement
	// BUS_CLOCK controls the speed of the cars and buses traversing
		// the playfield.
	logic SYSTEM_CLOCK;
	logic BUS_CLOCK;

	clock_divider divider (.clock(CLOCK_50), .divided_clocks(div_clk));

	// CLOCK SELECT - for simulation or for programming the DE1-SoC
	//assign SYSTEM_CLOCK = CLOCK_50;          // for simulation
	//assign BUS_CLOCK = CLOCK_50;          // for simulation		
	assign SYSTEM_CLOCK = div_clk[sysClock]; 
	assign BUS_CLOCK = div_clk[busClock];


	
	/* Set up LED board driver
	================================================================== */
	logic [15:0][15:0]RedPixels; // 16 x 16 array representing red LEDs
	logic [15:0][15:0]GrnPixels; // 16 x 16 array representing green LEDs
	
	
	logic resetGame;                   // reset - toggle this on startup
	assign resetGame = SW[9];
	logic resetRound;						  // automatically resets the round
														// by repositioning frog to start	

	/* Standard LED Driver instantiation - set once and 'forget it'. 
	See LEDDriver.sv for more info. Do not modify unless you know what you are doing! */
	LEDDriver Driver (.CLK(SYSTEM_CLOCK), .RST(resetGame), .EnableCount(1'b1), .RedPixels(RedPixels),
					.GrnPixels(GrnPixels), .GPIO_1(GPIO_1));

	
	/* LED board general control of frogger and cars

	=================================================================== */	
	// L, R, F, B stores inputs from KEY[3:0] that are sent through instantiated inputTug modules
		// for each button. These modules check for holding down the button (which is only counted once)
		// and also briefly delaying key presses to ensure stability. Output is sent to L, R, F, B.
	logic L, R, F, B;
	inputTug left (.clk(SYSTEM_CLOCK), .reset(resetGame), .key(KEY[3]), .tug(L));
	inputTug right (.clk(SYSTEM_CLOCK), .reset(resetGame), .key(KEY[2]), .tug(R));
	inputTug forward (.clk(SYSTEM_CLOCK), .reset(resetGame), .key(KEY[1]), .tug(F));
	inputTug back (.clk(SYSTEM_CLOCK), .reset(resetGame), .key(KEY[0]), .tug(B));
	
	// car and frog stores the positions of the cars and the frogs on the LED Array
		// car's 1st and 3rd rows (starting from 0th at the top) is controlled by the
		// output to the RedPixels in the same rows of the LED Array.
		// frog's positions are all controlled later through modules.
		
	// GrnPixels is controlled by both the positions of the frog and car.
		// Since car also uses RedPixels, cars will appear orange on the LED Array
		// Frog will only appear green
	logic [15:0][15:0] car, frog;
	assign car[1][15:10] = RedPixels[1][15:10];
	assign car[3][15:10] = RedPixels[3][15:10];
	assign GrnPixels = frog + car;
	
	// Instantiates two normalLight modules to control the cars in the 1st and 3rd rows of
		// the LED Array. The outputs are stored in the corresponding rows for RedPixels.
		// The clock is the slower BUS_CLOCK, which is only used to control the speed
			// of the cars.
		// dir is the direction the cars are traveling.
	normalLight topDanger (.clk(BUS_CLOCK), .reset(resetGame), .dir(1'b1), .lightOn(RedPixels[1][15:10]));
	normalLight botDanger (.clk(BUS_CLOCK), .reset(resetGame), .dir(1'b0), .lightOn(RedPixels[3][15:10]));
	
	// winRound contains whether the frog reached the top row
	// loseRound contains whether the frog ran into a vehicle
	logic winRound;
	logic loseRound;
	
	// win is controlled by whether the frog reached any LED in the top row.
	// If the frog reached one of the LEDs, the index of that LED will go high
	// winRound is set to whether any of the indices for the top row goes high,
		// meaning the frog reached the top row.
	logic [5:0] win;
	assign winRound = (win >= 1);
	
	// the frog resets to the starting position if it wins or loses a round.
	or (resetRound, winRound, loseRound);
	
	// checks if the frog ran into a car
		// by comparing whether both the positions of the car and the frog match
		// Outputs result to loseRound
	loseChecker lost (.car(car), .frog(frog), .lose(loseRound));
	
	// tracks the total wins for the player
	logic [2:0] totalWins;
	// instantiates a 3-bit counter to increment by 1 in the case of a round win
		// or decrement by 1 in the case of a round loss.
	counter wins (.clk(SYSTEM_CLOCK), .reset(resetGame), .win(winRound), .lose(loseRound), .out(totalWins));
	
	// the output of the 3-bit counter is sent to the HEX display through instantiated seg7, which
		// takes in the total wins and the HEX to display the value to.
	seg7 vicHex (.count(totalWins), .leds(HEX0));
	
	
	// generate variables i and j cycle through the rows or columns of the LED Array
		// to instantiate a module to control each necessary LED.
	genvar i, j;
	generate
		// instantiates victoryLight modules for the six leftmost LEDs on the top row of the LED Array.
			// the victoryLights are off on reset and are only affected by
			// the forward button and whether the light below them is on.
		// If the frog is below a victory light and the forward button is pressed,
			// the frog is victorious and returns to start.
		for(i=15; i>9; i--) begin :topRow
			victoryLight led (.clk(SYSTEM_CLOCK), .reset(resetRound),
							 .F(F), .NB(frog[1][i]),
							 .lightOn(frog[0][i]), .win(win[-i + 15]));
		end
		
		// Instantiates frogLight modules for the leftmost column for the first 5 rows of the
			// LED Array, without the edge cases.
		// However, if the frog presses left on the leftmost column, the frog will "cycle" to the
			// rightmost LED on the playfield, which is the 6th LED from the left.
		// The frog's movement is therefore continuous throughout the field.
		for(i=1; i<4; i++) begin :leftCol
			frogLight led (.clk(SYSTEM_CLOCK), .reset(resetGame), .roundWin(resetRound),
							 .L(L), .R(R), .F(F), .B(B),
							 .NL(frog[i][10]), .NR(frog[i][14]), .NF(frog[i-1][15]), .NB(frog[i+1][15]),
							 .center(1'b0), .lightOn(frog[i][15]));
		end
		
		// Instantiates frogLight modules for the middle rows and columns of the playfield
			// for the first 5 rows and 6 columns of the LED Array.
		for (j=1; j<4; j++) begin :midRow
			for(i=14; i>10; i--) begin :midCol
				frogLight led (.clk(SYSTEM_CLOCK), .reset(resetGame), .roundWin(resetRound),
								 .L(L), .R(R), .F(F), .B(B),
								 .NL(frog[j][i+1]), .NR(frog[j][i-1]), .NF(frog[j-1][i]), .NB(frog[j+1][i]),
								 .center(1'b0), .lightOn(frog[j][i]));
			end
		end
		
		
		// Instantiates frogLight modules for the rightmost column of the playfield
			// for the first 5 rows of the LED Array.
		// If the frog presses right on this column, the frog will "cycle" to the
			// leftmost LED on the playfield.
		// The frog's movement is therefore continuous throughout the field.
		for(i=1; i<4; i++) begin :rightCol
			frogLight led (.clk(SYSTEM_CLOCK), .reset(resetGame), .roundWin(resetRound),
							 .L(L), .R(R), .F(F), .B(B),
							 .NL(frog[i][11]), .NR(frog[i][15]), .NF(frog[i-1][10]), .NB(frog[i+1][10]),
							 .center(1'b0), .lightOn(frog[i][10]));
		end

		
		// Instantiates frogLight modules for the bottommost row of the playfield
			// (5th row of LED Array), not including edge cases.
		// The third LED from the left is the starting point for the frog,
			// which will be on after any reset.
		for(i=14; i>10; i--) begin :botRow
			if (i==13) begin
				frogLight led (.clk(SYSTEM_CLOCK), .reset(resetGame), .roundWin(resetRound),
							 .L(L), .R(R), .F(F), .B(B),
							 .NL(frog[4][i+1]), .NR(frog[4][i-1]), .NF(frog[3][i]), .NB(1'b0),
							 .center(1'b1), .lightOn(frog[4][i]));
			end else begin
				frogLight led (.clk(SYSTEM_CLOCK), .reset(resetGame), .roundWin(resetRound),
							 .L(L), .R(R), .F(F), .B(B),
							 .NL(frog[4][i+1]), .NR(frog[4][i-1]), .NF(frog[3][i]), .NB(1'b0),
							 .center(1'b0), .lightOn(frog[4][i]));
			end
		end
		
	endgenerate
	
	// instantiates frogLight modules for the bottom left and bottom right corners of the
		// playfield (the edge cases). As with the columns, if the frog presses left
		// on the leftmost LED, it will skip to the rightmost LED, appearing like
		// the playfield is continuous. The same happens for the right side but
		// skipping to the left.
	frogLight botLeft (.clk(SYSTEM_CLOCK), .reset(resetGame), .roundWin(resetRound),
							 .L(L), .R(R), .F(F), .B(B),
							 .NL(frog[4][10]), .NR(frog[4][14]), .NF(frog[3][15]), .NB(1'b0),
							 .center(1'b0), .lightOn(frog[4][15]));
	frogLight botRight (.clk(SYSTEM_CLOCK), .reset(resetGame), .roundWin(resetRound),
							 .L(L), .R(R), .F(F), .B(B),
							 .NL(frog[4][11]), .NR(frog[4][15]), .NF(frog[3][10]), .NB(1'b0),
							 .center(1'b0), .lightOn(frog[4][10]));
						
	
	
endmodule

	// Test and simulate the DE1_SoC module by testing switch inputs for reset
	// as well as testing key input to verify design.
module DE1_SoC_testbench();
	logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0]  LEDR;
	logic [3:0]  KEY;
	logic [9:0]  SW;
	logic [35:0] GPIO_1;
	logic CLOCK_50;

	// sets up a DE1_SoC named as dut for testbench.
	DE1_SoC dut (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW, LEDR, GPIO_1, CLOCK_50);

	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
	CLOCK_50 <= 0;
	// Forever toggle the clock
	forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
	end

	// Test the design.
	initial begin
		// test moving forward twice.
		// Expected result is that single button presses will shift the center light up once
			// and if the frog occupies the same LED as a car, then it will reset back to
			// starting position.
		
		// Game reset, resets all lights and hex displays
		SW[9] <= 1;						   					 	 @(posedge CLOCK_50);
			// testing loss from start.
			// Expected response is that the frog stays (since it was reset to start)
			KEY[3:0] <= 4'b0010;									 @(posedge CLOCK_50);
			KEY[3:0] <= 4'b0;									    @(posedge CLOCK_50);
		
			// testing movement with buttons as well as returning to start on loss
		SW[9] <= 1;						   						 @(posedge CLOCK_50);
		SW[9] <= 0;													 @(posedge CLOCK_50);
			KEY[3:0] <= 4'b0010;									 @(posedge CLOCK_50);
			KEY[3:0] <= 4'b0;									    @(posedge CLOCK_50);
			KEY[3:0] <= 4'b0010;									 @(posedge CLOCK_50);
			KEY[3:0] <= 4'b0;									    @(posedge CLOCK_50);
			KEY[3:0] <= 4'b0100;									 @(posedge CLOCK_50);
			KEY[3:0] <= 4'b0;									    @(posedge CLOCK_50);
			KEY[3:0] <= 4'b0010;									 @(posedge CLOCK_50);
			KEY[3:0] <= 4'b0;							repeat(5) @(posedge CLOCK_50);
	$stop; // End the simulation.
	end
endmodule