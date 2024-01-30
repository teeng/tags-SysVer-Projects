/*
Constructs a 32x1 multiplexer module named mux32_1
	out is the output for the mux with type logic
	in is 32'b input for the mux with type logic
	sel is 5'b select line for the mux with type logic
	
	Timescale was a necessary addition to the module for running
		given regstim simulation file without errors.
*/

`timescale 1 ps / 1 ps

module mux32_1(out, in, sel);
	output logic out;
	input  logic [31:0] in;
	input logic [4:0] sel;
	
	
	// internal logic v holds the outputs for individual instantiated mux16_1, two 16x1 muxes,
		// to eventually be used as a 2'b input for a final instantiated mux2_1, 2x1 mux
	logic  [1:0] v;
	
	// instantiates two 16x1 mux16_1 named m2, m1.
	// m2 and m1 both have outputs to the internal signals v[0] and v[1],
		// where the 2'b combined result is used in a 3rd mux2_1, m0.
	// m2 and m1 are controlled by the 0th to 4th bit from the select line, sel
	// m0 uses the 5th bit from the select line, sel, with output out for the mux32_1 module.
	mux16_1 m2 (.out(v[0]),  .in(in[15:0]), .sel(sel[3:0]));
	mux16_1 m1 (.out(v[1]),  .in(in[31:16]), .sel(sel[3:0])); 
	mux2_1 m0 (.out(out), .in(v),  .sel(sel[4]));
endmodule

/*
Constructs a testbench for the 4x1 multiplexer, testing 
all possible input and select line combinations
with a for loop, and a time delay of 10 units
*/
module mux32_1_testbench();
	// creates variables i00,i01, i10, i11, sel0, sel1, and out as type object
	logic [31:0] in;
	logic [4:0] sel;    
	logic  out;
	
	// sets up the mux4_1 module for testing, named as dut   
	mux32_1 dut (.out, .in, .sel);    
   
	// tests every possible combination of the six input signals for the mux4_1,
	// which is sel1, sel0, i00, i01, i10, and i11 with a for loop and time delay of 10 time units
	integer i;   
	initial begin  
		for(i=0; i<10; i++) begin  
			{sel, in} = i; #1000;
		end
		
		sel <= 5'b00010;
		for(i=0; i<10; i++) begin  
			in = i; #1000;
		end
		
		sel <= 5'b00011;
		for(i=0; i<10; i++) begin  
			in = i; #1000;
		end
		
		sel <= 5'b00100;
		for(i=0; i<10; i++) begin  
			in = i; #1000;
		end
		
	$stop;
	end  
endmodule 