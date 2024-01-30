// module seg7 controls output to a hex display depending on count.
	// output leds is a number from 0 through 7 depending on how many rounds were
	// won by respective player.
// This module is based off the template given by Lab3.
module seg7 (count, leds);
	input  logic  [2:0] count;
	output logic  [6:0] leds;
	
	// count's value corresponds how many rounds a player has won
		// minus however many times they lost. The hex displays
		// the corresponding value by specifying exactly which segments are on or off.
	always_comb begin
		case (count)
			//          Light: 6543210
			default: leds = 7'b1111111; // none active
			3'b000: leds = ~7'b0111111; // 0
			3'b001: leds = ~7'b0000110; // 1
			3'b010: leds = ~7'b1011011; // 2
			3'b011: leds = ~7'b1001111; // 3
			3'b100: leds = ~7'b1100110; // 4
			3'b101: leds = ~7'b1101101; // 5
			3'b110: leds = ~7'b1111101; // 6
			3'b111: leds = ~7'b0000111; // 7
		endcase
	end
endmodule