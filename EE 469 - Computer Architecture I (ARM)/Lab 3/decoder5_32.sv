/*
Constructs a 5:32 decoder to choose between which of 64 outputs should be HIGH
	registers[31:0] are the 32 different outputs that may be set to HIGH
	enableWrite is a 1'b control for the decoder that will set all outputs to 0
		and therefore disable the decoder
	writeReg[4:0] is the 5'b select line for choosing which of the 32
		outputs should be HIGH
	
	Timescale was a necessary addition to the module for running
		given regstim simulation file without errors.
*/

`timescale 1 ps / 1 ps
module decoder5_32 (regChosen, enableWrite, writeReg); 
	output [31:0] regChosen;
	input enableWrite;
	input [4:0] writeReg;
	
	// internal logic decoderEnable is used by a 2:4 decoder,
		// instantiated decoder2_4 that will select which of the
		// of the four instantiated 3:8 decoders, decoder3_8, will be active at a time.
	// Each bit of decoderEnable corresponds to one decoder3_8's enable.
	// decoder2_4 is controled by the MSB of writeReg
	logic [3:0] decoderEnable;
	decoder2_4 controlEnable (.decoderEnable(decoderEnable[3:0]), .enableWrite(enableWrite), .writeReg(writeReg[4:3]));
	
	// Four instantiated 3:8 decoders, decoder3_8, altogether generate the 32'b output regChosen
		// and are enabled by each bit of decoderEnable
	// The decoders share the same 3'b of the select line, writeReg.
	decoder3_8Enabled d0 (.registers(regChosen[7:0]), .enableWrite(decoderEnable[0]), .writeReg(writeReg[2:0]));
	decoder3_8Enabled d1 (.registers(regChosen[15:8]), .enableWrite(decoderEnable[1]), .writeReg(writeReg[2:0]));
	decoder3_8Enabled d2 (.registers(regChosen[23:16]), .enableWrite(decoderEnable[2]), .writeReg(writeReg[2:0]));
	decoder3_8Enabled d3 (.registers(regChosen[31:24]), .enableWrite(decoderEnable[3]), .writeReg(writeReg[2:0]));
endmodule

module decoder5_32_testbench();
	// creates corresponding variables to model decoderTwoIn module
	logic [31:0] regChosen;
	logic enableWrite;
	logic [4:0] writeReg;
	
	// initializes decoderTwoIn module for testing with name dut
	decoder5_32 dut (regChosen, enableWrite, writeReg);
	

// Simulation sends the state machine into all combinations of inputs first
	integer i;   
	initial begin
		enableWrite <= 1; #1000
		for(i=0; i<5; i++) begin  
			writeReg <= i; #1000;
		end
		
		
		enableWrite <= 0;		
		for(i=0; i<5; i++) begin  
			writeReg <= i; #1000;
		end

		$stop; // End the simulation
	end
endmodule