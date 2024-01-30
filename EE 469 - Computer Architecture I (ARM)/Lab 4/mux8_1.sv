/*
Constructs a 8x1 multiplexer module named mux8_1
	out is the output for the mux with type logic
	in is 8'b input for the mux with type logic
	sel is 3'b select line for the mux with type logic
	
	Timescale was a necessary addition to the module for running
		given alustim simulation file without errors.
*/

`timescale 1 ps / 1 ps

module mux8_1(out, in, sel);
	output logic out;
	input  logic [7:0] in;
	input logic [2:0] sel;
	
	// internal logic 2'b v is to store
		// results of two of the two 4x1 muxes needed to determine the final
		// 8x1 mux output
	logic  [1:0] v;
	
	// instantiates two 4x1 mux4_1 named m2, m1.
	// m2 and m1 both have outputs to the internal signals v0 and v1,
		// where the 2'b combined result is used in a 3rd mux2_1, m0.
	// m2 and m1 are controlled by the 0th and 1st bit from the select line, sel
	// m0 uses the 3rd bit from the select line, sel, with output out for the mux8_1 module.
	mux4_1 m2 (.out(v[0]),  .i3(in[3]), .i2(in[2]), .i1(in[1]), .i0(in[0]), .sel(sel[1:0]));
	mux4_1 m1 (.out(v[1]),  .i3(in[7]), .i2(in[6]), .i1(in[5]), .i0(in[4]), .sel(sel[1:0])); 
	mux2_1 m0 (.out(out), .in(v),  .sel(sel[2]));
endmodule


module mux8_1_testbench();
	logic [7:0] in;
	logic [2:0] sel;    
	logic  out;
	
	mux8_1 dut (.out, .in, .sel);    
   
	integer i;   
	initial begin  
		for(i=0; i<8; i++) begin  
			{sel, in} = i; #1500;
		end
		
		sel <= 3'b001;
		for(i=0; i<8; i++) begin  
			in = i; #1500;
		end
		
		sel <= 3'b010;
		for(i=0; i<8; i++) begin  
			in = i; #1500;
		end
		
		sel <= 3'b011;
		for(i=0; i<8; i++) begin  
			in = i; #1500;
		end
		
	$stop;
	end  
endmodule 