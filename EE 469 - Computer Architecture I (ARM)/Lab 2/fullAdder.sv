/*
Constructs a full adder, which outputs the result of three bits added together
	One bit is from input A, another bit from input B, and
	the third bit from input carryIn
Sum is the sum of the three bits and
carryOut allows for further addition by passing in a value for future adders
	

	Timescale was a necessary addition to the module for running
		given alustim simulation file without errors.
*/

`timescale 1 ps / 1 ps

module fullAdder (sum, carryOut, A, B, carryIn); 
	output logic sum, carryOut;
	input logic A, B, carryIn;
	
	// logic for finding the sum
	xor #50 (sum, A, B, carryIn);
	
	// internal logic v2, v1, v0 to store logic gate outputs
	logic v2, v1, v0;
	// logic for finding the carryOut bit
	and #50 (v2, B, carryIn);
	and #50 (v1, A, carryIn);
	and #50 (v0, A, B);
	or #50 (carryOut, v2, v1, v0);
	
	
endmodule

module fullAdder_testbench();
	logic sum, carryOut;
	logic A, B, carryIn;
	
	fullAdder dut (sum, carryOut, A, B, carryIn);
	
	integer i;   
	initial begin
		for(i=0; i<8; i++) begin  
			{A, B, carryIn} = i; #1000;
		end
		
		A <= 1'b1; B <= 1'b1; carryIn <= 1'b0; #1000;
		A <= 1'b1; B <= 1'b1; carryIn <= 1'b1; #1000;
		A <= 1'b1; B <= 1'b0; carryIn <= 1'b0; #1000;
		A <= 1'b1; B <= 1'b1; carryIn <= 1'b1; #1000;

		$stop; // End the simulation
	end
endmodule