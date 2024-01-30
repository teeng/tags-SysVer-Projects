/*
Lab 2 Task 1

Constructs a decoder to choose between which of WIDTH number and DEPTH sized outputs should be HIGH
	enableWrite is a 1b control for the decoder that will set all outputs to LOW
	sel is the DEPTH size select line for choosing which of the WIDTH number of outputs should be HIGH
	outH is the WIDTH number of outputs, specifying which bit should be HIGH	
*/

`timescale 1 ps / 1 ps

module decoder #(parameter WIDTH=32, parameter DEPTH=5) (enableWrite, sel, outH); 
	input logic enableWrite;
	input logic [DEPTH-1:0] sel;
	output logic [WIDTH-1:0] outH;
	
	integer i;
	always_comb begin
		// for every bit of outH, if at the bit that was selected to be HIGH,
			// and enableWrite is also HIGH, then that bit is set to HIGH
		for (i=0; i<WIDTH; i++) begin 
			if (i == sel) begin
				outH[i] = enableWrite;
			end else begin
		// otherwise, set to LOW
				outH[i] = 1'b0;
			end
		end
	end
	
endmodule

module decoder_testbench();
	// creates corresponding variables to model decoder module
	logic enableWrite;
	logic [4:0] sel;
	logic [31:0] outH;
	
	// initializes decoder module for testing with name dut
	decoder dut (.enableWrite, .sel, .outH);
	

// Simulation sends the state machine into all combinations of inputs first
	integer i;   
	initial begin
		// enableWrite is HIGH, so set bits 0 through 4 of outH to HIGH
		enableWrite <= 1; 	#1000
		for(i=0; i<5; i++) begin  
			sel <= i; 			#1000;
		end
		
		// enableWrite is LOW, so set all bits of outH to LOW
		enableWrite <= 0;		#1000;
		for(i=0; i<5; i++) begin  
			sel <= i; 			#1000;
		end

		$stop; // End the simulation
	end
endmodule