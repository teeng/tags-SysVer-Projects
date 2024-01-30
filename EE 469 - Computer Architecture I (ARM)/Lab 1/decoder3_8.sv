/*
Constructs a 3:8 decoder to choose between which of 8 outputs should be HIGH
	registers[7:0] are the 8 different outputs that may be set to HIGH
	enableWrite is a 1'b control for the decoder that will set all outputs to 0
		and therefore disable the decoder
	writeReg[2:0] is the 3'b select line for choosing which of the 8
		outputs should be HIGH
	
	Timescale was a necessary addition to the module for running
		given regstim simulation file without errors.
*/

`timescale 1 ps / 1 ps

module decoder3_8 (registers, enableWrite, writeReg); 
	output [7:0] registers;
	input enableWrite;
	input [2:0] writeReg;
	
	// internal logic i2, i1, i0 for storing each bit inverse of writeReg
		// and are used for logic gates composing a 3:8 decoder,
		// alongside corresponding noninverted bits of writeReg.
	logic i2, i1, i0;
	not #50 (i2, writeReg[2]);
	not #50 (i1, writeReg[1]);
	not #50 (i0, writeReg[0]);
	
	// All AND logic gates are also controlled by enableWrite, which will set
		// the output to LOW if the decoder is disabled
	// Will determine which of the output register bits will be set to HIGH
		// if enableWrite is also HIGH.
	and #50 (registers[0], i2, i1, i0, enableWrite);
	and #50 (registers[1], i2, i1, writeReg[0], enableWrite);
	and #50 (registers[2], i2, writeReg[1], i0, enableWrite);
	and #50 (registers[3], i2, writeReg[1], writeReg[0], enableWrite);
	and #50 (registers[4], writeReg[2], i1, i0, enableWrite);
	and #50 (registers[5], writeReg[2], i1, writeReg[0], enableWrite);
	and #50 (registers[6], writeReg[2], writeReg[1], i0, enableWrite);
	and #50 (registers[7], writeReg[2], writeReg[1], writeReg[0], enableWrite);
endmodule

module decoder3_8_testbench();
	// creates corresponding variables to model decoderTwoIn module
	logic [7:0] registers;
	logic enableWrite;
	logic [2:0] writeReg;
	
	// initializes decoderTwoIn module for testing with name dut
	decoder3_8 dut (registers, enableWrite, writeReg);


	// Simulation sends the state machine into all combinations of inputs first
	integer i;   
	initial begin
		enableWrite <= 1;
		for(i=0; i<8; i++) begin  
			writeReg <= i; #1000;
		end
		
		
		enableWrite <= 0;		
		for(i=0; i<8; i++) begin  
			writeReg <= i; #1000;
		end

		$stop; // End the simulation
	end
endmodule