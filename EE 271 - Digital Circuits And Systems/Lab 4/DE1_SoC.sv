// Top-level module DE1_SoC that defines the I/Os for the DE-1 SoC
// board with parameters HEX0, HEX1, HEX2, HEX3, LEDR, and SW

// The HEX0...HEX3 parameters will be for the 7-segment HEX display on the DE-1 SoC board
// The LEDR parameter will be for the red LEDs on the DE-1 SoC board
// the SW parameter will be for the switches on the DE-1 SoC board
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, LEDR, SW);
	// Creates output variables LEDR[9]... LEDR[0] for the 10 red LEDs
	// on the DE-1 SoC board with type logic
	output logic [9:0] LEDR;
	// Creates output variables HEX0... HEX3 for four of the 7-segment
	// HEX display on the DE-1 SoC board with type logic
	output logic [6:0] HEX0, HEX1, HEX2, HEX3;
	// Creates input variables SW[9]... SW[0] for the 10 switches on the
	// DE-1 SoC board with type logic	
	input logic [9:0] SW;
	
	// instantiates one DE1_SoCLab4 as d0, which controls the output HEX displays,
	// HEX0, HEX1, HEX2, HEX3 in response to the input from the switches (SW).
	// DE1_SoCLab4 controls the HEX display to describe the product
	// with the item code matching the switch combination from SW[9], SW[8], and SW[7]
	DE1_SoCLab4 d0 (.HEX0, .HEX1, .HEX2, .HEX3, .SW);
	// instantiates one DE1_SoCLab3 as d1, which controls the output LEDRs
	// in response to the input from the switches (SW).
	// DE1_SoCLab3 controls the LEDR to show if the product is discounted or stolen,
	// with LEDR[9] lighting up if the product is discounted, and LEDR[8] lighting up
	// if the product is stolen. The product is determined from the
	// item code matching the switch combination from SW[9], SW[8], and SW[7]
	DE1_SoCLab3 d1 (.LEDR, .SW);

endmodule

/*
Constructs a testbench for the DE1-SoC, testing all possible input combinations
with a for loop, and a time delay of 10 units
*/
module DE1_SoC_testbench();
	// creates corresponding variables
	// for LEDRs, HEX0, HEX1, HEX2, HEX3, and SWs, with type logic
	logic [9:0] LEDR;
	logic [6:0] HEX0, HEX1, HEX2, HEX3;
	logic [9:0] SW;
	
	// sets up the DE1_SoC module for testing, named as dut
	DE1_SoC dut (.HEX0, .HEX1, .HEX2, .HEX3, .LEDR, .SW);
	
	// tests every possible combination of the input signals for the DE1_SoC,
	// with a time delay of 10 time units.
	// Following the design of the DE1-SoC module, output to LEDR[9] is high if the item
	// is on discount, which would be when either P (SW[8]) or UC (SW[9] AND SW[7]) are high.
	// Output to LEDR[8] is high if the item is stolen, as determined if it is expensive and
	// is lacking a marker (SW[0]).
	// Additionally, the HEX display will describe the product, in text or picture form
	// using all or few of four HEX displays.
	
	// some input combinations will never occur, so they do not matter. This includes
	// UPC codes outside of the 6 that exist, and non-expensive items that have been marked.
	// For these combinations, the output does not matter.
	integer i;
	initial begin
		for(i = 0; i < 16; i++) begin
			{SW[9:7], SW[0]} = i; #10;
		end
	end
endmodule