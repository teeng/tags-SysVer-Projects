// module computer creates a computer player to simulate button presses
// that will cause the center light to move right
	
// clk is the clock used for controlling input and output timing
// reset makes any simulated button presses from the computer count as misses,
	// therefore the light will not respond to button presses
// SW input is SW[8:0] on the DE1-SoC board, where highest difficulty is the
	// greatest input combination (SW[8] being MSB), and lowest difficulty is
	// with only SW[0] on
// tug is the output of whether the computer simulated a button press
module computer (clk, reset, SW, tug);
	input logic clk, reset;
	input logic [8:0] SW;
	output logic tug;
	
	// creates 10 bit variable lfsrOut to contain the random output from instantiated LFSRTen
	// compPress stores whether the button should be pressed or not
	logic [9:0] lfsrOut;
	logic compPress;
	
	// instantiated LFSRTen generates a random number, which is stored in lfsrOut,
		// and then transferred to compareTen, which checks if the switch input is greater
		// than the lfsrOut value. This is output to compPress.
	LFSRTen randGen (.clk(clk), .reset(reset), .out(lfsrOut));
	compareTen compPressCheck (.clk(clk), .A({1'b0, SW[8:0]}), .B(lfsrOut), .out(compPress));

	// tugCheck is an internal variable that is sent to inputDejammer to be sent through two flip-flops
		// and then eventually output as tug, which will be a button press.
	logic tugCheck;
	always_ff @(posedge clk) begin
		// on reset, any button presses are counted as misses
		if (reset)
			tugCheck <= 0;
		else
			tugCheck <= compPress;
	end
	
	// instantiated inputDug runs the button press through checks to see
		// if the button is held down over multiple clock cycles.
		// Also sends button press through inputDejammer within inputTug, which
			// attaches two flip flops to ensure stability and outputs result to tug
	inputTug comp (.clk(clk), .reset(reset), .key(tugCheck), .tug(tug));
	
endmodule


//Test/Simulate the State Machine
module computer_testbench();
	// creates corresponding variables to model inputDejammer module
	logic clk, reset;
	logic [8:0] SW;
	logic tug;
	
	// initializes inputDejammer module for testing with name dut
	computer dut (clk, reset, SW, tug);
	
	// Set up a simulated clock to toggle (from low to high or high to low)
	// every 50 time steps
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;//toggle the clock indefinitely
	end 

// Set up the inputs to the design.  Each line represents a clock cycle 
// Simulation observes increasing difficulty level as the input combination for
	// the switches increases in value. The higher the difficulty level the more
	// frequent the button will be pressed.
	integer i;
	initial begin
			reset <= 1;			 			  					@(posedge clk); // Always reset FSMs at start
			reset <= 0;	SW[8:0] = 9'b0;	  repeat(3) @(posedge clk);
				for (i=0;i<512;i++) begin
					{SW[8:0]} = i; 							@(posedge clk);
				end
			$stop; // End the simulation
		end
endmodule