/*
Constructs a 2x1 multiplexer module named mux2_1
	out is the output for the mux with type logic
	in is 2'b input for the mux with type logic
	sel is 1'b select line for the mux with type logic

	Timescale was a necessary addition to the module for running
		given alustim simulation file without errors.
*/
`timescale 1 ps / 1 ps

module mux2_1 (out, in, sel);
	output logic out;
	input logic [1:0] in;
	input logic sel;
	
	// internal logic notSel, b1, b0 are to store
		// results of logic gates that construct the mux
	logic notSel, b1, b0;
	
	// result of logic gates is that when sel is 0,
		// out is equal to the value of the 0th input.
		// And when sel is 1,
		// out is equal to the value of the 1st input.
	not #50 (notSel, sel);
	and #50 (b1, in[1], sel);
	and #50 (b0, in[0], notSel);	
	or #50 (out, b1, b0);
	
endmodule


module mux2_1_testbench();
	logic out;
	logic [1:0] in;
	logic sel;

	mux2_1 dut (.out, .in, .sel);
	
	integer i;
	initial begin
		for (i=0; i<8; i++) begin
			{sel, in} = i; #400;
		end
	$stop;
	end
endmodule
