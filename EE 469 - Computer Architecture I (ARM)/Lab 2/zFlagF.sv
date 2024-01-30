/*
Logic to find if there are any 1s among the results of the 16'b input, in
	Is meant to be instantiated multipled times to cover the entire 16'b input
	with logic gates limited to 4 inputs

	Timescale was a necessary addition to the module for running
		given regstim simulation file without errors.
*/

`timescale 1 ps / 1 ps
module zFlagF (zFlagFinal, i, in);
	output logic zFlagFinal;
	input logic [31:0] i; 
	input logic [15:0] in;

	or #50 (zFlagFinal, in[i], in[i+1], in[i+2], in[i+3]);
	
endmodule