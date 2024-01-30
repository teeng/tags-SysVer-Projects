/*
Constructs an alu with two 64'b inputs, A and B
With A and B, selects from six different operations depending on the value of cntrl
and controls four flags, negative, zero, overflow, and carry_out based on those operations.

Meaning of signals in and out of the ALU:

	Flags:
		negative: whether the result output is negative if interpreted as 2's comp.
		zero: whether the result output was a 64-bit zero.
		overflow: on an add or subtract, whether the computation overflowed if the inputs are interpreted as 2's comp.
		carry_out: on an add or subtract, whether the computation produced a carry-out.

	cntrl			Operation						Notes:
	000:			result = B						value of overflow and carry_out unimportant
	010:			result = A + B
	011:			result = A - B
	100:			result = bitwise A & B		value of overflow and carry_out unimportant
	101:			result = bitwise A | B		value of overflow and carry_out unimportant
	110:			result = bitwise A XOR B	value of overflow and carry_out unimportant
	
The output is the 64'b result of the operation between A and B and the 1'b output of the flags,
where if they are HIGH the flag is true.

	Timescale was a necessary addition to the module for running
		given alustim simulation file without errors.
*/

`timescale 1 ps / 1 ps

module alu (A, B, cntrl, result, negative, zero, overflow, carry_out, setFlag, clk); 
	input logic [63:0] A, B;
	input logic [2:0] cntrl;
	input logic setFlag, clk;
	output logic [63:0] result;
	output logic negative, zero, overflow, carry_out;
	
	// internal logic carryOut stores the carryOut bit from each bitSlice, which there are 64 of.
	logic [63:0] carryOut;
	
	// the first bitSlice instantiation requires the carryIn to be from the 0th bit of cntrl, which
		// is essential in the subtraction operation for the alu
	bitSlice first (.out(result[0]), .carryOut(carryOut[0]), .A(A[0]), .B(B[0]), .sel(cntrl), .carryIn(cntrl[0]));
	
	// generates 64 bitSlices, which each perform bitwise operations
		// the output of each bit is a single bit of the result, which is sent directly to the alu output 64'b result.
		// carryOut is from the single bit output from each adder within bitSlice, and is sent to carryOut
		// A[i] and B[i] are the corresponding single bits from the inputs A and B
		// the operation selected (sel) is determined from cntrl. The specific valid cntrl values are listed above.
		// carryIn is the bit carried in to each of the adders included in the bitSlice. For every bitSlice after the 0th
		// (which was declared above), the carry in is from the previous index of the carryOut, or bit carried in from the
		// previous adder.
	genvar i;
	generate
		for(i=1; i<64; i++) begin : eachSlice
			bitSlice m (.out(result[i]), .carryOut(carryOut[i]), .A(A[i]), .B(B[i]), .sel(cntrl), .carryIn(carryOut[i-1]));
		end
	endgenerate
	
	// the flagRegister manages all four outputs for the flags and requires the data from the carryOut and the result outputs of each
		// bitSlice.
	// setFlag input is used to determine if setFlag control signal is HIGH, meaning the flags should be set and should not change
		// until the next time they are HIGH
	setFlags flagRegister (.zFlag(zero), .oFlag(overflow), .cFlag(carry_out), .nFlag(negative), .sliceCarry(carryOut), .sliceOut(result),
								 .setFlag(setFlag), .clk(clk));
	
endmodule



// Test bench for ALU
`timescale 1ps/1ps



module alustim();

	parameter delay = 100000;

	logic		[63:0]	A, B;
	logic		[2:0]		cntrl;
	logic 				setFlag, clk;
	logic		[63:0]	result;
	logic					negative, zero, overflow, carry_out ;

	parameter ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUBTRACT=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110;
	parameter ClockDelay = 5000;

	alu dut (.A, .B, .cntrl, .result, .negative, .zero, .overflow, .carry_out, .setFlag, .clk);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);
	
	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end
	
	integer i;
	logic [63:0] test_val;
	initial begin
		setFlag <= 1'b0;
		$display("%t testing PASS_A operations", $time);
		cntrl = ALU_PASS_B;
		for (i=0; i<50; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == B && negative == B[63] && zero == (B == '0));
		end
		for (i=0; i<10; i++) begin
			A = 0; B = 0;
			#(delay);
			assert(result == B && negative == B[63] && zero == (B == '0));
		end
		
		
		$display("%t testing addition", $time);
		cntrl = ALU_ADD;
		A = 64'h0000000000000001; B = 64'h0000000000000001;
		#(delay);
		assert(result == 64'h0000000000000002 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);
		for (i=0; i<10; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == B && negative == B[63] && zero == (B == '0));
		end
		
		// check ADDS
		setFlag <= 1'b1;
		cntrl = ALU_ADD;
		A = 64'h0000000000000001; B = 64'h0000000000000001;
		#(delay);
		//assert(result == 64'h0000000000000002 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);
		for (i=0; i<10; i++) begin
			A = $random(); B = $random();
			#(delay);
			//assert(result == B && negative == B[63] && zero == (B == '0));
		end
		
		setFlag <= 1'b0;
		cntrl = ALU_SUBTRACT;
		for (i=0; i<10; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == B && negative == B[63] && zero == (B == '0));
		end
		
		cntrl = ALU_AND;
		for (i=0; i<10; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == B && negative == B[63] && zero == (B == '0));
		end
		
		cntrl = ALU_OR;
		for (i=0; i<10; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == B && negative == B[63] && zero == (B == '0));
		end
		
		cntrl = ALU_XOR;
		for (i=0; i<10; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == B && negative == B[63] && zero == (B == '0));
		end
	$stop;
	end
endmodule
