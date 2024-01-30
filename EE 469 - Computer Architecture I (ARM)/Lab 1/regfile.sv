/*
Constructs a register file with 32 available registers
	ReadData1 is a 64'b output reading from a register
	ReadData2 is a 64'b output reading from a register
	WriteData is the 64'b data to write into a register, with the exception of register 32,
		which is always set to 0
	ReadRegister1 chooses one of the 32 registers to read
	ReadRegister2 chooses one of the 32 registers to read
	RegWrite enables the ability to write into a register
	clk is the clock used for controlling input and output timing

	Timescale was a necessary addition to the module for running
		given regstim simulation file without errors.
*/

`timescale 1 ps / 1 ps

module regfile (ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2, WriteRegister, RegWrite, clk);  
	output logic [63:0] ReadData1, ReadData2;	
	input logic [4:0] ReadRegister1, ReadRegister2, WriteRegister;
	input logic [63:0] WriteData;
	input logic RegWrite, clk;
	
	
	// Internal 32'b regChosen stores the result of the 5x32 decoder, which sets one of its 32
		// outputs high depending on which register should be sent data and enabled write.
	// Internal 32'b x 64'b regData stores the 64'b information in each register, which there
		// are 32 of.
	logic [31:0] regChosen;
	logic [31:0][63:0] regData;
	
	// Instantiated decoder5_32 is a decoder with 32 outputs and a 5'b select line, controled by WriteRegister
	// The decoder is enabled with RegWrite signal.
	// Outputs whichever of the 32 registers should be enabled for write, which will recieve a single bit
		// HIGH with the same index as the register.
	decoder5_32 decoder (.regChosen(regChosen), .enableWrite(RegWrite), .writeReg(WriteRegister));
	
	// 32nd register (index 31) is always set to 0
	assign regData[31][63:0] = 64'b0;
		
	// Instantiates 32 D_FF64, representing the registers and storing 64'b with data from WriteData, and output to regData,
		// which stores all 64'b info in all 32 registers.
	genvar i;
	generate
		for(i=0; i<31; i++) begin : registers
			D_FF64 oneReg (.q(regData[i][63:0]), .d(WriteData), .writeEnable(regChosen[i]), .clk(clk));
		end
	endgenerate
	
	// Instantiates two mux64b32_1, 32x1 muxes that output the 64'b data from a selected register
		// selected with ReadRegister1 or 2, respective to mux1 and mux2. The registers are from regData,
		// which are the saved 32 registers with 64'b data that contains written data
	mux64b32_1 mux1 (.out(ReadData1), .registers(regData), .readRegister(ReadRegister1));
	mux64b32_1 mux2 (.out(ReadData2), .registers(regData), .readRegister(ReadRegister2));

	
endmodule


// Test bench for Register file
`timescale 1ns/10ps

module regstim(); 		

	parameter ClockDelay = 5000;

	logic	[4:0] 	ReadRegister1, ReadRegister2, WriteRegister;
	logic [63:0]	WriteData;
	logic 			RegWrite, clk;
	logic [63:0]	ReadData1, ReadData2;

	integer i;

	// Your register file MUST be named "regfile".
	// Also you must make sure that the port declarations
	// match up with the module instance in this stimulus file.
	regfile dut (.ReadData1, .ReadData2, .WriteData, 
					 .ReadRegister1, .ReadRegister2, .WriteRegister,
					 .RegWrite, .clk);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end

	initial begin
		// Try to write the value 0xA0 into register 31.
		// Register 31 should always be at the value of 0.
		RegWrite <= 5'd0;
		ReadRegister1 <= 5'd0;
		ReadRegister2 <= 5'd0;
		WriteRegister <= 5'd31;
		WriteData <= 64'h00000000000000A0;
		@(posedge clk);
		
		$display("%t Attempting overwrite of register 31, which should always be 0", $time);
		RegWrite <= 1;
		@(posedge clk);

		// Write a value into each  register.
		$display("%t Writing pattern to all registers.", $time);
		for (i=0; i<31; i=i+1) begin
			RegWrite <= 0;
			ReadRegister1 <= i-1;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= i*64'h0000010204080001;
			@(posedge clk);
			
			RegWrite <= 1;
			@(posedge clk);
		end

		// Go back and verify that the registers
		// retained the data.
		$display("%t Checking pattern.", $time);
		for (i=0; i<32; i=i+1) begin
			RegWrite <= 0;
			ReadRegister1 <= i-1;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= i*64'h0000000000000100+i;
			@(posedge clk);
		end
		$stop;
	end
endmodule
