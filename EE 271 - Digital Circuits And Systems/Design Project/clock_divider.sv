// This module divides the on-board FPGA clock at 50Mhz to
// divided_clocks[0] = 25MHz, [1] = 12.5Mhz, ... [23] = 3Hz, 
// [24] = 1.5Hz, [25] = 0.75Hz, ...and so on.
module clock_divider (clock, divided_clocks);
	// creates input variables reset and clock with type logic
	input logic clock;
	// creates output variables divided_clocks[31:0] with type logic.
	output logic  [31:0]  divided_clocks = 0;
	
	// generates the appropriate size for the divided clock
	always_ff @(posedge clock) begin
		divided_clocks <= divided_clocks + 1;
	end
endmodule
