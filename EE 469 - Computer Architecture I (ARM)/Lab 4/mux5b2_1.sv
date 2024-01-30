/*
Constructs a 5 bit 2_1 multiplexer module named mux5b2_1
	out is the 5b output for the mux with type logic
	in is 5'b input for the mux with type logic
	sel is 1'b select line for the mux with type logic
	
	Timescale was a necessary addition to the module for running
		given regstim simulation file without errors.
*/

`timescale 1 ps / 1 ps

module mux5b2_1 (out, regChoice1, regChoice0, sel);
	output logic [4:0] out;
	input  logic [4:0] regChoice1, regChoice0;
	input logic sel;
	
	// Instantiates 5 2x1 muxes and outputs 5'b single output through out.
		// in is regChoices, being the two registers to choose from
	// Select line for the mux is the 1'b sel signal that controls which
		// register is selected by the mux.
		
	genvar i;
	generate
		for(i=0; i<5; i++) begin : reg2Location
			mux2_1 m (.out(out[i]), .in({regChoice1[i], regChoice0[i]}), .sel(sel));
		end
	endgenerate
endmodule


module mux5b2_1_testbench();
	logic [4:0] out;
	logic [4:0] regChoice1, regChoice0;
	logic sel;
	
	mux5b2_1 dut (.out, .regChoice1, .regChoice0, .sel);    
   
	integer i, j;   
	initial begin
		{regChoice1, regChoice0} <= 0;
		
		sel = 1'b0; #1500;
		for(i=0; i<32; i++) begin  
			regChoice1 = i; #1500;
		end
		
		sel = 1'b1; #1500;
		for(i=0; i<10; i++) begin  
			regChoice1 = i; #1500;
		end
		
		sel = 1'b0; #1500;
		for(i=0; i<10; i++) begin  
			regChoice1 = i; #1500;
		end
							
	$stop;
	end  
endmodule 