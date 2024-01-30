/*
Constructs a bitSlice that performs one of the six operations
	for one bit from inputs A, B, and carryIn
	
sel determines which of the six operations is being performed
carryOut allows for a bit to be carried into the next adder in the next bitSlice
out is the result of the operation using A, B, and carryIn

	Timescale was a necessary addition to the module for running
		given regstim simulation file without errors.
*/

`timescale 1 ps / 1 ps

module bitSlice (out, carryOut, A, B, sel, carryIn); 
	output logic out, carryOut;
	input logic A, B, carryIn;
	input logic [2:0] sel;
	
	// internal logic notB and sum stores logic gate outputs
	logic notB, sum;
	not #50 (notB, B);
	
	// internal logic Bsign stores whether B is negative or not, 1 if it is.
	logic Bsign;
	// instantiated 2x1 mux controls the sign bit for input B, making the instantiated fullAdder
		// below perform two's complement with input Bsign, which is used for subtracting B from A.
	mux2_1 subB (.out(Bsign), .in({notB, B}), .sel(sel[0]));
	fullAdder fa (.sum(sum), .carryOut(carryOut), .A(A), .B(Bsign), .carryIn(carryIn));
	
	// internal logic addOp, subOp, andOp, orOp, xorOp store the outputs for each of the six operations
	logic addOp, subOp, andOp, orOp, xorOp;
	// both addOp and subOp are controlled by the full adder output, sum, since it controls both
		// adding and subtracting
	assign addOp = sum;
	assign subOp = sum;
	
	// logic gates determining or, and, xor between the A and B bit
	or #50 (orOp, A, B);
	and #50 (andOp, A, B);
	xor #50 (xorOp, A, B);
	
	// 8x1 mux outputs the result for whiever operation was chosen, as determined by sel
	mux8_1 outBit (.out(out), .in({1'b0, xorOp, orOp, andOp, subOp, addOp, 1'b0, B}), .sel(sel));
	
	
endmodule

module bitSlice_testbench();
	logic out, carryOut, carryIn;
	logic A, B;
	logic [2:0] sel;
	
	bitSlice dut (out, carryOut, A, B, sel, carryIn);
	
	integer i, j;   
	initial begin
		for(j=0; j<8; j++) begin
			sel = j;
			for(i=0; i<8; i++) begin  
				{A, B, carryIn} = i; #2000;
			end
		end
		$stop; // End the simulation
	end
endmodule