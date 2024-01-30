/*
Lab 1

Constructs a variable-width 2x1 multiplexer module named muxnb2_1
Inputs:
	sel = 1b signal for which of the two options to select
	in1 = WIDTH length signal, with default WIDTH of 1b, option 1 of the 2x1 mux
	in0 = WIDTH length signal, with default WIDTH of 1b, option 0 of the 2x1 mux
Output:
	out = WIDTH length signal, with default WIDTH of 1b,
			and outputs whichever of the options was chosen by the select line
*/

module muxnb2_1 #(parameter WIDTH=2) (sel, in1, in0, out);
	output logic [WIDTH-1:0] out;
	input logic [WIDTH-1:0] in1, in0;
	input logic sel;
	
	// Instantiates WIDTH number of 2x1 muxes and outputs WIDTH length single output through out,
	// Result is that when sel is 0: out is equal to the value of the 0th input.
		// And when sel is 1: out is equal to the value of the 1st input.
	genvar i;
	generate
		for(i=0; i<WIDTH; i++) begin : bus
			mux2_1 m (.sel(sel), .in({in1[i], in0[i]}), .out(out[i]));
		end
	endgenerate
endmodule

// Test/Simulate muxnb2_1 for outputs
module muxnb2_1_testbench();
	logic [1:0] out;
	logic [1:0] in1, in0;
	logic sel;
	
	// creates corresponding variables to model muxnb2_1 module with default WIDTH,
		// so 1b length inputs and 1b length output
	muxnb2_1 dut (.sel, .in1, .in0, .out);    
   
	integer i;   
	initial begin
		// set both inputs to 0 at start
		{in1, in0} <= 0;
		
		// set sel for the 0th option. Should match in0's data
		sel = 1'b0; #10;
		for(i=0; i<4; i++) begin  
			in1 = i; #10;
		end
		
		// set sel for the 1st option. Should match in1's data
		sel = 1'b1; #10;
		for(i=0; i<4; i++) begin  
			in1 = i; #10;
		end
		
		// set sel for the 0th option. Should match in0's data
		sel = 1'b0; #10;
		for(i=0; i<4; i++) begin  
			in1 = i; #10;
		end
							
	$stop;
	end  
endmodule