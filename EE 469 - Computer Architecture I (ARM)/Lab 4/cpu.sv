/*
Lab 4 - Pipelined CPU

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
	
	logic nReset;
	not #50 (nReset, reset);
	// all control signals needed to perform each of the instruction types listed above.
	logic immediate, reg2Loc, setPCReg, link, uncondBranch, cbBranch, cbzBranch, memRead,
			memToReg, memWrite, ALUSrc, regWrite, setFlags;
	logic zFlagAlwaysID;
	logic [2:0] ALUOp;
	
	logic [1:0] WB_ID;
	logic [6:0] M_ID;
	logic [5:0] EX_ID;
	// stores the control signals WB, M, EX responsible for forwarding
		// WB is RegWrite, MemToReg signals
		// M is MemRead, MemWrite, Branch (conditional) signals
		// EX is ALUSrc, ALUOp, immediate signals	
	registers #(.LENGTH(2)) WBctrl1 (.q(WB_ID), .d({regWrite, memToReg}), .writeEnable(nReset), .clk(clk), .reset(reset));
	registers #(.LENGTH(7)) Mctrl1 (.q(M_ID), .d({memRead, memWrite, cbBranch, cbzBranch, uncondBranch, link, setPCReg}), .writeEnable(nReset),
											  .clk(clk), .reset(reset));
	registers #(.LENGTH(6)) EXctrl1 (.q(EX_ID), .d({setFlags, ALUSrc, ALUOp, immediate}), .writeEnable(nReset), .clk(clk), .reset(reset));
	
	logic [1:0] WB_EX;
	logic [6:0] M_EX;
	registers #(.LENGTH(2)) WBctrl2 (.q(WB_EX), .d(WB_ID), .writeEnable(nReset), .clk(clk), .reset(reset));
	registers #(.LENGTH(7)) Mctrl2 (.q(M_EX), .d(M_ID), .writeEnable(nReset), .clk(clk), .reset(reset));

	logic [1:0] WB_MEM;
	registers #(.LENGTH(2)) WBctrl3 (.q(WB_MEM), .d(WB_EX), .writeEnable(nReset), .clk(clk), .reset(reset));
	
	
	logic [3:0] flagTemp;
	//====STAGE IF====
		//========PC========
			logic [63:0] nextAddr, //nextAddr is the next immediate address without branching
							 memAddr,  // memAddr is current instruction memory address
							 writeData, // writeData is the 64'b data to be written into a register
							 memAddrDest, memAddrDestEX, memAddrDestMEM,
							 readData2ID;
			logic [31:0] instruction; // instruction is the 32'b opcode and data needed to perform one of instruction types listed above
											  // and is sed within the ID stage
			logic PCSrc; // PCSrc determined later under BRANCH CONDITION
			// instantiates a pc to update the memory address
				// setPC will update the PC to equal the data in register2
				// the PCSrc is determined later under BRANCH CONDITION, is controlled by either a
					// (non)conditional branch or CBZ
			logic cbzGo;
			logic [63:0] writeDataExt;
			pc pcUnit (.nextAddr(nextAddr), .memAddr(memAddr), .resultMem(memAddrDest), .setPC(writeDataExt), //likely problem with setPC
						  .setPCReg(setPCReg), .PCSrc(PCSrc), .cbzBranch(cbzGo), .clk(clk), .reset(reset));
			
		
			//========INSTRUCTION MEMORY========
			// outputs the memory address for given instruction, uses clock for error-checking
				// sends output to pipeline register
			instructmem iMemUnit (.address(memAddr), .instruction(instruction), .clk(clk));
		
		
	//====IF/ID PIPELINE REGISTER STORAGE====
		logic [31:0] instructionIF, instructionID, instructionEX, instructionMEM;
		logic [63:0] nextAddrIF, memAddrIF;
		
		registers nextAddrPipe (.q(nextAddrIF), .d(nextAddr), .writeEnable(nReset), .clk(clk), .reset(reset));
		registers memAddrPipe1 (.q(memAddrIF), .d(memAddr), .writeEnable(nReset), .clk(clk), .reset(reset));
		registers #(.LENGTH(32)) instMem (.q(instructionIF), .d(instruction), .writeEnable(nReset),
						.clk(clk), .reset(reset));
		
	
	//====STAGE ID====
		//========REGFILE========
			// regWriteLoc is the which register to write to
			// reg2Chosen is controlled by reg2Loc, of where the second register should be retrieved from instruction
			logic [4:0] regWriteLoc, reg2Chosen, regDPipeMEM, regDPipeEX, regDPipeID;
			// reg2Choose in RegFile, which is either Rd/Rt (4:0) for I/D/CB type or Rm (20:16) for R-type
				// reg2Chosen is sent to the regFile for getting the data from that register
			// writeRegLink is either picking from the given Rd/Rt in the instruction, or in the case of
				// instruction BL, a link to the next memory address is saved in register 30 if control signal link is HIGH
			mux5b2_1 reg2Choose (.out(reg2Chosen), .regChoice1(instructionIF[4:0]), .regChoice0(instructionIF[20:16]), .sel(reg2Loc));
			mux5b2_1 writeRegLink (.out(regWriteLoc), .regChoice1(5'b11110), .regChoice0(instructionIF[4:0]), .sel(link));
			
			
			// Sending chosen registers (reg2Chosen and regWriteLoc) through regFileUnit
			// Outputs readData1, readData2 delivered to either ALU or to data memory
			logic [63:0] readData1, // readData1 is register 1's data
							 readData2; // readData2 is register 2's data
			regfile regFileUnit (.ReadData1(readData1), .ReadData2(readData2), .WriteData(writeData), .ReadRegister1(instructionIF[9:5]),
						.ReadRegister2(reg2Chosen), .WriteRegister(regDPipeEX), .RegWrite(WB_EX[1]), .clk(clk));
			
			logic [63:0] cbAddr, // cbAddr is the sign extended given conditional branch address from the instruction
							 bAddr; // bAddr is the sign extended given nonconditional branch address from the instruction
			
		
			mux64b2_1 signExtBAddr (.out(bAddr), .i1({{36{1'b1}}, instructionIF[25:0], 2'b00}),	// if negative, extend 1s
															 .i0({36'b0, instructionIF[25:0], 2'b00}),	// if positive, extend 0s
															 .sel(instructionIF[25]));	// sign bit
			mux64b2_1 signExtCBAddr (.out(cbAddr), .i1({{43{1'b1}}, instructionIF[23:5], 2'b00}), //if negative, extend 1s
																.i0({43'b0, instructionIF[23:5], 2'b00}),	// if positive, extend 0s
																.sel(instructionIF[23]));	// sign bit
			
			
		//=====ALU INPUT B========
			// extendedShift holds the sign-extended DT_address = instructionIF[20:12] for destination memory address
			logic [63:0] extendedShift;
			mux64b2_1 signExtend (.out(extendedShift), .i1({{55{1'b1}}, instructionIF[20:12]}), // if sign bit = 1, extend 1s
																.i0({55'b0, instructionIF[20:12]}), // if sign bit = 0; extend 0s
																.sel(instructionIF[20]));	
			// DTOrImm determines whether a destination address, or an extended immediate value (for ADDI) should be sent
			// to ALU as second input, output memOrImm.
			// dataB is the final data to be sent to the ALU, either from the register file (register 2 data) or memOrImm.
			logic [63:0] memOrImm;
			mux64b2_1 DTOrImm (.out(memOrImm), .i1({52'b0, instructionIF[21:10]}), .i0(extendedShift), .sel(immediate));
			
			
		//========BRANCH CONDITION========
		
			logic zFlagAlways, zFlagAlwaysEX;
			logic negative, zero, overflow, carry_out;
			// internal logic zAndB stores result of AND between zero flag and the branch control signal
			// cbzGo is to initiate a conditional branch if zero (CBZ)
			logic zFlag;
			// picking between set flag (for general conditional branch) or the always-active zFlag for CBZ
				// since the zero flag can be high after being set, but may not represent the currently given register's data
				// controlled by CBZ instruction's MSB, which is 1, in contrast to the general conditional branch's MSB, which is 0 
			mux2_1 cbzFlag (.out(zFlag), .in({zFlagAlways, zero}), .sel(instructionIF[31])); //CHANGED sel from instructionIF[31] to cbzBranch
			
			// if doing a CBZ instruction and zFlag is HIGH, cbzGo is HIGH, meaning it will trigger a branch (determined below)
			and #50 (cbzGo, zFlag, cbzBranch);
			
			// bLT determines whether the branch when less than instruction should be triggered, which is
				// controlled by negative and overflow set flags
			// cbGo is if a conditional branch is ocurring and if bLT is high, meaning it will trigger a branch (determined below)
			logic bLT, cbGo;
			xor #50 (bLT, flagTemp[0], flagTemp[2]);
			and #50 (cbGo, bLT, cbBranch);
			
			// outputs HIGH if a branch is needed, which is sent to program counter (found above in PC section)
			or #50 (PCSrc, cbGo, cbzGo, uncondBranch);
		
		
		//========CONTROL========
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
			control controlUnit (.reset(reset), .opcode(instructionIF[31:21]), .immediate(immediate),
					.reg2Loc(reg2Loc), .setPCReg(setPCReg), .link(link), .uncondBranch(uncondBranch),
					.cbBranch(cbBranch), .cbzBranch(cbzBranch), .memRead(memRead), .memToReg(memToReg),
					.ALUOp(ALUOp), .memWrite(memWrite), .ALUSrc(ALUSrc), .regWrite(regWrite), .setFlags(setFlags));
			
			
		
	//====ID/EX PIPELINE REGISTER STORAGE====
		logic [2:0] ctrlForw1;
		logic [4:0] reg1Pipe, reg2Pipe;
		logic [63:0] readData1ID, memOrImmID, bAddrID, cbAddrID, nextAddrID, memAddrID;
		logic [1:0] forwardA, forwardB;
		
		// stores the three registers used by regFile
		registers #(.LENGTH(5)) regRn (.q(reg1Pipe), .d(instructionIF[9:5]), .writeEnable(nReset), .clk(clk), .reset(reset));
		registers #(.LENGTH(5)) regRm (.q(reg2Pipe), .d(reg2Chosen), .writeEnable(nReset), .clk(clk), .reset(reset));
		registers #(.LENGTH(5)) regRd1 (.q(regDPipeID), .d(regWriteLoc), .writeEnable(nReset), .clk(clk), .reset(reset));
		// stores the data of the Rn and Rm from regfile for use in ALU
		registers regData1Pipe (.q(readData1ID), .d(readData1), .writeEnable(nReset), .clk(clk), .reset(reset));
		registers regData2Pipe (.q(readData2ID), .d(readData2), .writeEnable(nReset), .clk(clk), .reset(reset));
		
		registers signExtBPipe (.q(bAddrID), .d(bAddr), .writeEnable(nReset), .clk(clk), .reset(reset));
		registers signExtCBPipe (.q(cbAddrID), .d(cbAddr), .writeEnable(nReset), .clk(clk), .reset(reset));
		
		registers memOrImmPipe (.q(memOrImmID), .d(memOrImm), .writeEnable(nReset), .clk(clk), .reset(reset));
		
		registers nextAddrPipe2 (.q(nextAddrID), .d(nextAddrIF), .writeEnable(nReset), .clk(clk), .reset(reset));
		
		registers memAddrPipe2 (.q(memAddrID), .d(memAddrIF), .writeEnable(nReset), .clk(clk), .reset(reset));
		
		registers #(.LENGTH(32)) instMem2 (.q(instructionID), .d(instructionIF), .writeEnable(nReset),
						.clk(clk), .reset(reset));
		registers #(.LENGTH(32)) instMem3 (.q(instructionEX), .d(instructionID), .writeEnable(nReset),
						.clk(clk), .reset(reset));
		registers #(.LENGTH(32)) instMem4 (.q(instructionMEM), .d(instructionEX), .writeEnable(nReset),
						.clk(clk), .reset(reset));				
	
	//====STAGE EX====
		logic [63:0] dataB;
		// determining input B for ALU operation, which is either
			// from R-type instruction where dataB is register2's data
			// from D-type/I-type instruction.
		mux64b2_1 ALUSrcMux (.out(dataB), .i1(memOrImmID), .i0(readData2ID), .sel(EX_ID[4]));
			
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
			logic [63:0] aluA, aluB;
			
			//========FORWARDING========
			//logic [4:0] regDPipeEX;
			logic [63:0] ALUResultEX, ALUResultMEM;
			forwardingUnit forwUnit (.reset(reset), .immediate(EX_ID[0]), .EXregWrite(WB_EX[1]), .MEMregWrite(WB_MEM[1]), .Rn(reg1Pipe), .Rm(reg2Pipe),
									.EXRd(regDPipeEX), .MEMRd(regDPipeMEM), .fA(forwardA), .fB(forwardB), .memWriteAddr(ALUResultMEM), .memReadAddr(ALUResultEX),
									.reg2Loc(reg2Loc), .fM(forwardM));
			
			mux64b4_1 aluForwA (.out(aluA), .i3(64'b0), .i2(ALUResultEX), .i1(ALUResultMEM), .i0(readData1ID), .sel(forwardA));
			mux64b4_1 aluForwB (.out(aluB), .i3(64'b0), .i2(ALUResultEX), .i1(ALUResultMEM), .i0(dataB), .sel(forwardB));
			
			alu aluUnit (.A(aluA), .B(aluB), .cntrl(EX_ID[3:1]), .result(ALUResult), .negative(negative), .zero(zero),
						.overflow(overflow), .carry_out(carry_out), .flagTemp(flagTemp), .setFlag(EX_ID[5]), .clk(clk));
		
		
			// CBZ zero checks the given register 2's data for whether it equals 0
			// CBZ requires knowing the zero flag for the register immediately, not from set flags
			// checks the given register 2's data for whether it equals 0
			zFlagReg regData2Check (.zFlag(zFlagAlways), .regCheck(readData2));
			
			
			logic [63:0] brAddr; // brAddr is used to determine which branch address of the branch, unconditional or conditional
			// memAddDest adds the branch destination address to the current PC value
			logic [63:0] brAddrID, brAddrEX, brAddrMEM;
			pcAddMem pcAddMemUnit (.resultMem(memAddrDest), .currMemAddr(memAddrIF), .destAddr(brAddr), .clk(clk), .reset(reset));
			
			// if taking an unconditional branch, output the branch address, otherwise, output the conditional branch address
				// the result is brAddr, which is the general destination address
			logic [63:0] brAddrTemp;
			mux64b2_1 branchType (.out(brAddr), .i1(bAddr), .i0(cbAddr), .sel(uncondBranch));
			
	//====EX/MEM PIPELINE REGISTER STORAGE====
		logic [63:0] memAddrEX, dataBEX, readData2EX, nextAddrEX;
		
		// stores the new Rd
		registers #(.LENGTH(5)) regRd2 (.q(regDPipeEX), .d(regDPipeID), .writeEnable(nReset), .clk(clk), .reset(reset));
		// stores the dataB input of ALU and the ALU Output
		registers ALUdataB (.q(dataBEX), .d(dataB), .writeEnable(nReset), .clk(clk), .reset(reset));
		registers ALUoutput1 (.q(ALUResultEX), .d(ALUResult), .writeEnable(nReset), .clk(clk), .reset(reset));
		registers #(.LENGTH(1)) zFlagAlwaysPipe (.q(zFlagAlwaysID), .d(zFlagAlways), .writeEnable(nReset), .clk(clk), .reset(reset));
		registers #(.LENGTH(1)) zFlagAlwaysPipe2 (.q(zFlagAlwaysEX), .d(zFlagAlwaysID), .writeEnable(nReset), .clk(clk), .reset(reset));
		registers regData2Pipe2 (.q(readData2EX), .d(readData2ID), .writeEnable(nReset), .clk(clk), .reset(reset));
		registers nextAddrPipe3 (.q(nextAddrEX), .d(nextAddrID), .writeEnable(nReset), .clk(clk), .reset(reset));
		
		registers memAddrPipeSaving2 (.q(memAddrDestEX), .d(memAddrDest), .writeEnable(nReset), .clk(clk), .reset(reset));
		registers memAddrPipeSaving3 (.q(memAddrDestMEM), .d(memAddrDestEX), .writeEnable(nReset), .clk(clk), .reset(reset));
		registers memAddrPipe3 (.q(memAddrEX), .d(memAddrID), .writeEnable(nReset), .clk(clk), .reset(reset));
		registers brAddrPipe1 (.q(brAddrID), .d(brAddr), .writeEnable(nReset), .clk(clk), .reset(reset));
		registers brAddrPipe2 (.q(brAddrEX), .d(brAddrID), .writeEnable(nReset), .clk(clk), .reset(reset));
		registers brAddrPipe3 (.q(brAddrMEM), .d(brAddrEX), .writeEnable(nReset), .clk(clk), .reset(reset));
		
		
		
		
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
			datamem dataMemUnit (.address(ALUResultEX), .write_enable(M_EX[5]), .read_enable(M_EX[6]), .write_data(readData2EX), .clk(clk),
						.xfer_size(4'b1000), .read_data(memDataOut));
		
		//====MEM/WB PIPELINE REGISTER STORAGE====
			logic [63:0] memDataOutMEM, nextAddrMEM, memAddrMEM, readData2MEM;
			
			registers #(.LENGTH(5)) regRd3 (.q(regDPipeMEM), .d(regDPipeEX), .writeEnable(nReset), .clk(clk), .reset(reset));
			registers memDataOutPipe (.q(memDataOutMEM), .d(memDataOut), .writeEnable(nReset), .clk(clk), .reset(reset));
			registers ALUoutput2 (.q(ALUResultMEM), .d(ALUResultEX), .writeEnable(nReset), .clk(clk), .reset(reset));
			registers nextAddrPipe4 (.q(nextAddrMEM), .d(nextAddrEX), .writeEnable(nReset), .clk(clk), .reset(reset));
			registers memAddrPipe4 (.q(memAddrMEM), .d(memAddrEX), .writeEnable(nReset), .clk(clk), .reset(reset));
			registers memWritePipe (.q(readData2MEM), .d(readData2EX), .writeEnable(nReset), .clk(clk), .reset(reset));
			
			logic [63:0] writeDataEX, writeDataMEM, writeDataWB;
			registers writeDataSave1 (.q(writeDataEX), .d(writeData), .writeEnable(nReset), .clk(clk), .reset(reset));
			registers writeDataSave2 (.q(writeDataMEM), .d(writeDataEX), .writeEnable(nReset), .clk(clk), .reset(reset));
			registers writeDataSave3 (.q(writeDataWB), .d(writeDataMEM), .writeEnable(nReset), .clk(clk), .reset(reset));
			registers writeDataSave4 (.q(writeDataExt), .d(writeDataWB), .writeEnable(nReset), .clk(clk), .reset(reset));
			
			logic linkExt1, linkExt2;
			registers #(.LENGTH(1)) linkSave2 (.q(linkExt1), .d(M_EX[1]), .writeEnable(nReset), .clk(clk), .reset(reset));
			registers #(.LENGTH(1)) linkSave3 (.q(linkExt2), .d(linkExt1), .writeEnable(nReset), .clk(clk), .reset(reset));
		//========WRITE TO REGISTER========
			// newData is either the ALU result to be sent directly to the register, or if it is from reading the data memory
				// as determined by control signal memToReg
			logic [63:0] newDataTemp, newData, newDataFinal;
			logic linkDelayWrite;
			
			and #50 (linkDelayWrite, regWrite, linkExt2, link);
			
			mux64b2_1 memData (.out(newDataTemp), .i1(memDataOut), .i0(ALUResultEX), .sel(WB_MEM[0]));
			mux64b2_1 writingReg1 (.out(newData), .i1(writeDataMEM), .i0(newDataTemp), .sel(linkDelayWrite));
			mux64b2_1 memData2 (.out(newDataFinal), .i1(readData2MEM), .i0(newData), .sel(forwardM));
			// if a link to the next instruction should be made, instead write to register the nextAddr, instead of what may
				// be sent from ALU or Data Memory. Otherwise, send the newData to the register to be written
			
			
			mux64b2_1 writingReg2 (.out(writeData), .i1(nextAddrEX), .i0(newDataFinal), .sel(M_EX[1]));
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
		reset <= 1'b1;				  @(posedge clk);
		reset <= 1'b0; repeat(100) @(posedge clk); // simulation requires cycles for tests 1-6
	$stop;
	end  
endmodule 