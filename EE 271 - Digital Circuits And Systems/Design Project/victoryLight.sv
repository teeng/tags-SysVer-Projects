// module victoryLight defines additional functionality for a victory (top) light.

// clk is the clock used for controlling input and output timing
// reset turns the lights off on a new round
// F is true when forward key is pressed
// NB is true when the light backward is on
// lightOn is whether the light should turn on. Though, this only
	// happens very briefly since the frog is reset
	// to start once it reaches a victory light.
// win is whether the frog reached a victoryLight, 1 if it did.
module victoryLight (clk, reset, F, NB, lightOn, win);
	input logic clk, reset;
	input logic F, NB;
	// when lightOn is true, the light should be on.
	output logic lightOn;
	output logic win;
	
	
	// instantiates a frogLight for basic functionality of a frog light, turning on when it is reached,
		// specifying that this is not a center light
	frogLight victory (.clk(clk), .reset(reset), .roundWin(win), .L(1'b0), .R(1'b0), .F(F), .B(1'b0),
							 .NL(1'b0), .NR(1'b0), .NF(1'b0), .NB(NB), .center(1'b0), .lightOn(lightOn));
							  
	
	// player wins if the frog reaches a victory light by pressing forward when the next
		// bottom light is on.
	enum logic [1:0] {roundCont=2'b00, roundWin=2'b01, roundStop=2'b10} ps, ns; 
	// This logic describes all the possible state transitions from ps to ns
	always_comb begin
		win <= ps[0];
		case (ps)
			roundStop: 										ns = roundStop;
			roundWin:		 								ns = roundStop;
			roundCont: if (NB && F)						ns = roundWin;
						 else									ns = roundCont;
		endcase
	end
	
	// D-FF implementation
	always_ff @(posedge clk) begin
		// on reset, set state to one allowing play
		if (reset) begin
			ps <= roundCont;
		// otherwise, head to next state in state diagram
		end else
			ps <= ns;
	end
endmodule

//Test/Simulate the State Machine
module victoryLight_testbench();
	// creates corresponding variables to model victoryLight module
	logic clk, reset;
	logic F, NB;
	// when lightOn is true, the normal light should be on.
	logic lightOn;
	logic win;
	
	// initializes victoryLight module for testing with name dut
	victoryLight dut (clk, reset, F, NB, lightOn, win);
	
	// Set up a simulated clock to toggle (from low to high or high to low)
		// every 50 time steps
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;//toggle the clock indefinitely
	end 

// Simulation sends the state machine into various scenarios.
	initial begin
		reset <= 1;								    @(posedge clk); // Always reset FSMs at start
		reset <= 0;	// test player functionality with no button press, a button press but no adjacent light on,
							// and button press with the adjacent light on.
							// Expected results are that there is no response when only the button
								// is HIGH or no buttons are HIGH.
							// Expect a win when the forward button is pressed and the next bottom LED is on
								// and only one win occurs
						{F, NB} <= 2'b00; 										repeat(2) @(posedge clk);
						{F, NB} <= 2'b10; 										repeat(2) @(posedge clk);
		reset <= 1;															 					 @(posedge clk);
		reset <= 0;
						{F, NB} <= 2'b00; 										repeat(2) @(posedge clk);
						{F, NB} <= 2'b01; 										repeat(2) @(posedge clk);
		reset <= 1;															 					 @(posedge clk);
		reset <= 0;
						{F, NB} <= 2'b00; 										repeat(2) @(posedge clk);
						{F, NB} <= 2'b11; 										repeat(5) @(posedge clk);
						{F, NB} <= 2'b00; 										repeat(2) @(posedge clk);
						{F, NB} <= 2'b11; 										repeat(5) @(posedge clk);
		$stop; // End the simulation
	end
endmodule 