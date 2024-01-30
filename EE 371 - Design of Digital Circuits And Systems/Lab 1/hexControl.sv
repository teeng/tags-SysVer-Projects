/*
Lab 1

This module controls the six HEX displays on the De-1 SoC board,
displaying both the count and whether the parking lot is full or clear
Input:
	reset: 1b reset signal to set sensors to default behavior
	count: 5b signal representing the number of cars currently in the parking lot
Outputs:
	hex5 through hex0: 7b signal each for which of the segments should be lit for each of the hex displays
*/
module hexControl (reset, count, hex5, hex4, hex3, hex2, hex1, hex0);
	input  logic reset;
	input  logic  [4:0] count;
	output logic  [6:0] hex5, hex4, hex3, hex2, hex1, hex0;
	
	// separating the ones digit for count, which should always be displayed on hex0
		// Also has a limit of 9, so four bits is needed
	logic [3:0] ones;
	assign ones = count % 10;
	// separating the tens digit for count, which may or may not be displayed on hex1,
		// depending on further logic
		// Also has a limit of 2 (count limit is 25) so only two bits is needed.
	logic [1:0] tens;
	assign tens = count / 10;
	
	// internal logic controls what should be displayed on hex1
	logic [6:0] hexR, hexTens, hexTemp;
	logic selHex1R, selHex1Show;
	
	// internal logic determining current value of count, which will control hex1's output
	assign selHex1R = (5'b0 == (count & 5'b11111)); //if count is 0, output selHex1R HIGH
	assign selHex1Show = ((2'b0 == (tens & 2'b11)) & (4'b0 != (ones & 4'b1111))); //if tens is 0 but ones is not 0, output selHex1Show HIGH
	
	// Instantiates two 7b length muxnb2_1 to select what to output to hex1
	// hex1Clear:	
		// controlled by 1b selHex1R, and selects between option 1: 7b hexR, the letter R
			// or option 0: hexTens, the tens digit of count
		// outputs 7b option selected to hexTemp for the next muxnb2_1
	// hex1Show:
		// controlled by selHex1Show, and selects between option 1: HEX display off (7b all HIGH) if count is between 0 and 10
			// or option 0: where the count is less than 10 but greater than 0, and is the tens digit for count
		// output is 7b option selected to hex1, the HEX1 display on the De-1 SoC board
	muxnb2_1 #(.WIDTH(7)) hex1Clear (.sel(selHex1R), .in1(hexR), .in0(hexTens), .out(hexTemp));
	muxnb2_1 #(.WIDTH(7)) hex1Show (.sel(selHex1Show), .in1(7'b1111111), .in0(hexTemp), .out(hex1));
	
	// Instantiates two seg7 modules
	// onesDigit:
		// recieves the separated ones digit from count
		// outputs directly to hex0, the HEX0 display on the De-1 SoC board
	// tensDigit:
		// recieves the separated tens digit from count
		// outputs to hexTens, which may be output to HEX1 display on the De-1 SoC board,
			// depending on above logic.
	seg7 onesDigit (.reset(reset), .count(ones), .leds(hex0));
	seg7 tensDigit (.reset(reset), .count({2'b00, tens}), .leds(hexTens));
	
	// Determines default behavior of the HEXs, as well as for when count is 0 and 25
		// by assigning the individual segments of each HEX.
	always_comb begin
		case (count)
			default: begin
			//          Light:    6543210 represents which segment is which by bit
							hex5 = 7'b1111111;
							hex4 = 7'b1111111;
							hex3 = 7'b1111111;
							hex2 = 7'b1111111;
							hexR = 7'b1111111;
						end
			// If count is 0, output to hex5 through hex1 should be CLEAr			
			5'b00000: begin
							hex5 = 7'b1000110; // C
							hex4 = 7'b1000111; // L
							hex3 = 7'b0000110; // E
							hex2 = 7'b0001000; // A
							hexR = 7'b0101111; // r
						 end
			// if count is 25, output to hex5 through hex1 should be fuLL
			5'b11001: begin
							hex5 = 7'b0001110; // f
							hex4 = 7'b1000001; // u
							hex3 = 7'b1000111; // L
							hex2 = 7'b1000111; // L
							hexR = 7'b1111111;
						 end
		endcase
	end
endmodule

// Test/Simulate hexControl HEX displays
module hexControl_testbench();
	// creates corresponding variables to model hexControl module
	logic  		 reset;
	logic  [4:0] count;
	logic  [6:0] hex5, hex4, hex3, hex2, hex1, hex0;
	
	// initializes hexControl module for testing with name dut
	hexControl dut (.reset, .count, .hex5, .hex4, .hex3, .hex2, .hex1, .hex0);
	
// Set up the inputs to the design
// count starts at 0 and goes to 30, where the HEX segments should change
	// with response to count to altogether display a number on the De-1 SoC board.
// Should display values representing CLEAr when count is 0
// and values representing fuLL when count is 25
// Should not update beyond 0 or 25.
	integer i;
	initial begin
		reset <= 1'b1;
		reset<= 1'b0;
		for (i=0; i < 30; i++) begin
			count <= i; #10;
		end
	$stop; // End the simulation.
	end
endmodule 