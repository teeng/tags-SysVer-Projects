/*
Constructs a 2x1 multiplexer module named mux64b2_1
	out is the output for the mux with type logic of 64b
	i1 is the 1'b 1st input for the mux with type logic
	i0 is the 1'b 0th input for the mux with type logic
	sel is the 1'b select line for the mux with type logic
	
	Timescale was a necessary addition to the module for running
		given regstim simulation file without errors.
*/

`timescale 1 ps / 1 ps

module mux64b2_1 (out, i1, i0, sel);
	output logic [63:0] out;
	input  logic [63:0] i1, i0;
	input logic sel;
	
	// Instantiates 64 2x1 muxes and outputs 64'b single output through out.
		// in is regChoices, being the two registers to choose from
	// Select line for the mux is the 1'b Reg2Loc signal that controls which
		// register is selected by the mux.
		
	genvar i;
	generate
		for(i=0; i<64; i++) begin : choose64b
			mux2_1 m (.out(out[i]), .in({i1[i], i0[i]}), .sel(sel));
		end
	endgenerate
endmodule


module mux64b2_1_testbench();
	logic [63:0] out;
	logic [63:0] i1, i0;
	logic sel;
	
	mux64b2_1 dut (.out, .i1, .i0, .sel);    
   
	integer i, j;   
	initial begin
		{i1, i0} <= 0;
		
		sel = 1'b0; #1500;
		for(i=0; i<32; i++) begin  
			i1 = i; #1500;
		end
		
		sel = 1'b1; #1500;
		for(i=0; i<10; i++) begin  
			i1 = i; #1500;
		end
		
		sel = 1'b0; #1500;
		for(i=0; i<10; i++) begin  
			i0 = i; #1500;
		end
							
	$stop;
	end  
endmodule 