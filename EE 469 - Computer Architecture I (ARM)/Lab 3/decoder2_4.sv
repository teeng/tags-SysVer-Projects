/*
Constructs a 2:4 decoder to choose between which of 4 outputs should be HIGH
	registers[3:0] are the 4 different outputs that may be set to HIGH
	enableWrite is a 1'b control for the decoder that will set all outputs to 0
		and therefore disable the decoder
	writeReg[1:0] is the 2'b select line for choosing which of the 4
		outputs should be HIGH
	
	Timescale was a necessary addition to the module for running
		given regstim simulation file without errors.
*/

`timescale 1 ps / 1 ps

module decoder2_4 (decoderEnable, enableWrite, writeReg); 
	output [3:0] decoderEnable;
	input enableWrite;
	input [1:0] writeReg;
	
	// internal logic i1, i0 for storing each bit inverse of writeReg
		// and are used for logic gates composing a 3:8 decoder,
		// alongside corresponding noninverted bits of writeReg.
	logic i1, i0;
	not #50 (i1, writeReg[1]);
	not #50 (i0, writeReg[0]);

	// All AND logic gates are also controlled by enableWrite, which will set
		// the output to LOW if the decoder is disabled
	// Will determine which of the output register bits will be set to HIGH
		// if enableWrite is also HIGH.
	and #50 (decoderEnable[0], i1, i0, enableWrite);
	and #50 (decoderEnable[1], i1, writeReg[0], enableWrite);
	and #50 (decoderEnable[2], writeReg[1], i0, enableWrite);
	and #50 (decoderEnable[3], writeReg[1], writeReg[0], enableWrite);
endmodule

module decoder2_4_testbench();
	// creates corresponding variables to model decoderTwoIn module
	logic [3:0] decoderEnable;
	logic [1:0] writeReg;
	logic enableWrite;
	
	// initializes decoderTwoIn module for testing with name dut
	decoder2_4 dut (decoderEnable, enableWrite, writeReg);
	

// Simulation sends the state machine into all combinations of inputs first
	integer i;   
	initial begin
		enableWrite <= 1;
		for(i=0; i<4; i++) begin  
			writeReg <= i; #1000;
		end
		
		
		enableWrite <= 0;		
		for(i=0; i<4; i++) begin  
			writeReg <= i; #1000;
		end

		$stop; // End the simulation
	end
endmodule