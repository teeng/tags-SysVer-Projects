/*
Constructs logic for determining the state of the four flags:
	zero, overflow, carry out, and negative
	
	uses inputs sliceCarry, which are the carry out bits from each bitSlice,
	and sliceOut, which are the results of each bitSlice (result of the operation)

	Timescale was a necessary addition to the module for running
		given regstim simulation file without errors.
*/

`timescale 1 ps / 1 ps

module setFlags (zFlag, oFlag, cFlag, nFlag, sliceCarry, sliceOut, setFlag, clk); 
	output logic zFlag, oFlag, cFlag, nFlag;
	input logic [63:0] sliceCarry, sliceOut;
	input logic setFlag, clk;
	
	
	logic [3:0] flagSave;
	// logic gate for determining the overflow flag
	xor #50 (flagSave[2], sliceCarry[63], sliceCarry[62]); //oFlag
	
	// connecting wires to the negative and carry out flags directly from
		// the carry out and output bits of the bitSlices
	assign flagSave[1] = sliceCarry[63]; //cFlag
	assign flagSave[0] = sliceOut[63]; //nFlag
	
	zFlagReg zFlagTime (.zFlag(flagSave[3]), .regCheck(sliceOut));
	
	// if set is HIGH, flags = current flags computed and stay that way even when set LOW
	// if set is LOW, keep current value of flags
	
	logic [3:0] tempFlag;
	mux2_1 setZ (.out(tempFlag[3]), .in({flagSave[3], zFlag}), .sel(setFlag));
	mux2_1 setO (.out(tempFlag[2]), .in({flagSave[2], oFlag}), .sel(setFlag));
	mux2_1 setC (.out(tempFlag[1]), .in({flagSave[1], cFlag}), .sel(setFlag));
	mux2_1 setN (.out(tempFlag[0]), .in({flagSave[0], nFlag}), .sel(setFlag));
	
	D_FF stayZ (.q(zFlag), .d(tempFlag[3]), .reset(1'b0), .clk(clk));
	D_FF stayO (.q(oFlag), .d(tempFlag[2]), .reset(1'b0), .clk(clk));
	D_FF stayC (.q(cFlag), .d(tempFlag[1]), .reset(1'b0), .clk(clk));
	D_FF stayN (.q(nFlag), .d(tempFlag[0]), .reset(1'b0), .clk(clk));
	
endmodule

module setFlags_testbench();
	logic zFlag, oFlag, cFlag, nFlag;
	logic [63:0] sliceCarry, sliceOut;
	logic setFlag, clk;

	parameter ClockDelay = 5000;
	
	setFlags dut (.zFlag, .oFlag, .cFlag, .nFlag, .sliceCarry, .sliceOut, .setFlag, .clk);  
   
	
	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);
	
	integer i;   
	initial begin  		
		sliceCarry <= '1; sliceOut <= '0; setFlag <= 1'b0; 				@(posedge clk);
		sliceCarry <= '1; sliceOut <= '0; setFlag <= 1'b1; 				@(posedge clk);
		setFlag <= 1'b0;											 	  repeat(3) @(posedge clk);
		
		sliceCarry <= '0; sliceOut <= '1; 					  	  repeat(3) @(posedge clk);
		
		setFlag <= 1'b1; 																@(posedge clk);
		setFlag <= 1'b0;											 	  repeat(3) @(posedge clk);
		
	$stop;
	end
endmodule 