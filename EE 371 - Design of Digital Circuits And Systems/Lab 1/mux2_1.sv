/*
Lab 1

Constructs a 2x1 multiplexer module named mux2_1
Inputs:
	sel = 1b signal for which of the two options to select
	in = 2b signal, each bit represents an option
Output:
	out = 1b signal, which is whichever of the bits from in that was chosen
*/

module mux2_1 (sel, in, out);
	output logic out;
	input logic [1:0] in;
	input logic sel;
	
	// internal logic to store results of logic gates that construct the mux
	logic notSel, b1, b0;
	
	// result of logic gates is that when sel is 0: out is equal to the value of the 0th input.
		// And when sel is 1: out is equal to the value of the 1st input.
	not (notSel, sel);
	and (b1, in[1], sel);
	and (b0, in[0], notSel);	
	or (out, b1, b0);
	
endmodule


// Test/Simulate mux2_1 for outputs
module mux2_1_testbench();
	// creates corresponding variables to model mux2_1 module
	logic out;
	logic [1:0] in;
	logic sel;
	
	// initializes seg7 module for testing with name dut
	mux2_1 dut (.sel, .in, .out);
	
	integer i;
	initial begin
		// sel and in together are three bits, with a decimal value limit of eight
		// Therefore, uses a for loop to run through every combination of sel and in
			// with a time delay of 10 units in simualtion
		for (i=0; i<8; i++) begin
			{sel, in} = i; #10;
		end
	$stop;
	end
endmodule
