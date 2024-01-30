

`timescale 1 ps / 1 ps

module slice_64b (out, carryOut, A, B, sel); 
	output logic [63:0] out, carryOut;
	input logic [63:0] A, B;
	input logic [1:0] sel;
	
	// from ALU Control 2, 1, 0
	// use {2, 0} as sel for this
	

	
	bitSlice first (.out(out[0]), .carryOut(carryOut[0]), .A(A[0]), .B(B[0]), .carryIn(sel[0]), .sel(sel[1:0]));
	
	genvar i;
	generate
		for(i=1; i<64; i++) begin : eachSlice
			bitSlice m (.out(out[i]), .carryOut(carryOut[i]), .A(A[i]), .B(B[i]), .carryIn(carryOut[i-1]), .sel({sel[1], carryOut[i-1]}));
		end
	endgenerate
	
endmodule

module slice_64b_testbench();
	// creates corresponding variables to model decoderTwoIn module
	logic [63:0] out, carryOut;
	logic [63:0] A, B;
	logic [1:0] sel;
	
	// initializes decoderTwoIn module for testing with name dut
	slice_64b dut (out, carryOut, A, B, sel);
	

// Simulation sends the state machine into all combinations of inputs first
	integer i, j;   
	initial begin
		for(j=0; j<4; j++) begin
			sel = j;
			A = 20; B = 40; #10000;
			A = 1; B = 1; #10000;
			A = 5; B = 6; #10000;
		end
		

		$stop; // End the simulation
	end
endmodule