// Top-level module DE1_SoC that defines the I/Os for the DE-1 SoC
// board with parameters HEX0, HEX1, HEX2, HEX3, LEDR, and SW

// The HEX0...HEX3 parameters will be for the 7-segment HEX display on the DE-1 SoC board
// The LEDR parameter will be for the red LEDs on the DE-1 SoC board
// the SW parameter will be for the switches on the DE-1 SoC board
module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);
	input  logic         CLOCK_50; // 50MHz clock.
	output logic  [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic  [9:0]  LEDR;
	// Key/Buttons are True when not pressed, False when pressed
	input  logic  [3:0]  KEY; 
	input  logic  [9:0]  SW;
	
	// Generate clk off of CLOCK_50, whichClock picks rate/frequency.
	logic reset;
	assign reset = !KEY[0];
	logic [31:0] div_clk;
	// Select 0.75 Hz clock 
	parameter whichClock = 25; 
	
	// instantiates a clock divider, which will make the clock cycle and its effects
	// more visible on the De1-SoC board.
	clock_divider cdiv (.clock(CLOCK_50), 
							  .reset(reset),
							  .divided_clocks(div_clk));
	
	// Clock selection; 
	// allows for easy switching between simulation and board clocks 
	logic clkSelect;

	// Uncomment ONE of the following two lines depending on intention
	//assign clkSelect = CLOCK_50;          // for simulation
	assign clkSelect = div_clk[whichClock]; // for synthesis on DE1_SoC board
			 
	// instantiates the main module for LEDR control, which is landing.
	// landing module takes input from SW[1] and SW[0] to control the output
	// LEDR[2:0]. The clock is set to the clock determined in this module, which
	// can be modified for simulation or for programming into the De1 SoC board.
	// reset is commanded by KEY[0] and is passed in to the landing module.
	landing s (.clk(clkSelect), .reset(reset), .SW(SW), .LEDR(LEDR[2:0]));
		 
	// Show signals on LEDRs to observe how the FSM is behaving
	 assign LEDR[9] = clkSelect;
	 assign LEDR[8] = reset;
endmodule

// Test and simulate the DE1_SoC module by testing every combination of switch inputs
// as well as testing key input (for reset) to verify design.
module DE1_SoC_testbench();
	logic         CLOCK_50;
	logic  [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic  [9:0]  LEDR;
	logic  [3:0]  KEY;
	logic  [9:0]  SW;
    
	DE1_SoC dut (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);
	
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
			CLOCK_50 <= 0;
			// Forever toggle the clock
			forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
	end
	
	// Test the design.
	initial begin
		repeat(1) @(posedge CLOCK_50);
		
																	@(posedge CLOCK_50);
									KEY[0] <= 0;				@(posedge CLOCK_50);
																	repeat(2) @(posedge CLOCK_50);
									KEY[0] <= 1;				@(posedge CLOCK_50); // Always reset FSMs at start
																	repeat(2) @(posedge CLOCK_50);
									SW[1] <= 0; SW[0] <= 0; @(posedge CLOCK_50);
																	repeat(4) @(posedge CLOCK_50);
													SW[0] <= 1; @(posedge CLOCK_50);
																	repeat(4) @(posedge CLOCK_50);
									SW[1] <= 1; SW[0] <= 0; @(posedge CLOCK_50);
																	repeat(4) @(posedge CLOCK_50);
													SW[0] <= 1; @(posedge CLOCK_50);
																	repeat(4) @(posedge CLOCK_50);
																	@(posedge CLOCK_50);
			$stop; // End the simulation.
		end 
endmodule 