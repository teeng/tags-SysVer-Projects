/*
Lab 6
*/


`timescale 1 ps / 1 ps
module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW, LEDR, V_GPIO);

	// define ports
	input  logic CLOCK_50;
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	input  logic [3:0] KEY;
	input  logic [9:0] SW;
	output logic [9:0] LEDR;
	inout  logic [35:23] V_GPIO;
	
	// global reset
	logic reset;
	assign reset = SW[9];
	
	logic hourIncTemp, hourInc, keyPress; // temp var for handling button press
	logic rushStartTrigger, rushEndTrigger; // internal logic to trigger datapath
														 // to record rush hour start or end
	
	logic [2:0] hour, hourTemp, // registers to record hour, previous hour
					rushStart, rushEnd; // rush hour start and end
	
	logic readTrigger; // readTrigger is for when hour 7 passes and the RAM should be read
	logic wren;	// write enable to the RAM
	logic [2:0] rdAddr, // rdAddr is read address for RAM
					rdAddrTemp, // rdAddrTemp is previous read address for RAm
					wrAddr; // wrAddr is the write address for RAM
														 
	logic [3:0] wrData, rdData; // register for the data to write to RAM, or the data read from RAM
	
	logic [3:0] numCarEntered; // register for recording the number of cars that have entered the lot
										// in each hour
	logic hourReset; // each hour, the number of cars that entered should reset to start incrementing again
	logic dayEnd; // internal signal for when the day has ended
	logic full; // internal signal for when the lot is full
	
	// Setting the clock to be slower if being used on the DE-1 SoC board,
	// but otherwise be at 50 MHz for simulation
	logic clkSlow;
	parameter whichClock = 25;
	logic [31:0] div_clk;
	clock_divider cdiv (.clock(CLOCK_50), .reset(reset), .divided_clocks(div_clk));
	assign clkSlow = div_clk[whichClock];
	
	
	// Current hour control
		// Metastability control for KEY[0] pushbutton
		// and resetting of values corresponding to each hour, as the hour switches to the next
	always_ff @(posedge CLOCK_50) begin
		if (reset) begin
			hour <= 3'b0;
			hourIncTemp <= 1'b0;
			hourInc <= 1'b0;
			hourReset <= 1'b1; // the RAM is constantly written to while hourReset is HIGH
									 // when hourReset goes LOW (for one clock cycle), the RAM switches to the next address
		end else begin
			hourIncTemp <= ~KEY[0]; // send keypress through two D_FFs for reducing change for metastable outputs
			hourInc <= hourIncTemp;
			hour <= hour + {2'b0, keyPress}; // increase hour by 1 if keypress read
			
			if ((hourInc || readTrigger) || (hour == 0 && (hourTemp == 7))) hourReset <= 1'b0;
			else			 																	 hourReset <= 1'b1;
		end
	end
	
	// RAM reading control
	always_ff @(posedge CLOCK_50) begin
		if (reset) begin
			hourTemp <= 3'b0;
			readTrigger <= 1'b0;
			rdAddrTemp <= 3'b0;
		end else begin
			if (hour == 0 && hourTemp == 7) readTrigger <= 1'b1; // day just ended, start reading from RAM
			
			hourTemp <= hour; // save the previous hour
			rdAddrTemp <= rdAddr; // save the previous read address
		end
	end
	
	always_ff @(posedge clkSlow) begin
	//always_ff @(posedge CLOCK_50) begin
		if (reset) rdAddr <= 3'b0;
		else begin
			// When reading from RAM, cycle through every address (will cycle 0-7, since address is 3b)
			if (readTrigger)	rdAddr <= rdAddr + 3'b1;
		end
	end
	
	logic enter_one_cycle;
	user_input enterCar (.clk(CLOCK_50), .reset, .in(V_GPIO[31]), .out(enter_one_cycle));
	
	// RAM writing control
	always_ff @(posedge CLOCK_50) begin
		if (reset) begin
			numCarEntered <= 4'b0;
		end else begin
			if (hourReset) begin // hourReset is usually HIGH
				wren <= 1'b1;
				wrData <= numCarEntered; // constantly recording the number of cars that entered for the current hour
				wrAddr <= hourTemp; // previous hour
			end else begin // when hourReset is LOW, do not write to RAM
				wren <= 1'b0;
				//numCarEntered <= 3'b0;
			end
			if (enter_one_cycle) numCarEntered <= numCarEntered + 4'b1; // increment number of cars entered anytime entrance gate opens
		end
	end
	
	
	
	// Rush hour control
	control ctrl_module (.clk(CLOCK_50), .reset(reset), .keyPress(hourInc), .park1(V_GPIO[28]),
								.park2(V_GPIO[29]), .park3(V_GPIO[30]),
								.enter(V_GPIO[23]), .exit(V_GPIO[24]), .keyPressConfirm(keyPress),
								.opengate_enter(V_GPIO[31]), .opengate_exit(V_GPIO[33]),
								.rushStartTrigger(rushStartTrigger), .rushEndTrigger(rushEndTrigger));
	// Rush hour datapath							
	datapath data_module (.clk(CLOCK_50), .reset(reset), .hour(hour),
								 .rushStartTrigger(rushStartTrigger), .rushEndTrigger(rushEndTrigger),
								 .rushStart(rushStart), .rushEnd(rushEnd));
	
	// RAM to store number of cars that entered at each hour
	ram8x4 mem_module (.clock(CLOCK_50), .data(wrData), .rdaddress(rdAddr), .wraddress(wrAddr),
							 .wren(wren), .q(rdData));

	hexControl hex_controller (.reset(reset), .full(full), .dayEnd(readTrigger), .hour({1'b0, hour}),
										.rushEnd({1'b0, rushEnd}), .rushStart({1'b0, rushStart}), .rdAddr({1'b0, rdAddr}),
										.rdData(rdData), .spaceLeft(2'b11 - V_GPIO[28] - V_GPIO[29] - V_GPIO[30]),
										.hex5(HEX5), .hex4(HEX4), .hex3(HEX3), .hex2(HEX2), .hex1(HEX1), .hex0(HEX0));
	
	assign full = V_GPIO[28] && V_GPIO[29] && V_GPIO[30]; // all parking spots occupied
	
	// FPGA output
	assign V_GPIO[26] = V_GPIO[28];	// LED parking 1
	assign V_GPIO[27] = V_GPIO[29];	// LED parking 2
	assign V_GPIO[32] = V_GPIO[30];	// LED parking 3
	assign V_GPIO[34] = full;	// LED full

	// FPGA input
	assign LEDR[0] = V_GPIO[28];	// Presence parking 1
	assign LEDR[1] = V_GPIO[29];	// Presence parking 2
	assign LEDR[2] = V_GPIO[30];	// Presence parking 3
	assign LEDR[3] = V_GPIO[23];	// Presence entrance
	assign LEDR[4] = V_GPIO[24];	// Presence exit

endmodule  // DE1_SoC


// Testbench for DE1_SoC module to verify outputs
module DE1_SoC_testbench();
	// creates corresponding variables to model DE1_SoC module
	
	// define ports
	logic CLOCK_50;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [3:0] KEY;
	logic [9:0] SW;
	logic [9:0] LEDR;
	wire [35:23] V_GPIO;
	
	
	// initializes DE1_SoC module for testing with name dut
	DE1_SoC dut (.*);
	
	// Set up a simulated clock
	parameter CLOCK_PERIOD=100;
	initial begin
		CLOCK_50 <= 0;
		// Forever toggle the clock
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
	end
	
	
	logic LEDpark1, LEDpark2, LEDpark3, LEDfull,
			park1, park2, park3, parkEn, parkEx, openEnGate, openExGate;
	// PRESENCE
	assign V_GPIO[23] = parkEn;
	assign V_GPIO[24] = parkEx;
	
	assign V_GPIO[28] = park1;
	assign V_GPIO[29] = park2;
	assign V_GPIO[30] = park3;
	
	// LEDs
	assign V_GPIO[26] = LEDpark1;
	assign V_GPIO[27] = LEDpark2;
	assign V_GPIO[32] = LEDpark3;
	assign V_GPIO[34] = V_GPIO[28] && V_GPIO[29] && V_GPIO[30];
	assign LEDfull = V_GPIO[34];
	
	// COMMAND
	assign V_GPIO[31] = openEnGate;
	assign V_GPIO[33] = openExGate;
	
	// creating integer for loop
	integer i;
	initial begin
		SW[9] <= 1'b1;    							@(posedge CLOCK_50); // reset at start
		SW[9] <= 1'b0;
		{park1, park2, park3, parkEn, parkEx} <= 5'b0;	// Presence parking/entrance/exit
		
		// first hour
		KEY[0] <= ~1'b1;					repeat(5)@(posedge CLOCK_50);
		KEY[0] <= ~1'b0;								@(posedge CLOCK_50);
	
		// second hour
		KEY[0] <= ~1'b1;								@(posedge CLOCK_50);
		KEY[0] <= ~1'b0;								@(posedge CLOCK_50);
		
		// car at entrance
		parkEn <= 1'b1;								@(posedge CLOCK_50);
		openEnGate <= 1'b1;							@(posedge CLOCK_50);
		parkEn <= 1'b0;
		openEnGate <= 1'b0;
		
		// car entered parking lot 1
		park1 <= 1'b1;
		LEDpark1 <= 1'b1;								@(posedge CLOCK_50);
		
		// car at entrance
		parkEn <= 1'b1;								@(posedge CLOCK_50);
		openEnGate <= 1'b1;							@(posedge CLOCK_50);
		parkEn <= 1'b0;
		openEnGate <= 1'b0;
		// car entered parking lot 2
		park2 <= 1'b1;
		LEDpark2 <= 1'b1;								@(posedge CLOCK_50);
		
		// car at entrance
		parkEn <= 1'b1;								@(posedge CLOCK_50);
		openEnGate <= 1'b1;							@(posedge CLOCK_50);
		parkEn <= 1'b0;
		openEnGate <= 1'b0;
		// car entered parking lot 3 (full)
		park3 <= 1'b1;
		LEDpark3 <= 1'b1;								@(posedge CLOCK_50);
												repeat(4)@(posedge CLOCK_50);
		// expected LEDFull to be HIGH, and for rushStart to be equal to the current hour
		// Now check rushEnd
		
		// car exited parking lot 1
		park1 <= 1'b0;
		LEDpark1 <= 1'b0;								@(posedge CLOCK_50);
		// car at exit	
		parkEx <= 1'b1;								@(posedge CLOCK_50);
		openExGate <= 1'b1;							@(posedge CLOCK_50);
		parkEx<= 1'b0;
		openExGate <= 1'b0;
		
		// car exited parking lot 2
		park2 <= 1'b0;
		LEDpark2 <= 1'b0;								@(posedge CLOCK_50);
		
		// car at exit
		parkEx <= 1'b1;								@(posedge CLOCK_50);
		openExGate <= 1'b1;							@(posedge CLOCK_50);
		parkEx<= 1'b0;
		openExGate <= 1'b0;
		
		// third hour
		KEY[0] <= ~1'b1;								@(posedge CLOCK_50);
		KEY[0] <= ~1'b0;								@(posedge CLOCK_50);
		
		
		// fourth hour
		KEY[0] <= ~1'b1;								@(posedge CLOCK_50);
		KEY[0] <= ~1'b0;								@(posedge CLOCK_50);
		// car exited parking lot 3 (empty)
		park3 <= 1'b0;
		LEDpark3 <= 1'b0;								@(posedge CLOCK_50);
		
		// car at exit
		parkEx <= 1'b1;								@(posedge CLOCK_50);
		openExGate <= 1'b1;							@(posedge CLOCK_50);
		parkEx<= 1'b0;
		openExGate <= 1'b0;
		
		// expected that rushEnd equals current hour
		
		
		// fifth hour
		KEY[0] <= ~1'b1;								@(posedge CLOCK_50);
		KEY[0] <= ~1'b0;								@(posedge CLOCK_50);
		// sixth hour
		KEY[0] <= ~1'b1;								@(posedge CLOCK_50);
		KEY[0] <= ~1'b0;								@(posedge CLOCK_50);
		// seventh hour
		KEY[0] <= ~1'b1;								@(posedge CLOCK_50);
		KEY[0] <= ~1'b0;								@(posedge CLOCK_50);
		// end of seventh hour
		KEY[0] <= ~1'b1;								@(posedge CLOCK_50);
		KEY[0] <= ~1'b0;								@(posedge CLOCK_50);
												 repeat(15) @(posedge CLOCK_50);
		
	$stop;
	end
endmodule