/*
Lab 1

Top-level module DE1_SoC that defines the I/Os for the DE-1 SoC board
DE-1 SoC board was connected virtually in Labsland, with a breadboard
containing three switches and two LEDs connected to the GPIO_0 pins

Parameters:
	GPIO_0: 34 pins on the DE-1 SoC board that can be set as input or output,
		and therefore can be controlled by input switches or control output LEDs
		with a 34b size.
	CLOCK_50: 1b input 50 MHz clock for consistent timing across the DE-1 SoC board
	HEX0 through HEX5: Six total HEX displays on the DE-1 SoC board that each contain
		seven LEDR segments (and therefore size 7b each), which can be individually set HIGH or LOW.
		Segments are active LOW.
		
This module is the overall controller to count the number of vehicles present in the parking lot,
	after vehicles enter or leave, starting with the parking lot clear of vehicles.
Cars entering or leaving are illustrated with two LEDs, which represent
	two sensors observing the gate for any vehicles entering or exiting.
	The cars are controlled by two switches by their direction.
*/
module DE1_SoC (GPIO_0, CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	input  logic       CLOCK_50;
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	inout logic [33:0] GPIO_0;
	
	// 1b reset signal for all operations
	logic reset;				  
	assign reset = GPIO_0[5]; // GPIO_0[5] is connected to SW2 on breadboard and recieves its input
	
	
	//====SENSORS====
	// dir = 2b representation of the direction of vehicle as determined by sensors
		// 2'b00 = no direction (car not present)
		// 2'b01 = car exiting (appeared at gate from the right)
		// 2'b10 = car entering (appeared at gate from the left)
	logic [1:0] dir;
	
	// Instantiated sensor named sensorSyst which outputs the direction of the vehicle
		// if the vehicle has completely passed through the gate, meaning,
		// the count of the number of cars in the parking lot should change.
	// inputs:
		// CLOCK_50 = 1b signal to match timing control of the DE-1 SoC board
		// reset = 1b signal match the reset signal of the DE-1 SoC board
		// GPIO_0[6] and GPIO_[0] = a 2b bus from two switches, SW0 and SW1 on the breadboard.
	// output: dir = direction of the vehicle (entering, exiting, or not present)
	sensor sensorSyst (.clk(CLOCK_50), .reset(reset), .ab({GPIO_0[6], GPIO_0[8]}), .dir(dir));
	
	
	//====COUNTER====
	// count = number of vehicles in the parking lot, which updates for every vehicle that
		// enters or exits. Is 5b long to with a minimum count of 0, but accomodates for the
		// maximum of 25 cars in the parking lot.
	logic [4:0] count;
	
	// Instantiated counter named tracker updates for every vehicle that enters or exits.
	// inputs:
		// CLOCK_50 = 1b signal to match timing control of the DE-1 SoC board
		// reset = 1b signal match the reset signal of the DE-1 SoC board
		// dir[1] = bit that represents a car has entered, controlled by instantiated sensor above
		// dir[0] = bit that represents a car has exited, controlled by instantiated sensor above
	// output: count = updated number of cars in the parking lot
	counter tracker (.clk(CLOCK_50), .reset(reset), .inc(dir[1]), .dec(dir[0]), .out(count));
	
	
	//====DISPLAY====
	// Breadboard LED connections
	assign GPIO_0[26] = GPIO_0[6]; // leftmost switch (SW0) connected to GPIO_0[26] powers leftmost LED,
													// which is connected to GPIO_0[6]
	assign GPIO_0[27] = GPIO_0[8]; // middle switch (SW1) connected to GPIO_0[27] powers rightmost LED,
													// which is connected to GPIO_0[8]
	// Instantiated hexControl named display controls the six total HEX displays on the DE-1 SoC board,
		// updating their values based on the number of cars in the parking lot
	// Upon reset, HEXs display CLEAR0 for 0 cars in the parking lot. At maximum of 25 cars, HEXs display FULL25.
	// input: count = 5b bus limited to 0 to 25, updated for every car that enters and exits, starts at 0.
	// outputs:
		// HEX5 through HEX0 = 7b each to control seven LEDR segments and display numbers or letters
	hexControl display (.reset(reset), .count(count), .hex5(HEX5), .hex4(HEX4), .hex3(HEX3), .hex2(HEX2), .hex1(HEX1), .hex0(HEX0));
	
endmodule


// Testbench for DE1_SoC module to verify outputs
module DE1_SoC_testbench();
	// creates corresponding variables to model DE1_SoC module
	
	wire [33:0] GPIO_0;
	logic CLOCK_50;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	

	// logic a, b are the 1b input signals representing the two switches, SW1 and SW0 connected to GPIO_0
		// which further represent the two sensors, sensor A and sensor B
	// logic swReset is the 1b input signal from the reset switch connected to GPIO_0 (SW2)
	logic a, b, swReset;
	
	// initializes DE1_SoC module for testing with name dut
	DE1_SoC dut (.GPIO_0, .CLOCK_50, .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5);
	
	// Set up a simulated clock
	parameter CLOCK_PERIOD=100;
	initial begin
		CLOCK_50 <= 0;
		// Forever toggle the clock
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
	end
	
	// represent the GPIO_0 pins as the earlier-defined logic variables for easier control and readability
	assign GPIO_0[5] = swReset;
	assign GPIO_0[6] = a;
	assign GPIO_0[8] = b;
	
	// creating integer for loop
	integer i;
	initial begin
			swReset <= 1'b1;    							@(posedge CLOCK_50); // reset at start
			swReset <= 1'b0;
			
			{a, b} <= 2'b00;								@(posedge CLOCK_50); // start gate as empty
												  repeat(2) @(posedge CLOCK_50);
			
			// testing cars consecutively entering, with varying time spent in front of the sensors
			// dir should be 2'b10 at the end of each loop, but be 2'b00 otherwise,
				// representing a single car entering at a time
			for (i=0;i < 5; i++) begin
				{a, b} <= 2'b10;	@(posedge CLOCK_50);
				{a, b} <= 2'b11;  @(posedge CLOCK_50);
				{a, b} <= 2'b11;  @(posedge CLOCK_50);
				{a, b} <= 2'b11;  @(posedge CLOCK_50);
				{a, b} <= 2'b01;  @(posedge CLOCK_50);
				{a, b} <= 2'b01;  @(posedge CLOCK_50);
				{a, b} <= 2'b00;  @(posedge CLOCK_50);
				{a, b} <= 2'b00;  @(posedge CLOCK_50);
				{a, b} <= 2'b00;  @(posedge CLOCK_50);
				
			end			
																@(posedge CLOCK_50);
			
			// testing cars consecutively exiting, with varying time spent in front of the sensors
			// dir should be 2'b01 at the end of each loop, but be 2'b00 otherwise,
				// representing a single car exiting at a time
			for (i=0;i < 5; i++) begin
				{a, b} <= 2'b01;	@(posedge CLOCK_50);
				{a, b} <= 2'b01;	@(posedge CLOCK_50);
				{a, b} <= 2'b11;  @(posedge CLOCK_50);
				{a, b} <= 2'b11;  @(posedge CLOCK_50);
				{a, b} <= 2'b11;  @(posedge CLOCK_50);
				{a, b} <= 2'b10;  @(posedge CLOCK_50);
				{a, b} <= 2'b10;  @(posedge CLOCK_50);
				{a, b} <= 2'b10;  @(posedge CLOCK_50);
				{a, b} <= 2'b00;  @(posedge CLOCK_50);
				{a, b} <= 2'b00;  @(posedge CLOCK_50);
				
			end
																@(posedge CLOCK_50);
															
															
			// checking if a pedestrian, and not a car is entering a gate
				// in other words: the sensors at the gate are not fully blocked
			// dir should be 2'b00 representing no car entering or exiting
			{a, b} <= 2'b10;    							@(posedge CLOCK_50);
			{a, b} <= 2'b01;    							@(posedge CLOCK_50);
			{a, b} <= 2'b00;    							@(posedge CLOCK_50);
																@(posedge CLOCK_50);
															
			// checking change of direction within the gate, or reversing withing the gate
				// in other words: the car did not fully enter or exit
			// dir should be 2'b00 representing no car entering or exiting
			{a, b} <= 2'b10;    							@(posedge CLOCK_50);
			{a, b} <= 2'b11;    							@(posedge CLOCK_50);
			{a, b} <= 2'b10;    							@(posedge CLOCK_50);
			{a, b} <= 2'b00;    							@(posedge CLOCK_50);
			{a, b} <= 2'b10;    							@(posedge CLOCK_50);
			{a, b} <= 2'b10;    							@(posedge CLOCK_50);
			{a, b} <= 2'b11;    							@(posedge CLOCK_50);
			{a, b} <= 2'b11;    							@(posedge CLOCK_50);
			{a, b} <= 2'b01;    							@(posedge CLOCK_50);
			{a, b} <= 2'b00;    							@(posedge CLOCK_50);
												 repeat(10) @(posedge CLOCK_50);
		
			// Going above 25 on count. dir should be 2'b10 at the end of each loop
			// After reach 25, dir should not update
			for (i=0;i < 30; i++) begin
				{a, b} <= 2'b10;	@(posedge CLOCK_50);
				{a, b} <= 2'b11;  @(posedge CLOCK_50);
				{a, b} <= 2'b01;  @(posedge CLOCK_50);
				{a, b} <= 2'b00;  @(posedge CLOCK_50);
				
			end			
												 repeat(10) @(posedge CLOCK_50);
		
	$stop;
	end
endmodule