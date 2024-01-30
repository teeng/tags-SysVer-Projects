/*
Constructs logic for determining the state of the four flags:
	zero, overflow, carry out, and negative
	
	uses inputs sliceCarry, which are the carry out bits from each bitSlice,
	and sliceOut, which are the results of each bitSlice (result of the operation)

	Timescale was a necessary addition to the module for running
		given regstim simulation file without errors.
*/

`timescale 1 ps / 1 ps

module flagReg (zFlag, oFlag, cFlag, nFlag, sliceCarry, sliceOut); 
	output logic zFlag, oFlag, cFlag, nFlag;
	input logic [63:0] sliceCarry, sliceOut;

	// logic gate for determining the overflow flag
	xor #50 (oFlag, sliceCarry[63], sliceCarry[62]); //oFlag
	
	// connecting wires to the negative and carry out flags directly from
		// the carry out and output bits of the bitSlices
	assign nFlag = sliceOut[63]; //nFlag
	assign cFlag = sliceCarry[63];	//cFlag
	
	// internal logic for storing the zero flag logic
	logic [15:0] zFlagMidTrack;
	logic [3:0] zFlagFinal;
	
	
	//zFlag logic runs through all the outputs from the slices and checks that they are all 0
	genvar i;
	generate
		for(i=0; i<64; i = i + 4) begin : eachSlice
			zFlagMid z16 (.zFlagMidTrack(zFlagMidTrack[i/4]), .i(i), .in(sliceCarry)); //<== check if dividing is alright
		end
		
		for(i=0; i<16; i = i + 4) begin : fourSlice
			zFlagF z8 (.zFlagFinal(zFlagFinal[i/4]), .i(i), .in(zFlagMidTrack));
		end
		
		nor #50 (zFlag, zFlagFinal[0], zFlagFinal[1], zFlagFinal[2], zFlagFinal[3]);
		
	endgenerate
	
	
endmodule