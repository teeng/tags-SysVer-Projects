// LAB 2
// Top-level module DE1_SoC that defines the I/Os for the DE-1 SoC board
// with parameters HEX0, HEX1... HEX5, KEY, LEDR, and SW
// The HEX parameter will be for the 70segment displays on the DE-1 SoC board 
// The KEY parameter will be for the pushbuttons on the DE-1 SoC board
// The LEDR parameter will be for the red LEDs on the DE-1 SoC board
// the SW parameter will be for the switches on the DE-1 SoC board 

module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);   
	// Creates output variables HEX0...HEX5 that are the 6
	// 7-segment displays on the DE-1 SoC board with type logic
	output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	// Creates output variables LEDR[8]... LEDR[0] for the 9 red LEDs
	// on the DE-1 SoC board with type logic
	output logic [9:0]  LEDR;
	// Creates input variables KEY[2]... KEY[0] for the 3 pushbuttons
	// on the DE-1 SoC board with type logic
	input  logic [3:0]  KEY;
	// Creates input variables SW[8]... SW[0] for the 9 switches on the
	// DE-1 SoC board with type logic
	input  logic [9:0]  SW;
   
	// Sets each HEX variable to the efault value of '7'b1111111',
	// which turns off the HEX displays on the DE-1 SoC board
	assign HEX0 = 7'b1111111; 
	assign HEX1 = 7'b1111111;
	assign HEX2 = 7'b1111111;
	assign HEX3 = 7'b1111111;
	assign HEX4 = 7'b1111111;
	assign HEX5 = 7'b1111111;
	
	// Logic to check if SW[3]..SW[0] match to bottom-most digit of student
	// number, which is 4, and SW[7]..SW[4] to match the next digit of the student number,
	// which is also 4.
	// Result drives LEDR[0], with output high only if the switch configuration for
	// two fours are input, and no other combination.
	// For the bottom-most digit to be a 4, an input of SW[2] high with
	// SW[3], SW[1], and SW[0] low is required.
	// For the next digit to be a 4, an input of SW[6] high with
	// SW[7], SW[5], SW[4] low is required.
	// For both digits to be four and therefore set output LEDR[0] to high,
	// both SW[2] and SW[6] must be high and all other switches must be low.
	// This is the only combination of inputs where the output LEDR[0] is high.							
	not (v7, SW[7]);
	not (v5, SW[5]);
	not (v4, SW[4]);
	not (v3, SW[3]);
	not (v1, SW[1]);
	not (v0, SW[0]);
	
	and (out0, v3, SW[2]);
	and (out1, v1, v0);
	and (out2, v7, SW[6]);
	and (out3, v5, v4);
	
	and (LEDR[0], out0, out1, out2, out3);
	
	
endmodule


/*
Constructs a testbench, testing 
all possible input combinations
with a for loop, and a time delay of 10 units
*/
module DE1_SoC_testbench();
	// creates corresponding variables
	// for HEXs, LEDRs, KEYs, and SWs, with type logic
	logic  [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5; 
	logic  [9:0] LEDR; 
	logic  [3:0] KEY; 
	logic  [9:0] SW; 
	
	// sets up the DE1_SoC module for testing, named as dut
	DE1_SoC dut (.HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .KEY, .LEDR, 
	.SW);
	
	// tests every possible combination of the input signals for the DE1_SoC,
	// with a for loop and time delay of 10 time units.
	// Following the design of the DE1-SoC module, the only combination of inputs for
	// output LEDR[0] set to high is if both SW[2] and SW[6] are high
	// and all other switches are low. This corresponds to two 4s being the last
	// two digits of my student number. All other combination of inputs should
	// have the output LEDR[0] at low.
	integer i;
	initial begin
		SW[9] = 1'b0;
		SW[8] = 1'b0;
		for(i = 0; i <256; i++) begin
			SW[7:0] = i; #10;
		end
	end
endmodule
