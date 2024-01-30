// module seg7 controls output to a hex display, specified by hex.
	// output is either number 1 or number 2 as determined by input playerWin.
// This module is based off the template given by Lab3, with the majority of other
	// possible outputs removed as they are unecessary for this project.
module seg7 (playerWin, hex);
	input  logic  [1:0] playerWin;
	output logic  [6:0] hex;
	
	// playerWin's value corresponds whichever player won. The hex displays
		// the corresponding value by specifying exactly which segments are on or off.
	always_comb begin
		case (playerWin)
			//          Light: 6543210
			default: hex = 7'b1111111; // none active
			2'b01: hex = 7'b1111001; // 1
			2'b10: hex = 7'b0100100; // 2
		endcase
	end
endmodule