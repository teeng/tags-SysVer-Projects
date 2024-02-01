/*
Lab 2 Task 1

This module controls a single HEX display on the DE-1 SoC board containing seven LED segments
than can be individually on or turned off. Segments are active LOW.
Output on the HEX display is in hexadecimal format, so values range from 0 to F.

Input:
	reset: 1b reset signal to set sensors to default behavior
	count: 4b input of what number should be represented on the HEX display,	
		with a limit of 15 (F)
	setDefault: 7b default display for the HEX if count is not a recognized value
Output:
	leds: 7 output of which segments should be individually set HIGH or LOW to represent the number
*/

`timescale 1 ps / 1 ps

module seg7 (reset, count, setDefault, leds);
	input  logic 		  reset;
	input  logic  [3:0] count;
	input  logic  [6:0] setDefault;
	output logic  [6:0] leds;
	
	// Assigns case-by-case which segments should be on or off depending on count, which
		// has a limit of 15 (F)
	always_comb begin
		case (count)
		//          Light:  6543210 represents which segment is which by bit
		4'b0000: leds = ~7'b0111111; // 0
		4'b0001: leds = ~7'b0000110; // 1
		4'b0010: leds = ~7'b1011011; // 2
		4'b0011: leds = ~7'b1001111; // 3
		4'b0100: leds = ~7'b1100110; // 4
		4'b0101: leds = ~7'b1101101; // 5
		4'b0110: leds = ~7'b1111101; // 6
		4'b0111: leds = ~7'b0000111; // 7
		4'b1000: leds = ~7'b1111111; // 8
		4'b1001: leds = ~7'b1101111; // 9
		4'b1010: leds = 7'b0001000; // 10 // A
		4'b1011: leds = 7'b0000011; // 11 // B
		4'b1100: leds = 7'b1000110; // 12 // C
		4'b1101: leds = 7'b0100001; // 13 // D
		4'b1110: leds = 7'b0000110; // 14 // E
		4'b1111: leds = 7'b0001110; // 15 // F
		default: leds = setDefault;
		endcase
	end
endmodule


// Test/Simulate seg7 HEX displays
module seg7_testbench();
	// creates corresponding variables to model seg7 module
	logic 		reset;
	logic [3:0] count;
	logic [6:0] leds, setDefault;
	
	// initializes seg7 module for testing with name dut
	seg7 dut (.reset, .count, .setDefault, .leds);
	
// Set up the inputs to the design
// count starts at 0 and goes to 15, where the HEX segments should change
	// with response to count to altogether display a number on the DE-1 SoC board.
	integer i;
	initial begin
		reset <= 1'b1;
		reset<= 1'b0;
		
		setDefault <= '1;
		for (i=0; i < 16; i++) begin
			count <= i; #10;
		end
	$stop; // End the simulation.
	end
endmodule 