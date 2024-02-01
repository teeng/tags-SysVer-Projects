// module DE1_SoC that defines the I/Os for the DE-1 SoC
// board with parameters LEDR and SW

// The LEDR parameter will be for the red LEDs on the DE-1 SoC board
// the SW parameter will be for the switches on the DE-1 SoC board 
module DE1_SoCLab3 (LEDR, SW);
	// Creates output variables LEDR[9]... LEDR[0] for the 10 red LEDs
	// on the DE-1 SoC board with type logic
	output logic [9:0]  LEDR;
	// Creates input variables SW[9]... SW[0] for the 10 switches on the
	// DE-1 SoC board with type logic
	input  logic [9:0]  SW;
	
	// internal signals, v0, v1, v2, v3 with type logic
	logic v0, v1, v2, v3;
	

	// Gate-level logic to check if a switch combination corresponds
	// to an item UPC code, if it is a discounted item,
	//	and if it is marked.
	// SW[9], SW[8], and SW[7] is the item UPC code,
	// with SW[9] for U,
	// with SW[8] for P,
	// with SW[7] for C
	// and SW[0] for whether the item is marked or not (M).
	//	High if it is marked, low if not.
	// UPC codes for items that don't exist have outputs that do not matter.
	// 
	// The output for whether the item is discounted or not goes to LEDR[9], with
	// high meaning discounted, low meaning not discounted.
	// The output for whether the item is stolen or not goes to LEDR[8], with
	// high meaning stolen, low meaning not stolen.
	
	// Gate-level logic determining whether an item is on discount or not,
	// depending on its UPC code.
	and discountUC (v0, SW[9], SW[7]);
	or discount (LEDR[9], v0, SW[8]);
	
	
	// Gate-level logic determining whether an an expensive item was stolen.
	// An expensive item (determined from its UPC code) without the mark is stolen,
	// but if it does have an mark, it is not stolen.
	// A non-expensive item without the mark is not stolen.
	// A non-expensive item with the mark will never occur, so its output for whether
	// it is stolen or not does not matter.
	nor stolenPM (v1, SW[8], SW[0]);
	not stolenC (v2, SW[7]);
	or stolenUC (v3, v2, SW[9]);
	
	and stolen (LEDR[8], v3, v1);
	
endmodule


/*
Constructs a testbench for the DE1-SoCLab3 module, testing all possible input combinations
with a for loop, and a time delay of 10 units
*/
module DE1_SoCLab3_testbench();
	// creates corresponding variabless
	// for LEDRs, and SWs, with type logic
	logic  [9:0] LEDR;
	logic  [9:0] SW; 
	
	// sets up the DE1_SoCLab3 module for testing, named as dut
	DE1_SoCLab3 dut (.LEDR, .SW);
	
	// tests every possible combination of the input signals for the DE1_SoCLab3 module,
	// with a time delay of 10 time units.
	// Following the design of the De1-SoCLab3 module, output to LEDR[9] is high if the item
	// is on discount, which would be when either P (SW[8]) or UC (SW[9] AND SW[7]) are high.
	
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
