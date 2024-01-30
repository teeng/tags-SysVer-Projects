`timescale 1 ps / 1 ps

module zFlagReg (zFlag, regCheck);
	output logic zFlag;
	input logic [63:0] regCheck;


	// internal logic for storing the zero flag logic
	logic [15:0] zFlagMidTrack;
	logic [3:0] zFlagFinal;
	
	
	//zFlag logic runs through all the outputs from the slices and checks that they are all 0
	genvar i;
	generate
		for(i=0; i<64; i = i + 4) begin : eachSlice
			zFlagMid z16 (.zFlagMidTrack(zFlagMidTrack[i/4]), .i(i), .in(regCheck));
		end
		
		for(i=0; i<16; i = i + 4) begin : fourSlice
			zFlagF z8 (.zFlagFinal(zFlagFinal[i/4]), .i(i), .in(zFlagMidTrack));
		end
		
		nor #50 (zFlag, zFlagFinal[0], zFlagFinal[1], zFlagFinal[2], zFlagFinal[3]);
		
	endgenerate
endmodule