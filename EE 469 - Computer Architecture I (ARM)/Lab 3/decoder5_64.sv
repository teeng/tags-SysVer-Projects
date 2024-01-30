/*
Constructs a 5:64 decoder to choose between which of 64 outputs should be HIGH
	registers[31:0] are the 8 different outputs that may be set to HIGH
	enableWrite is a 1'b control for the decoder that will set all outputs to 0
		and therefore disable the decoder
	writeReg[2:0] is the 3'b select line for choosing which of the 8
		outputs should be HIGH
	
	Timescale was a necessary addition to the module for running
		given regstim simulation file without errors.
*/

`timescale 1 ns / 1 ps
module decoder5_64 (regChosen, enableWrite, writeReg); 
	output [31:0] regChosen;
	input enableWrite;
	input [4:0] writeReg;
	
	// writeReg has val 0-32. go to it.
	// if 32, reg set to 0
	logic [3:0] decoderEnable;
	
	decoder2_4 controlEnable (.decoderEnable(decoderEnable[3:0]), .enableWrite(enableWrite), .writeReg(writeReg[4:3]));
	
	// TODO make 32nd reg = 0
	decoder3_8 d0 (.registers(regChosen[7:0]), .enableWrite(decoderEnable[0]), .writeReg(writeReg[2:0]));
	decoder3_8 d1 (.registers(regChosen[15:8]), .enableWrite(decoderEnable[1]), .writeReg(writeReg[2:0]));
	decoder3_8 d2 (.registers(regChosen[23:16]), .enableWrite(decoderEnable[2]), .writeReg(writeReg[2:0]));
	decoder3_8 d3 (.registers(regChosen[31:24]), .enableWrite(decoderEnable[3]), .writeReg(writeReg[2:0]));
		

endmodule

module decoder5_64_testbench();
	// creates corresponding variables to model decoderTwoIn module
	logic [31:0] regChosen;
	logic enableWrite;
	logic [4:0] writeReg;
	
	// initializes decoderTwoIn module for testing with name dut
	decoder5_64 dut (regChosen, enableWrite, writeReg);
	

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