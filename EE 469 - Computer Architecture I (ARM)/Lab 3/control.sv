/*controlUnit determines output for each of the control signals.
	If reset is high, all control signals are set to LOW, meaning cpu should perform no operations until
		PC has updated to the next instruction
	opcode is the instruction's first 11 bits, which will ultimately control the output control signals
	immediate is for ADDI instructions, where the immediate value in the instruction should be retrieved
	reg2Loc is for where in the instruction the second register is
	setPCReg is whether the PC should be set to a register value instead of updating through other means
	link is whether to also record the next instruction address when branching (for BL instruction)
	uncondBranch is for the PC to take a branch without any conditions
	cbBranch is for the PC to take a branch with a specified condition (LT, less than)
	cbzBranch is for the PC to take a branch if the given register is 0
	memRead is whether the memory should be read
	memToReg is whether the memory data should be sent to the register
	ALUOp is the operation (PASS/ADD/SUB/AND/OR/XOR) the ALU should take
	memWrite is whether the memory should be written to
	AluSrc determines which input is selected for the second ALU input
	regWrite is whether a register should be written
	setFlags is whether flags should be set 	*/
module control (reset, opcode, immediate, reg2Loc, setPCReg, link, uncondBranch, cbBranch, cbzBranch, memRead, memToReg, ALUOp,
			memWrite, ALUSrc, regWrite, setFlags);
	input logic reset;
	input logic [10:0] opcode;
	output logic immediate, reg2Loc, setPCReg, link, uncondBranch, cbBranch, cbzBranch, memRead, memToReg,
			memWrite, ALUSrc, regWrite, setFlags;
	output logic [2:0] ALUOp;

	// determines the output control signals depending on the opcode, which is specific to each instruction
	always_comb begin
		// if reset is HIGH, all control signals are set to 0, no operations.
		if (reset) begin
			{immediate, reg2Loc, setPCReg, link, uncondBranch, cbBranch, cbzBranch, memRead, memToReg, ALUOp,
			memWrite, ALUSrc, regWrite, setFlags} = 16'b0;
		end else begin
			if (opcode[10:1] == 10'b1001000100) begin //ADDI
				{immediate, setPCReg, link, uncondBranch, cbBranch, cbzBranch, memToReg, ALUOp,
				 memWrite, ALUSrc, regWrite, setFlags} = 14'b10000000100110;
				{reg2Loc, memRead} = 2'b0;
			end else if (opcode == 11'b10101011000) begin // ADDS
				{reg2Loc, setPCReg, link, uncondBranch, cbBranch, cbzBranch, memToReg, ALUOp,
				 memWrite, ALUSrc, regWrite, setFlags} = 14'b00000000100011;
				{immediate, memRead} = 2'b0;
			end else if (opcode[10:5] == 6'b000101) begin //BI
				{immediate, reg2Loc, setPCReg, link, uncondBranch, cbBranch, cbzBranch, memRead, memToReg, ALUOp,
				 memWrite, ALUSrc, regWrite, setFlags} = 16'b0000100000000000;
			end else if (opcode[10:3] == 8'b01010100) begin //CB			
				{setPCReg, link, uncondBranch, cbBranch, cbzBranch, memWrite, setFlags} = 7'b0001000;
				{immediate, reg2Loc, memRead, memToReg, ALUOp, ALUSrc, regWrite} = 9'b0;
			end else if (opcode[10:5] == 6'b100101) begin // BL
				{immediate, setPCReg, link, uncondBranch, memRead, memWrite, regWrite, setFlags} = 8'b00110010;
				{reg2Loc, cbBranch, cbzBranch, memToReg, ALUOp, ALUSrc} = 8'b0;
			end else if (opcode == 11'b11010110000) begin //BR
				{reg2Loc, setPCReg, link, uncondBranch, memWrite, regWrite, setFlags} = 7'b1101000;
				{immediate, cbBranch, cbzBranch, memRead, memToReg, ALUOp, ALUSrc} = 9'b0;
			end else if (opcode[10:3] == 8'b10110100) begin //CBZ
				{reg2Loc, setPCReg, link, uncondBranch, cbBranch, cbzBranch, memWrite, regWrite, setFlags} = 9'b100001000;
				{immediate, memRead, memToReg, ALUOp, ALUSrc} = 7'b0;
			end else if (opcode == 11'b11111000010) begin //LDUR
				{immediate, reg2Loc, setPCReg, link, uncondBranch, cbBranch, cbzBranch, memRead, memToReg, ALUOp,
				 memWrite, ALUSrc, regWrite, setFlags} = 16'b0100000110100110;
			end else if (opcode == 11'b11111000000) begin //STUR
				{immediate, reg2Loc, setPCReg, link, uncondBranch, cbBranch, cbzBranch, memRead, memToReg, ALUOp,
				 memWrite, ALUSrc, regWrite, setFlags} = 16'b0100000000101100;
			end else if (opcode == 11'b11101011000) begin //SUBS
				{reg2Loc, setPCReg, link, uncondBranch, cbBranch, cbzBranch, memToReg, ALUOp,
				 memWrite, ALUSrc, regWrite, setFlags} = 14'b00000000110011;
				{immediate, memRead} = 2'b0;
			// if encountering an instruction not listed above, then set all output control signals to 0
			end else begin // default
				{immediate, reg2Loc, setPCReg, link, uncondBranch, cbBranch, cbzBranch, memRead, memToReg, ALUOp,
				 memWrite, ALUSrc, regWrite, setFlags} = 16'b0;
			end
		end
	end
endmodule


module control_testbench();
	logic reset;
	logic [10:0] opcode;
	logic immediate, reg2Loc, setPCReg, link, uncondBranch, cbBranch, cbzBranch, memRead, memToReg, memWrite,
			ALUSrc, regWrite, setFlags;
	logic [2:0] ALUOp;

	parameter ADDI = 11'b1001000100x, BI = 11'b000101xxxxx, BL = 11'b100101xxxxx, CB = 11'b01010100xxx,
				 ADDS = 11'b10101011000, BR = 11'b11010110000,
				 LDUR = 11'b11111000010, STUR = 11'b11111000000, SUBS = 11'b11101011000;
	
	control dut (.reset, .opcode, .immediate, .reg2Loc, .setPCReg, .link, .uncondBranch, .cbBranch, .cbzBranch, .memRead, .memToReg, .ALUOp,
			.memWrite, .ALUSrc, .regWrite, .setFlags);  
   

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);
	
	integer i;   
	initial begin  
		reset <= 1'b1; opcode <= 11'b0; #50;
		reset <= 1'b0;
		opcode <= ADDI; #50;
		assert(immediate == 1'b1 && ALUOp == 3'b010);
		opcode <= 11'b10010001000; #50;
		assert(immediate == 1'b1 && ALUOp == 3'b010);
		opcode <= 11'b10010001001; #50;
		assert(immediate == 1'b1 && ALUOp == 3'b010);
		
		
		opcode <= SUBS; #50;
		opcode <= BL; #50;
		opcode <= CB; #50;
		
		opcode <= ADDS; #50;
		opcode <= BR; #50;
		opcode <= LDUR; #50;
		opcode <= STUR; #50;
		opcode <= SUBS; #50;
		
	$stop;
	end  
endmodule 