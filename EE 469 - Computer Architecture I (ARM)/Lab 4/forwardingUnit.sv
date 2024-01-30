module forwardingUnit (reset, immediate, EXregWrite, MEMregWrite, Rn, Rm, EXRd, MEMRd, fA, fB, memWriteAddr, memReadAddr, reg2Loc, fM);
	input logic reset, immediate, EXregWrite, MEMregWrite, reg2Loc;
	input logic [4:0] Rn, Rm, EXRd, MEMRd;
	input logic [63:0] memWriteAddr, memReadAddr;
	//input logic wbE, wbM;
	output logic [1:0] fA, fB;
	output logic fM;

	// determines the output fA, fB, which control ALU inputs A and B to be the forwarded values
		// depending on the registers for upcoming instructions
	always_comb begin
		// if reset is HIGH, set fA and fB, meaning no forwarding is needed
		if (reset) begin
			{fA, fB, fM} = 3'b000;
		end else begin
			if (MEMregWrite && MEMRd != 5'b11111 && MEMRd == Rn) begin
				// set fA to HIGH, changing ALU inputA
				fA = 2'b01;
			end else if (EXregWrite && EXRd != 5'b11111 && EXRd == Rn) begin
				fA = 2'b10;
			end else begin
				fA = 2'b00;
			end
			
			if (MEMregWrite && MEMRd != 5'b11111 && MEMRd == Rm && !immediate) begin
				// set fA to HIGH, changing ALU inputA
				fB = 2'b01;
			end else if (EXregWrite && EXRd != 5'b11111 && EXRd == Rm && !immediate) begin
				// set fB to HIGH, changing ALU inputB
				fB = 2'b10;
			end else begin
				fB = 2'b00;
			end
			
			if (EXregWrite && MEMRd != 5'b11111 && memWriteAddr == memReadAddr && reg2Loc) begin
				fM = 1'b1;
			end else begin;
				fM = 1'b0;
			end
		end
	end
endmodule


module forwardingUnit_testbench();
	logic reset, immediate, EXregWrite, MEMregWrite;
	logic [4:0] Rn, Rm, EXRd, MEMRd;
	//logic wbE, wbM;
	logic [63:0] memWriteAddr, memReadAddr;
	logic [1:0] fA, fB;
	logic fM;

	forwardingUnit dut (.reset, .immediate, .EXregWrite, .MEMregWrite, .Rn, .Rm, .EXRd, .MEMRd, .fA, .fB);
	
	
	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);
	
	integer i;   
	initial begin  
		reset <= 1'b1;	#50;
		reset <= 1'b0;
		
		
	$stop;
	end  
endmodule 