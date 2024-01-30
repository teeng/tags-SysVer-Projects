/*
Lab 2 Task 1

Top-level module DE1_SoC that defines the I/Os for the DE-1 SoC board
DE-1 SoC board was connected virtually in Labsland, with a breadboard
containing three switches and two LEDs connected to the GPIO_0 pins

Parameters:
	HEX0 through HEX5: Six total HEX displays on the DE-1 SoC board that each contain
		seven LEDR segments (and therefore size 7b each), which can be individually set HIGH or LOW.
		Segments are active LOW.
	SW: Ten total switches on the DE-1 SoC board each represented by one bit, and therefore SW is a
		10b bus of which switches are HIGH or LOW.
	KEY: Four total pushbuttons on the DE-1 SoC board each represented by one bit, and therefore KEY is a 
		4b bus of which buttons are being pressed. KEY is active LOW.
		
This module is the overall controller to store input data into a 32x4 memory, meaning
	there are 32 available registers to store data, with a 4b limit to representing each word of data.
Data is input into a desired address using switches on the De-1 SoC board, and a keypress represents
	one clock cycle. Therefore, to read the data back from the memory, another keypress is required.
When not writing, data can be read from a specified address at a keypress.
*/

`timescale 1 ps / 1 ps

module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, SW, KEY);
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	input  logic [9:0] SW;
	input  logic [3:0] KEY;
	
	//====CONTROL SIGNALS====
	// defining internal signals
	logic clk, write, enableWrite;
	logic [4:0] addr, addrSend;
	logic [3:0] dataIn, dataInSend, dataOut, dataOutSend;
	
	assign clk = ~KEY[0]; // clock controlling timing is set to a keypress
	assign enableWrite = write && SW[9]; // enableWrite ensures writing only on clockedge and when intended
	assign addr = SW[8:4]; // Address in ram specified by switches 8 through 4
	assign dataIn = SW[3:0]; // Data to write into ram specified by switches 3 through 0
	logic [31:0][3:0] memArray; // Storage array of size 32x4
	
	// At every positive clockedge, save whether data should be written or not,
		// the address represented by the switches, and the input data represented by the switches
	// These signals are later sent to a register to be saved into memory
	always_ff @(posedge clk) begin
		write <= SW[9];
		addrSend <= addr;
		dataInSend <= dataIn;
	end
		
	// Instantiated decoder module regChooser picks which of 32 registers in the memory should be written to
	// enableWrite allows a register to be written to
	// addrSend is the 5b address of the register to write to, picking between 0 to 32
	// writeToReg is a 32b bus that is either all 0s or has a single bit set to 1, which is the register to write to
	logic [31:0] writeToReg;
	decoder regChooser (.enableWrite(enableWrite), .sel(addrSend), .outH(writeToReg));
	
	// Instantiate register module 32 times, one for each register to represent the 32x4 memory.
	// Each register contains a four-bit word and is written to if selected by the above decoder.
		// clk is a 1b signal that controls  timing to match the system clock
		// reset is hardwired to 1b zero to never reset
		// writeEnable is a 32b bus with the bit representing each register
		// dataInSend is the 4b data to write into the register
		// memArray is for each register, and therefore represents one 4b word at each register
	genvar i;
	generate
		for(i=0; i<32; i++) begin : registers
			register oneReg (.clk(clk), .reset(1'b0), .writeEnable(writeToReg[i]), .d(dataInSend), .q(memArray[i][3:0]));
		end
	endgenerate
	
	// Read from the memory at addrSend for the 4b word
	assign dataOut = memArray[addrSend][3:0]; 
	
	// Instantiates four total seg7 modules
	// addrOnesDigit:
		// recieves the separated ones digit from addr, which is represented by 4b and outputs
		// the 7b representing which LEDs to light directly to HEX4
		// Is hardwired to never reset, and its default state is to be off.
	logic [3:0] addrOnes;
	assign addrOnes = addr % 16;
	seg7 addrOnesDigit (.reset(1'b0), .count(addrOnes), .setDefault('1), .leds(HEX4));
	// addrTensDigit:
		// recieves the separated tens digit from addr, which is represented by 4b and outputs
		// the 7b representing which LEDs to light directly to HEX5
		// Is hardwired to never reset, and its default state is to be off.
	logic [3:0] addrTens;
	assign addrTens = addr / 16;
	seg7 addrTensDigit (.reset(1'b0), .count(addrTens), .setDefault('1), .leds(HEX5));
	
	// dataInHex:
		// recieves the the 4b data to write, dataIn, and outputs the 7b representing which LEDs to light to HEX2
		// Is hardwired to never reset, and its default state is to be off.
	seg7 dataInHex (.reset(1'b0), .count(dataIn), .setDefault('1), .leds(HEX2));
	// dataOutHex:
		// recieves the the 4b data from memory, dataOut, and outputs the 7b representing which LEDs to light to HEX0
		// Is hardwired to never reset, and its default state is to display a 0.
	seg7 dataOutHex (.reset(1'b0), .count(dataOut), .setDefault(~7'b0111111), .leds(HEX0));
	
	// setting HEX3 and HEX1 to always be off.
	assign HEX3 = '1;
	assign HEX1 = '1;
endmodule


// Testbench for DE1_SoC module to verify outputs
module DE1_SoC_testbench();
	// creates corresponding variables to model DE1_SoC module
	
	logic [9:0] SW;
	logic [3:0] KEY;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	

	// initializes DE1_SoC module for testing with name dut
	DE1_SoC dut (.HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .SW, .KEY);
		
	
	// creating integer for loop
	integer i;
	initial begin
			// Should not write anything, and nothing has been initialized into
			// memory, so dataOut should be undefined, but HEX0 should show 0.
			SW[9] <= 1'b0; #100
			SW[8:4] <= 5'b0; #100
			SW[3:0] <= 4'b1; #100
			KEY[0] <= ~1'b1; #100
			KEY[0] <= ~1'b0; #100
			KEY[0] <= ~1'b1; #100
			KEY[0] <= ~1'b0; #100
			#500
			
			// Should write into address 0 a 2 on the first clock edge
			// Then dataOut and HEX0 should show a 2 on the second clock edge.
			// MemRam should also hold a 2 at address 0
			SW[9] <= 1'b1; #100
			SW[8:4] <= 5'b0; #100
			SW[3:0] <= 4'b10; #100
			KEY[0] <= ~1'b1; #100
			KEY[0] <= ~1'b0; #100
			KEY[0] <= ~1'b1; #100
			KEY[0] <= ~1'b0; #100
			#500
			
			// Should write into address 1 a 3 on the first clock edge
			// Then dataOut and HEX0 should show a 3 on the second clock edge.
			// MemRam should also hold a 3 at address 1
			SW[9] <= 1'b1; #100
			SW[8:4] <= 5'b1; #100
			SW[3:0] <= 4'b11;#100
			KEY[0] <= ~1'b1; #100
			KEY[0] <= ~1'b0; #100
			KEY[0] <= ~1'b1; #100
			KEY[0] <= ~1'b0; #100
			#500
			
			// Should not write, but read address 0.
			// dataOut and HEX0 should show a 2 on the first clock edge
			SW[9] <= 1'b0; #100
			SW[8:4] <= 5'b0; #100
			SW[3:0] <= 4'b100; #100
			KEY[0] <= ~1'b1; #100
			KEY[0] <= ~1'b0; #100
			KEY[0] <= ~1'b1; #100
			KEY[0] <= ~1'b0; #100
			#500
			
			// Writing into address 2 a 4 (from above block)
			// Then dataOut and HEX0 should show a 4 on the second clock edge.
			// MemRam should also hold a 4 at address 2
			SW[9] <= 1'b1; #100
			SW[8:4] <= 5'b10; #100
			KEY[0] <= ~1'b1; #100
			KEY[0] <= ~1'b0; #100
			KEY[0] <= ~1'b1; #100
			KEY[0] <= ~1'b0; #100
			#500
			
			// Writing into address 3 a 4 (continuing above block)
			// Then dataOut and HEX0 should show a 4 on the second clock edge.
			// MemRam should also hold a 4 at address 3
			SW[8:4] <= 5'b11; #100
			KEY[0] <= ~1'b1; #100
			KEY[0] <= ~1'b0; #100
			KEY[0] <= ~1'b1; #100
			KEY[0] <= ~1'b0; #100
			#500
			
			// Writing into address 4 a 4
			// Then dataOut and HEX0 should show a 4 on the second clock edge.
			// MemRam should also hold a 4 at address 4
			SW[8:4] <= 5'b100; #100
			KEY[0] <= ~1'b1; #100
			KEY[0] <= ~1'b0; #100
			KEY[0] <= ~1'b1; #100
			KEY[0] <= ~1'b0; #100
			#500
			
			// Writing into address 7 a 4
			// Then dataOut and HEX0 should show a 4 on the second clock edge.
			// MemRam should also hold a 4 at address 7
			SW[8:4] <= 5'b111; #100
			KEY[0] <= ~1'b1; #100
			KEY[0] <= ~1'b0; #100
			KEY[0] <= ~1'b1; #100
			KEY[0] <= ~1'b0; #100
			#500
			
			// Should not write, but read address 0.
			// dataOut and HEX0 should show a 2 on the first clock edge
			SW[9] <= 1'b0; #100
			SW[8:4] <= 5'b0; #100
			SW[3:0] <= 4'b101; #100
			KEY[0] <= ~1'b1; #100
			KEY[0] <= ~1'b0; #100
			KEY[0] <= ~1'b1; #100
			KEY[0] <= ~1'b0; #100
			#500
			
			// Should not write, but read address 3.
			// dataOut and HEX0 should show a 4 on the first clock edge
			SW[8:4] <= 5'b11; #100
			KEY[0] <= ~1'b1; #100
			KEY[0] <= ~1'b0; #100
			KEY[0] <= ~1'b1; #100
			KEY[0] <= ~1'b0; #100
			#500
			
			// Should not write, but read address 7.
			// dataOut and HEX0 should show a 4 on the first clock edge
			SW[8:4] <= 5'b111; #100
			KEY[0] <= ~1'b1; #100
			KEY[0] <= ~1'b0; #100
			KEY[0] <= ~1'b1; #100
			KEY[0] <= ~1'b0; #100
			#500
			
			// Writing into address 0 a B (11 in decimal)
			// Then dataOut and HEX0 should show a B on the second clock edge.
			// MemRam should also hold a B at address 0
			SW[9] <= 1'b1; #100
			SW[8:4] <= 5'b0; #100
			SW[3:0] <= 4'b1011; #100
			KEY[0] <= ~1'b1; #100
			KEY[0] <= ~1'b0; #100
			KEY[0] <= ~1'b1; #100
			KEY[0] <= ~1'b0; #100
			#500
	$stop;
	end
endmodule