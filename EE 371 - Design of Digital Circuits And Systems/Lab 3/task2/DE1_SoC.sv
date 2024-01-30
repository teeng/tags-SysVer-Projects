/*
 Lab 3 Task 2
 
 Animates a line moving across the screen. Can be erased by pressing KEY[3], and once erased,
 can be drawn again using KEY[0]
 Inputs:
	KEY - 4 pushbuttons on the DE1-SoC board, each represented by 1b, and therefore KEY is a total of 4b
	SW - 10 switches on teh DE-1 SoC board, each represented by 1b, and therefore SW is a total of 10b
	CLOCK_50 - 1b 50 Mhz clock responsible for timing
 Outputs:
	HEX0-5 - the 6 HEX displays on the DE1-SoC board, each represented by 7b, one for each of the
		LEDR segments within it. THerefore, each HEX is 7b
	LEDR - the 10 LEDRs on the De-1 SoC board, each represented by 1b, and therefore LEDR is a total of 10b
	VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS are all 1b signals to control the VGA display connected to the
		DE-1 SoC board
*/
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, CLOCK_50, 
	VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);
	// defining variables for working with De-1 SoC board
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	input CLOCK_50;
	
	// declaring variables for working with VGA display
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;
	
	// turn off HEX displays
	assign HEX0 = '1;
	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;
	
	// resetKey is set to KEY[0], which if KEY is pressed, reset the system and redraw the line
	// reset, midReset, and clearDrawing are internal variables meant to control when a new line
		// is being drawn or if the lines should be erased
	logic reset, resetKey, midReset, clearDrawing;
	assign resetKey = ~KEY[0];
	assign LEDR[0] = resetKey; // visual for reset
	
	
	// Setting the clock to be slower if being used on the De-1 SoC board,
	// but otherwise be at 50 MHz for simulation
	logic clkSelect;
	parameter whichClock = 20;
	logic [31:0] div_clk;
	clock_divider cdiv (.clock(CLOCK_50), .reset(resetKey), .divided_clocks(div_clk));
	
	// change which statement to assign clkSelect to depending on purpose (synthesis or simulation)
	//assign clkSelect = div_clk[whichClock]; // for synthesis
	assign clkSelect = CLOCK_50; // for simulation
	
	// internal variables for drawing pixels
	logic [9:0] x0, x1, x;
	logic [8:0] y0, y1, y;
	logic frame_start;
	logic pixel_color;
	
	
	// x0, y0, x1, and y1 all change between the values stored in x0Curr, y0Curr,
		// xCurr, and yCurr.
	// create variable for endpoint x and y to save across register
	logic [3:0][9:0] x0Curr, xCurr;
	logic [3:0][8:0] y0Curr, yCurr;
	
	// the arrays below are the coordinates to set x0, y0, and x1, and y1 to depending on 
		// at what point of the animation is running
	assign x0Curr[3:0] = {10'd135, 10'd85, 10'd0, 10'd0};
	assign y0Curr[3:0] = {9'd104, 9'd108, 9'd0, 9'd0};
	assign xCurr[3:0] = {10'd196, 10'd135, 10'd85, 10'd0};
	assign yCurr[3:0] = {9'd160, 9'd104, 9'd108, 9'd0};
		
	// index ensures that the correct coordinate is selected between all of the possible
		// coordinates used in drawing the lines
	logic [2:0] index;
	assign x0 = x0Curr[index];
	assign y0 = y0Curr[index];
	assign x1 = xCurr[index];
	assign y1 = yCurr[index];
	
	
	always_ff @(posedge clkSelect) begin
		if (reset) begin // reset is triggered if the drawing should be cleared
			index <= 1'b0; midReset <= 1'b1;
			reset <= 1'b0; 
		end else if (resetKey) begin // start drawing again if resetKey is pressed, which is KEY[0]
			index <= 1'b0; midReset <= 1'b1;
			reset <= 1'b0; clearDrawing <= 1'b0;
		end else if (x == x1 && y == y1) begin // if the target coordinate was reached, move
																// to the next set of coordinates in the above arrays
			index <= index + 1'b1;
			midReset <= 1'b1;
		end else if (index >= 1 && index < 4) begin	// otherwise, continue drawing lines
			midReset <= 1'b0;
		end
		if (~KEY[3]) begin // trigger a response to clear the drawing if KEY[3] is presseds
			clearDrawing <= 1'b1;
			reset <= 1'b1;
		end
	end
	
	// pixel color is black if clearing the drawing, and white if drawing lines at target coordinates
	assign pixel_color = ~clearDrawing;
	
	
	//////// DOUBLE_FRAME_BUFFER ////////
	logic dfb_en;
	assign dfb_en = 1'b0;
	/////////////////////////////////////
	
	// instantiate a VGA_framebuffer to control the VGA display connected
		// to the DE1_SoC.
	// timing is controlled by 1b CLOCK_50
	// reset is controlled by 1b KEY[0]
	// x, y are the current pixel coordinates, 10b and 9b respectively
	// pixelColor is the pixel color (white or black in this module and 1b in size)
	// pixel_write is set to 1b HIGH to always draw pixels
	// dfb_en is the double frame buffer enable of 1b
	VGA_framebuffer fb(.clk(CLOCK_50), .rst(resetKey), .x, .y,
				.pixel_color, .pixel_write(1'b1), .dfb_en, .frame_start,
				.VGA_R, .VGA_G, .VGA_B, .VGA_CLK, .VGA_HS, .VGA_VS,
				.VGA_BLANK_N, .VGA_SYNC_N);
	// instantiates a line_drawer to draw lines from (x0, y0) to (x1, y1),
		// with (x0, y0) and (x1, y1) changing
		// once the target coordinate (x1, y1) has been reached
	// Inputs:
		// clkSelect is the 1b selector for which clock to use
		// midReset is the 1b reset for the line drawer, which will update the x0, y0, x1, y1, x, and y values
		// x0 and y0 is the initial coordinate to draw a line from, 10b and 9b respectively
		// x1 and y1 is the final coordinate to draw a line to, 10b and 9b respectively
	// Output: x and y is the current coordinate between (x0, y0) and (x1, y1) to output to, 10b and 9b respectively
	line_drawer lines (.clk(clkSelect), .reset(midReset),
				.x0(x0), .y0(y0), .x1(x1), .y1(y1), .x(x), .y(y));
endmodule

// testbench for DE1_SoC to model outputs for different inputs and verify accuracy
module DE1_SoC_testbench();
	// declaring necessary variables for DE1_SoC module
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;
	logic CLOCK_50;

	logic [7:0] VGA_R;
	logic [7:0] VGA_G;
	logic [7:0] VGA_B;
	logic VGA_BLANK_N;
	logic VGA_CLK;
	logic VGA_HS;
	logic VGA_SYNC_N;
	logic VGA_VS;
	
	// instantiates DE1_SoC module named dut for testing
	DE1_SoC dut (.HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .KEY, .LEDR, .SW, .CLOCK_50, 
	.VGA_R, .VGA_G, .VGA_B, .VGA_BLANK_N, .VGA_CLK, .VGA_HS, .VGA_SYNC_N, .VGA_VS);
	
	// generates a forever cycling clock
	parameter CLOCK_PERIOD = 100;
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD / 2) CLOCK_50 <= ~CLOCK_50;
	end
	
	initial begin
		// upon reset, expect that the target coordinate is reached by x and y before switching
			// to the next target coordinate
		KEY[0] <= ~1'b1; KEY[3] <= ~1'b0;	@(posedge CLOCK_50);
		KEY[0] <= ~1'b0; 		  repeat (300) @(posedge CLOCK_50);
		// redraw the lines but with the opposite pixel color to erase them
		KEY[3] <= ~1'b1; 							@(posedge CLOCK_50);
		KEY[3] <= ~1'b0; 		  repeat (300) @(posedge CLOCK_50);
		$stop;
	end
	
endmodule