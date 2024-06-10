// module DE1_SoCLab4 that defines the I/Os for the DE-1 SoC
// board with parameters HEX0, HEX1, HEX2, HEX3, and SW

// The HEX0...HEX3 parameters will be for the 7-segment HEX display on the DE-1 SoC board
// the SW parameter will be for the switches on the DE-1 SoC board
module DE1_SoCLab4 (HEX0, HEX1, HEX2, HEX3, SW);
	// Creates output variables HEX0, HEX1, HEX2, HEX3 with type logic, each representing
	// the seven-segment HEX display on the DE-1 SoC board
	output logic [6:0] HEX0, HEX1, HEX2, HEX3;
	// Creates input variables SW[9]... SW[0] for the 10 switches on the
	// DE-1 SoC board with type logic
	input  logic [9:0]  SW;
	
	// instantiates one seg7 as m0, which controls the individual segments of the
	// HEX displays, HEX0, HEX1, HEX2, HEX3.
	// The seg7 uses the input from the 3 switches SW[9], SW[8], and SW[7]
	// to control the four output HEX displays.
	seg7 m0 (.UPC(SW[9:7]), .HEX0, .HEX1, .HEX2, .HEX3);
	
endmodule


/*
Constructs a testbench for the DE1-SoCLab4, testing all possible input combinations
with a for loop, and a time delay of 10 units
*/
module DE1_SoCLab4_testbench();
	// creates corresponding variabless
	// for HEXs, and SWs, with type logic
	logic [6:0] HEX0, HEX1, HEX2, HEX3;
	logic [9:0] SW;
	
	// sets up the DE1_SoCLab4 module for testing, named as dut
	DE1_SoCLab4 dut (.HEX0, .HEX1, .HEX2, .HEX3, .SW);
	
	// tests every possible combination of the input signals for the DE1_SoCLab4,
	// with a time delay of 10 time units.
	// Following the design of the DE1-SoCLab4 module, output to the HEXs will describe the product
	// with the item code input from the switches.
	// some input combinations will never occur, so they do not matter. This includes
	// UPC codes outside of the 6 that exist, and non-expensive items that have been marked.
	// For these combinations, the output does not matter.
	integer i;
	initial begin
		for(i = 0; i < 8; i++) begin
			SW[9:7] = i; #10;
		end
	end
endmodule
