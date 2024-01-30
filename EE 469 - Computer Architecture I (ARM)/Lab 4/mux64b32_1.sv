/*
Constructs a 32x1 multiplexer module named mux32_1
	out is the output for the mux with type logic
	in is 32'b input for the mux with type logic
	sel is 5'b select line for the mux with type logic
	
	Timescale was a necessary addition to the module for running
		given regstim simulation file without errors.
*/

`timescale 1 ps / 1 ps

module mux64b32_1 (out, registers, readRegister);
	output logic [63:0] out;
	input  logic [31:0][63:0] registers;
	input logic [4:0] readRegister;
	
	// internal signal 64'b x 32'b registerFlip stores a flipped
		// version of data stores in registers so that the data can be loaded bitwise
		// in the mux32_1
	logic [63:0][31:0] registerFlip;
	integer j, k;
	always_comb begin
		for (j = 0; j<64; j++)
			for (k = 0; k<32; k++)
				registerFlip[j][k] = registers[k][j];
	end
	
	// Instantiates 64 32x1 muxes and outputs 64'b single output through out.
		// in is registerFlip, which will allow for 64'b to be written in each of the
		// 32 registers.
	// Select line for the mux is the 5'b readRegister signal that controls which
		// register is selected by the mux.
	genvar i;
	generate
		for(i=0; i<64; i++) begin : registerInfo
			mux32_1 m (.out(out[i]), .in(registerFlip[i][31:0]), .sel(readRegister));
		end
	endgenerate
endmodule


module mux64b32_1_testbench();
	logic [31:0][63:0] registers;
	logic [4:0] readRegister;    
	logic [63:0] out;
	
	mux64b32_1 dut (.out, .registers, .readRegister);    
   
	integer i, j;   
	initial begin
		registers <= 0;
		
		for (j=0; j<5; j++) begin
			readRegister = j; #1500;
			for(i=0; i<10; i++) begin  
				registers[j] = i; #1500;
			end
		end
		
		readRegister = 10; #1500;
					
	$stop;
	end  
endmodule 