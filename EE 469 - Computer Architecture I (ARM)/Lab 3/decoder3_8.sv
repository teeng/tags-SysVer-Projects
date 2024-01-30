/*
Constructs a 3:8 decoder to choose between which of 8 outputs should be HIGH
	pickFunction[7:0] are the 8 different outputs that may be set to HIGH
	enableWrite is a 1'b control for the decoder that will set all outputs to 0
		and therefore disable the decoder
	ALUCtrl[2:0] is the 3'b select line for choosing which of the 8
		outputs should be HIGH
	
	Timescale was a necessary addition to the module for running
		given regstim simulation file without errors.
*/

`timescale 1 ps / 1 ps

module decoder3_8 (pickFunction, ALUCtrl); 
	output logic [7:0] pickFunction;
	input logic [2:0] ALUCtrl;
	
	// internal logic i2, i1, i0 for storing each bit inverse of ALUCtrl
		// and are used for logic gates composing a 3:8 decoder,
		// alongside corresponding noninverted bits of ALUCtrl.
	logic i2, i1, i0;
	not #50 (i2, ALUCtrl[2]);
	not #50 (i1, ALUCtrl[1]);
	not #50 (i0, ALUCtrl[0]);
	
	// All AND logic gates are also controlled by enableWrite, which will set
		// the output to LOW if the decoder is disabled
	// Will determine which of the output register bits will be set to HIGH
		// if enableWrite is also HIGH.
	and #50 (pickFunction[0], i2, i1, i0);
	and #50 (pickFunction[1], i2, i1, ALUCtrl[0]);
	and #50 (pickFunction[2], i2, ALUCtrl[1], i0);
	and #50 (pickFunction[3], i2, ALUCtrl[1], ALUCtrl[0]);
	and #50 (pickFunction[4], ALUCtrl[2], i1, i0);
	and #50 (pickFunction[5], ALUCtrl[2], i1, ALUCtrl[0]);
	and #50 (pickFunction[6], ALUCtrl[2], ALUCtrl[1], i0);
	and #50 (pickFunction[7], ALUCtrl[2], ALUCtrl[1], ALUCtrl[0]);
endmodule

module decoder3_8_testbench();
	// creates corresponding variables to model decoderTwoIn module
	logic [7:0] pickFunction;
	logic enableWrite;
	logic [2:0] ALUCtrl;
	
	// initializes decoderTwoIn module for testing with name dut
	decoder3_8 dut (pickFunction, ALUCtrl);


	// Simulation sends the state machine into all combinations of inputs first
	integer i;   
	initial begin
		for(i=0; i<8; i++) begin  
			ALUCtrl <= i; #1000;
		end
		
	
		for(i=0; i<8; i++) begin  
			ALUCtrl <= i; #1000;
		end

		$stop; // End the simulation
	end
endmodule