// module seg7 that defines which segments of four of the HEX displays
// on the DE-1 SoC board should be on or off depending on the 
// input combination of the switches on the DE-1 SoC board
module seg7 (UPC, HEX0, HEX1, HEX2, HEX3);
	// Creates input variable UPC for three of the switches on the
	// DE-1 SoC board with type logic
	input  logic  [2:0] UPC;
	// Creates output variables HEX0, HEX1, HEX2, HEX3 with type logic, each representing
	// the seven-segment HEX display on the DE-1 SoC board
	output logic  [6:0] HEX0, HEX1, HEX2, HEX3;

	// Sets the output depending on the case, or input, of UPC.
	always_comb begin
		case (UPC)
		//         Light: 6543210 Specifying the order of the segments of the HEX display
		// 								Since the HEX display is ACTIVE LOW, a LOW would keep
		// 								the segment on while a HIGH would turn it off
		// For the case of UPC = 000, a table will be illustrated using two HEX displays
		3'b000: begin
				  HEX1 = 7'b0101111; // table left half
				  HEX0 = 7'b0111011; // table right half
				  HEX2 = 7'b1111111;
				  HEX3 = 7'b1111111;
				  end
		
		// For the case of UPC = 001, pen will be written using three HEX displays
		3'b001: begin
				  HEX2 = 7'b0001100; // p
				  HEX1 = 7'b0000110; // e
				  HEX0 = 7'b0101011; // n
				  HEX3 = 7'b1111111;
				  end
		
		// For the case of UPC = 011, doll will be written using four HEX displays
		3'b011: begin
				  HEX3 = 7'b0100001; // d
				  HEX2 = 7'b1000000; // o
				  HEX1 = 7'b1000111; // l
				  HEX0 = 7'b1000111; // l
				  end
				  
		// For the case of UPC = 100, fish will be written using four HEX displays
		3'b100: begin
				  HEX3 = 7'b0001110; // f
				  HEX2 = 7'b1001111; // i
				  HEX1 = ~7'b1101101; // s
				  HEX0 = 7'b0001001; // h
				  end
		
		// For the case of UPC = 101, a chair will be illustrated using two HEX displays
		3'b101: begin
				  HEX1 = 7'b0101111; // chair leg
				  HEX0 = 7'b0111001; // chair legs and back
				  HEX2 = 7'b1111111;
				  HEX3 = 7'b1111111;
				  end
		
		// For the case of UPC = 110, a hat will be illustrated using three HEX displays
		3'b110: begin
				  HEX2 = 7'b1110111; // hat brim
				  HEX1 = 7'b0101011; // hat base
				  HEX0 = 7'b1110111; // hat brim
				  HEX3 = 7'b1111111;
				  end
				  
		// For all other cases, the output will not matter
		default: begin
				  HEX0 = 7'bX;
				  HEX1 = 7'bX;
				  HEX2 = 7'bX;
				  HEX3 = 7'bX;
				  end
		endcase
	end
endmodule