/*
Lab 6

This module controls the six HEX displays on the De-1 SoC board,
displaying both the count and whether the parking lot is full or clear
Input:
	reset: 1b reset signal to set sensors to default behavior
	count: 5b signal representing the number of cars currently in the parking lot
Outputs:
	hex5 through hex0: 7b signal each for which of the segments should be lit for each of the hex displays
*/
module hexControl (reset, full, dayEnd, hour, rushEnd, rushStart, rdAddr, rdData, spaceLeft,
						 hex5, hex4, hex3, hex2, hex1, hex0);
	input logic reset, full, dayEnd;
	input logic [3:0] hour, rushEnd, rushStart, rdAddr, rdData;
	input logic [1:0] spaceLeft;
	output logic  [6:0] hex5, hex4, hex3, hex2, hex1, hex0;
	
	
	logic [6:0] hex5Temp, hex4Temp, hex3Temp, hex2Temp, hex1Temp, hex0Temp;
	
	
	always_comb begin
		if (full) begin
			hex5 = hex5Temp;
			hex4 = 7'b1111111; // empty
			hex3 = 7'b0001110; // F
			hex2 = 7'b1000001; // U
			hex1 = 7'b1000111; // L
			hex0 = 7'b1000111; // L
		end else if (!full && !dayEnd) begin
			hex5 = hex5Temp;
			hex4 = 7'b1111111; // empty
			hex3 = 7'b1111111; // empty
			hex2 = 7'b1111111; // empty
			hex1 = 7'b1111111; // empty
			hex0 = hex0Temp;
		end else if (!full && dayEnd) begin
			hex5 = 7'b1111111; // empty
			
			if (!rushStart && !rushEnd) begin
				hex4 = 7'b0111111;
				hex3 = 7'b0111111;
			end else begin
				hex4 = hex4Temp;
				hex3 = hex3Temp;
			end
			
			hex2 = hex2Temp;
			hex1 = hex1Temp;
			hex0 = 7'b1111111; // empty
		end else begin
			hex5 = 7'b1111111; // empty
			hex4 = 7'b1111111; // empty
			hex3 = 7'b1111111; // empty
			hex2 = 7'b1111111; // empty
			hex1 = 7'b1111111; // empty
			hex0 = 7'b1111111; // empty
		end
	end
	
	
	// HEX Display control
	seg7 curr_hours (.reset(reset), .count(hour), .setDefault(7'b1111111), .leds(hex5Temp));
	seg7 rush_end (.reset(reset), .count(rushEnd), .setDefault(7'b1111111), .leds(hex4Temp));
	seg7 rush_start (.reset(reset), .count(rushStart), .setDefault(7'b1111111), .leds(hex3Temp));
	seg7 ram_addr (.reset(reset), .count(rdAddr), .setDefault(7'b1111111), .leds(hex2Temp));
	seg7 ram_data (.reset(reset), .count(rdData), .setDefault(7'b1111111), .leds(hex1Temp));
	seg7 spaces_left (.reset(reset), .count({2'b0, spaceLeft}), .setDefault(7'b1111111), .leds(hex0Temp));
	
	
endmodule

// Test/Simulate hexControl HEX displays
module hexControl_testbench();
	// creates corresponding variables to model hexControl module
	logic  		 reset, full, dayEnd;
	logic [4:0] hour, rushEnd, rushStart, rdAddr, rdData;
	logic [1:0] spaceLeft;
	logic [6:0] hex5, hex4, hex3, hex2, hex1, hex0;
	
	// initializes hexControl module for testing with name dut
	hexControl dut (.*);
	
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
		for (i=0; i < 8; i++) begin
			hour <= i; rushEnd <= i; rushStart <= i; rdAddr <= i; rdData <= i;
			spaceLeft <= i % 3; #10;
		end
	$stop; // End the simulation.
	end
endmodule 