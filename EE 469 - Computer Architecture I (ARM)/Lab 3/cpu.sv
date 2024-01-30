/*
Lab 3- CPU

Constructs a cpu that will perform the following operations:

	ADDI Rd, Rn, Imm12: Reg[Rd] = Reg[Rn] + ZeroExtend(Imm12). 
	ADDS Rd, Rn, Rm: Reg[Rd] = Reg[Rn] + Reg[Rm].  Set flags. 
	B.LT Imm19: If (flags.negative != flags.overflow) PC = PC + SignExtend(Imm19<<2). 
					For lab #4 (only) this instr. has a delay slot.
	B Imm26: PC = PC + SignExtend(Imm26 << 2). 
					For lab #4 (only) this instr. has a delay slot.
	BL Imm26: X30 = PC + 4 (instruction after this one), PC = PC + SignExtend(Imm26 << 2)
	BR Rd: PC = Reg[Rd]
	CBZ Rd, Imm19: If (Reg[Rd] == 0) PC = PC + SignExtend(Imm19<<2). 
					For lab #4 (only) this instr. has a delay slot.
	LDUR Rd, [Rn, #Imm9]: Reg[Rd] = Mem[Reg[Rn] + SignExtend(Imm9)]. 
					For lab #4 (only) the value in rd cannot be used in the next cycle.
	STUR Rd, [Rn, #Imm9]: Mem[Reg[Rn] + SignExtend(Imm9)] = Reg[Rd]. 
	SUBS Rd, Rn, Rm: Reg[Rd] = Reg[Rn] - Reg[Rm].  Set flags.
	
Operations must be 32b long following LEGv8 format.

The cpu will perform the given operations on data that is 64'b, controlling what is placed and retrieved from memory,
and in lower-level data storage. The CPU itself has no output, but the effect of the given operations
can be seen in simulation running on a stable clock.

Resetting the cpu will cause no operations to be completed.


	Timescale was a necessary addition to the module for running
		simulation file without errors.
*/

`timescale 1 ps / 1 ps

module cpu (clk, reset);
	input logic clk, reset;
	
	//========CONTROL========
		// instruction is the 32'b opcode and data needed to perform one of instruction types listed above.
		logic [31:0] instruction;
		// all control signals needed to perform each of the instruction types listed above.
		logic immediate, reg2Loc, setPCReg, link, uncondBranch, cbBranch, cbzBranch, memRead,
				memToReg, memWrite, ALUSrc, regWrite, setFlags;
		logic [2:0] ALUOp;
		// controlUnit determines output for each of the control signals.
			// If reset is high, all control signals are set to LOW, meaning cpu should perform no operations until
				// PC has updated to the next instruction
			// immediate is for ADDI instructions, where the immediate value in the instruction should be retrieved
			// reg2Loc is for where in the instruction the second register is
			// setPCReg is whether the PC should be set to a register value instead of updating through other means
			// link is whether to also record the next instruction address when branching (for BL instruction)
			// uncondBranch is for the PC to take a branch without any conditions
			// cbBranch is for the PC to take a branch with a specified condition (LT, less than)
			// cbzBranch is for the PC to take a branch if the given register is 0
			// memRead is whether the memory should be read
			// memToReg is whether the memory data should be sent to the register
			// ALUOp is the operation (PASS/ADD/SUB/AND/OR/XOR) the ALU should take
			// memWrite is whether the memory should be written to
			// AluSrc determines which input is selected for the second ALU input
			// regWrite is whether a register should be written
			// setFlags is whether flags should be set
		control controlUnit (.reset(reset), .opcode(instruction[31:21]), .immediate(immediate), .reg2Loc(reg2Loc),
					.setPCReg(setPCReg), .link(link), .uncondBranch(uncondBranch), .cbBranch(cbBranch), .cbzBranch(cbzBranch),
					.memRead(memRead), .memToReg(memToReg), .ALUOp(ALUOp), .memWrite(memWrite), .ALUSrc(ALUSrc), .regWrite(regWrite),
					.setFlags(setFlags));
					

	//========PC========
		// memAddr is current instruction memory address, nextAddr is the next immediate address if there is no branching
		// cbAddr is the sign extended given conditional branch address from the instruction
		// bAddr is the sign extended given nonconditional branch address from the instruction
		// brAddr is used to determine which branch type, whether it is unconditional or conditional,
			//	should be sent to the pc to update the current memAddr
		// branchCond determined later under BRANCH CONDITION
		logic [63:0] nextAddr, memAddr, cbAddr, bAddr, brAddr;
		logic branchCond;
		
		mux64b2_1 signExtBAddr (.out(bAddr), .i1({{36{1'b1}}, instruction[25:0], 2'b00}),	// if negative, extend 1s
														 .i0({36'b0, instruction[25:0], 2'b00}),	// if positive, extend 0s
														 .sel(instruction[25]));	// sign bit
		mux64b2_1 signExtCBAddr (.out(cbAddr), .i1({{43{1'b1}}, instruction[23:5], 2'b00}), //if negative, extend 1s
															.i0({43'b0, instruction[23:5], 2'b00}),	// if positive, extend 0s
															.sel(instruction[23]));	// sign bit
		
		// CBZ zero check
		logic zFlagAlways; // CBZ requires knowing the zero flag for the register immediately, not from set flags
		// readData1 is register 1's data
		// readData2 is register 2's data
		// writeData is the 64'b data to be written into a register
		logic [63:0] readData1, readData2, writeData;
		// for CBZ: checks the given register 2's data for whether it equals 0
		zFlagReg regData2 (.zFlag(zFlagAlways), .regCheck(readData2));
		// if taking an unconditional branch, output the branch address, otherwise, output the conditional branch address
			// the result is brAddr, which is the general destination address
		mux64b2_1 branchType (.out(brAddr), .i1(bAddr), .i0(cbAddr), .sel(uncondBranch));
		
		// instantiates a pc to update the memory address
			// setPC will update the PC to equal the data in register2
			// the branchCond is determined later under BRANCH CONDITION, is controlled by either a (non)conditional branch or CBZ
		pc pcUnit (.nextAddr(nextAddr), .memAddr(memAddr), .destAddr(brAddr), .setPC(readData2), .setPCReg(setPCReg),
					  .branchCond(branchCond), .clk(clk), .reset(reset));
	
	
	//========INSTRUCTION MEMORY========
		// outputs the memory address for given instruction, uses clock for error-checking
		instructmem iMemUnit (.address(memAddr), .instruction(instruction), .clk(clk));
	
	
	//========REGFILE========
		// regWriteLoc is the which register to write to
		// reg2Chosen is controlled by reg2Loc, of where the second register should be retrieved from instruction
		logic [4:0] regWriteLoc, reg2Chosen;
		// reg2Choose in RegFile, which is either Rd/Rt (4:0) for I/D/CB type or Rm (20:16) for R-type
			// reg2Chosen is sent to the regFile for getting the data from that register
		// writeRegLink is either picking from the given Rd/Rt in the instruction, or in the case of
			// instruction BL, a link to the next memory address is saved in register 30 if control signal link is HIGH
		mux5b2_1 reg2Choose (.out(reg2Chosen), .regChoice1(instruction[4:0]), .regChoice0(instruction[20:16]), .sel(reg2Loc));
		mux5b2_1 writeRegLink (.out(regWriteLoc), .regChoice1(5'b11110), .regChoice0(instruction[4:0]), .sel(link));
		
		// Sending chosen registers (reg2Chosen and regWriteLoc) through regFileUnit
		// Outputs readData1, readData2 delivered to either ALU or to data memory
		regfile regFileUnit (.ReadData1(readData1), .ReadData2(readData2), .WriteData(writeData), .ReadRegister1(instruction[9:5]),
					.ReadRegister2(reg2Chosen), .WriteRegister(regWriteLoc), .RegWrite(regWrite), .clk(clk));
	
	
	//========ALU INPUT B========
		// extendedShift holds the sign-extended DT_address = instruction[20:12] for destination memory address
		logic [63:0] extendedShift;
		mux64b2_1 signExtend (.out(extendedShift), .i1({{55{1'b1}}, instruction[20:12]}), // if sign bit = 1, extend 1s
																.i0({55'b0, instruction[20:12]}), // if sign bit = 0; extend 0s
																.sel(instruction[20]));	
		
		// DTOrImm determines whether a destination address, or an extended immediate value (for ADDI) should be sent
			// to ALU as second input, output memOrImm.
		// dataB is the final data to be sent to the ALU, either from the register file (register 2 data) or memOrImm.
		logic [63:0] dataB, memOrImm;
		mux64b2_1 DTOrImm (.out(memOrImm), .i1({52'b0, instruction[21:10]}), .i0(extendedShift), .sel(immediate));
		// determining input B for ALU operation, which is either
			// from R-type instruction where dataB is register2's data
			// from D-type/I-type instruction.
		mux64b2_1 ALUSrcMux (.out(dataB), .i1(memOrImm), .i0(readData2), .sel(ALUSrc));
		
	
	//========ALU OUTPUT========
		// ALUResult stores 64'b result of ALU, with inputs
			// A - register 1's data
			// B - dataB
			// cntrl - ALU Control signal for operation (ADD/SUB/...)
		// Controls flags:
			// negative, zero, overflow, carry_out
		// flags are only changed when setFlags is HIGH for a clock edge. They are set to the current results
			// of the ALU operation, and will stay the same until setFlags is HIGH again and different results occur.
		logic [63:0] ALUResult;
		logic negative, zero, overflow, carry_out;
		alu aluUnit (.A(readData1), .B(dataB), .cntrl(ALUOp), .result(ALUResult), .negative(negative), .zero(zero),
					.overflow(overflow), .carry_out(carry_out), .setFlag(setFlags), .clk(clk));
	
	
	//========BRANCH CONDITION========
		// internal logic zAndB stores result of AND between zero flag and the branch control signal
		// cbzGo is to initiate a conditional branch if zero (CBZ)
		logic zFlag, cbzGo;
		// picking between set flag (for general conditional branch) or the always-active zFlag for CBZ
			// since the zero flag can be high after being set, but may not represent the currently given register's data
			// controlled by CBZ instruction's MSB, which is 1, in contrast to the general conditional branch's MSB, which is 0 
		mux2_1 cbzFlag (.out(zFlag), .in({zFlagAlways, zero}), .sel(instruction[31]));
		
		// if doing a CBZ instruction and zFlag is HIGH, cbzGo is HIGH, meaning it will trigger a branch (determined below)
		and #50 (cbzGo, zFlag, cbzBranch);
		
		// bLT determines whether the branch when less than instruction should be triggered, which is
			// controlled by negative and overflow set flags
		// cbGo is if a conditional branch is ocurring and if bLT is high, meaning it will trigger a branch (determined below)
		logic bLT, cbGo;
		xor #50 (bLT, negative, overflow);
		and #50 (cbGo, bLT, cbBranch);
		
		// outputs HIGH if a branch is needed, which is sent to program counter (found above in PC section)
		or #50 (branchCond, cbGo, cbzGo, uncondBranch);
	
	
	//========DATA MEMORY========
		// memDataOut is the output from data memory
		logic [63:0] memDataOut;
		// Controlled by:
			// memWrite, HIGH means data will be written to memory
			// memRead, HIGH means data will be read from memory
		// Inputs are:
			// destination memory address (processed by ALU) to either write to or read from
			// readData2, the 64'b data from the 2nd register to be written
			// clk for access/write on clockedge
			// xfersize integer transfer size for alignment (default double-word = 8 = 4'b1000)
		datamem dataMemUnit (.address(ALUResult), .write_enable(memWrite), .read_enable(memRead), .write_data(readData2), .clk(clk),
					.xfer_size(4'b1000), .read_data(memDataOut));
	
	
	//========WRITE TO REGISTER========
		// newData is either the ALU result to be sent directly to the register, or if it is from reading the data memory
			// as determined by control signal memToReg
		logic [63:0] newData;
		mux64b2_1 memData (.out(newData), .i1(memDataOut), .i0(ALUResult), .sel(memToReg));
		// if a link to the next instruction should be made, instead write to register the nextAddr, instead of what may
			// be sent from ALU or Data Memory. Otherwise, send the newData to the register to be written
		mux64b2_1 writingReg (.out(writeData), .i1(nextAddr), .i0(newData), .sel(link));
endmodule



// testbench to model cpu results
module cpu_testbench();
	logic clk, reset;
	
	parameter ClockDelay = 100000;
	
	// sets up the cpu module for testing, named as dut   
	cpu dut (.clk, .reset);  
	
	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end
   
	// simulation
	integer i;   
	initial begin
		reset <= 1'b1;					 @(posedge clk);
		reset <= 1'b0; repeat(1000) @(posedge clk); // simulation requires at most 50 cycles for tests 1-6
																  // requires closer to 1000 for tests 11, 12
	$stop;
	end  
endmodule 