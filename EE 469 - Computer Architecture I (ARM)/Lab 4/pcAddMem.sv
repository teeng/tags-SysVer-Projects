/*
Constructs a program counter that will determine the memory address for the current and next instruction

nextAddr is the instruction directly after the current one if a branch were not to occur (nextAddr = memAddr + 4)
memAddr is the instruction to perform

destAddr is if the instruction is a branch, and what the shift address for the branch is
setPC is a control signal determining whether or not the PC should be set to a register value instead of a
	branch destination address or to the next consecutive instruciton
setPCReg is the value of the register to set the PC to if setPC is HIGH
branchCond is if the instruction is a branch and the PC needs to read the destination address for the next instruciton
clk is for stable inputs and outputs
reset will set current memAddr to 0

	Timescale was a necessary addition to the module for running
		simulation file without errors.
*/

`timescale 1 ps / 1 ps

module pcAddMem (resultMem, currMemAddr, destAddr, clk, reset);
	output logic [63:0] resultMem;
	input logic [63:0] currMemAddr, destAddr;
	input logic clk, reset;
	
	// internal logic
		// A and B are the inputs for an adder specific to the pc
		// carryOutMem contains the carry out bits for when the destination address is added to memAddr
		// resultMem stores PC + destAddr
		
	logic [63:0] A, B, carryOutMem;
	assign A = currMemAddr;
	assign B = destAddr;
	
	// 1st bit requires the carry in bit to be 0, instantiates the first bitSlice to add the first 3 bits of the
		// addMem operation (3 bits being the carry in, A[0] and B[0]
	// doing an add operation, so the select line is 3'b010 following the ALU format
	bitSlice addMem (.out(resultMem[0]), .carryOut(carryOutMem[0]), .A(A[0]), .B(B[0]), .sel(3'b010), .carryIn(1'b0));
	
	// generates 63 more bitSclices each for the total 64'b output of resultMem
	genvar i;
	generate
		for(i=1; i<64; i++) begin : eachSliceAddMem
			bitSlice addMemAll (.out(resultMem[i]), .carryOut(carryOutMem[i]), .A(A[i]), .B(B[i]), .sel(3'b010), .carryIn(carryOutMem[i-1]));
		end
	endgenerate
	
	// the final memory address is determined using muxes, which are controlled by whether a branch is taken or not, and whether
		// the PC should be set to a register value or not.
	// final memory address is output to memAddr
	//logic [63:0] memAddrTemp, memAddrFinal;
	//mux64b2_1 brOrSetPC (.out(memAddrFinal), .i1(setPC), .i0(), .sel(setPCReg));
	//D_FF64 pcDestMem (.q(outAddr), .d(resultMem), .reset(reset), .clk(clk));
endmodule


module pcAddMem_testbench();
	logic [63:0] memAddr;
	logic [63:0] destAddr, setPC;
	logic setPCReg, clk, reset;
	
	pcAddMem dut (.memAddr, .destAddr, .setPC, .setPCReg, .clk, .reset);
	
	// Set up a simulated clock to toggle (from low to high or high to low)
	// every 50 time steps
	parameter CLOCK_PERIOD=10000;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;//toggle the clock indefinitely
	end 	
	
	initial begin
		reset <= 1'b1;																											@(posedge clk);
		reset <= 1'b0; setPCReg <= 1'b0; destAddr <= {36'b0, 26'b100, 2'b00};			 	 						 repeat(5) @(posedge clk);													 repeat(5) @(posedge clk);
		destAddr <= {{36{1'b1}}, 26'b11111111111111111111111001, 2'b00};								 					 	 repeat(5) @(posedge clk);
	$stop;
	end
endmodule
