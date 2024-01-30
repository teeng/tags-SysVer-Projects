/*
Constructs a 4x1 multiplexer module named mux4_1
	out is the output for the mux with type logic
	in is 4'b input for the mux with type logic
	sel is 2'b select line for the mux with type logic
	
	Timescale was a necessary addition to the module for running
		given regstim simulation file without errors.
*/
`timescale 1 ps / 1 ps

module mux4_1(out, in, sel);
	output logic out;
	input  logic [3:0] in;
	input logic [1:0] sel;
	
	// internal logic 2'b v is to store
		// results of two of the three 2x1 muxes needed to determine the final
		// 4x1 mux output
	logic  [1:0] v;
	
	// instantiates three 2x1 mux2_1 named m2, m1, m0.
	// m0 and m1 both have outputs to the internal signals v0 and v1,
		// where the 2'b combined result is used in a 3rd mux2_1, m0.
	// m2 and m1 are controlled by the 0th bit from the select line, sel
	// m0 uses the 1st bit from the select line, sel, with output out for the mux4_1 module.
	mux2_1 m2 (.out(v[0]),  .in(in[1:0]), .sel(sel[0]));   
	mux2_1 m1 (.out(v[1]),  .in(in[3:2]), .sel(sel[0]));   
	mux2_1 m0 (.out(out), .in(v),  .sel(sel[1]));   
endmodule   


module mux4_1_testbench();
	logic [3:0] in;
	logic [1:0] sel;    
	logic  out;
	
	mux4_1 dut (.out, .in, .sel);
	
	integer i;   
	initial begin  
		for(i=0; i<64; i++) begin  
			{sel, in} = i; #1000;   
		end
	$stop;
	end  
endmodule 