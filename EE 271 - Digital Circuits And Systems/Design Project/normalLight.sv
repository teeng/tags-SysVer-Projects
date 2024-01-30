// module normalLight defines basic functionality for passing vehicles.

// clk is the clock used for controlling input and output timing
// reset will turn certain LEDs off when active
// dir is which direction the cars should head, 0 for right, 1 for left.
// lightOn specified which LEDs in a row of 6 LEDs is on or off.
module normalLight (clk, reset, dir, lightOn);
	input logic clk, dir, reset;
	output logic [5:0] lightOn;
	
	// ps and ns of the lights will allow for transitioning between states
	logic [5:0] ps, ns;
	// count specified which state to transition to. count is incremented or
		// decremented depending on dir.
	logic [2:0] count;
	// This logic describes all the possible states for a row of vehicle
		// lights.
	always_comb begin
		case (count)
			default: ns = 6'b000000;
			3'b000: ns = 6'b001100;
			3'b001: ns = 6'b100110;
			3'b010: ns = 6'b010011;
			3'b011: ns = 6'b001001;
			3'b100: ns = 6'b000100;
			3'b101: ns = 6'b100010;
			3'b110: ns = 6'b110001;
			3'b111: ns = 6'b011000;
		endcase
	end

	// D-FF implementation
	always_ff @(posedge clk) begin
			// on reset, turn LEDs off
			if (reset)
				ps <= 6'b0;
			else begin
			// otherwise head to next state,
			// which is determined by count
				// if heading right (dir is 0), then
					// increment count until a 7. Once approaching
					// 7, set count back to 0.
				// if heading right (dir is 1), then do the
					// reverse of above.
				ps <= ns;
					if(dir == 0) begin
						if(count < 7)	
							count <= count + 1;
						else 
							count <= 3'b0;
					end else begin
						if(count > 0)	
							count <= count - 1;
						else 
							count <= 3'b111;
					end
			end
	end
	
	// Output logic
	// Output to lightOn matches the present state, which is encoded
		// to represent whether each LED in the row is HIGH or LOW
	assign lightOn = ps;
endmodule


//Test/Simulate the State Machine
module normalLight_testbench();
	// creates corresponding variables to model normalLight module
	logic clk, reset, dir;
	// when lightOn is true, the corresponding LEDs should be on.
	logic [5:0] lightOn;
	
	// initializes normalLight module for testing with name dut
	normalLight dut (clk, reset, dir, lightOn);
	
	// Set up a simulated clock to toggle (from low to high or high to low)
	// every 50 time steps
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;//toggle the clock indefinitely
	end 

// Simulation sends the state machine from reset to the various states automatically 
	initial begin
		reset <= 1;										 					@(posedge clk); // Always reset FSMs at start
		// check movement for dir = 0
		// Expected result is that the LEDs are "animated" rightward
		reset <= 0; dir <= 0;	 			 		   repeat (10) @(posedge clk);
		reset <= 1;															@(posedge clk);
		// check movement for dir = 1
		// Expected result is that the LEDs are "animated" leftward
		reset <= 0; dir <= 1;	 			 		   repeat (10) @(posedge clk);
		$stop; // End the simulation
	end
endmodule 