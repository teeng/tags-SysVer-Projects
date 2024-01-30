/*
Lab 1

This module describes the states and transitions associated with the two sensors
at the parking lot gate, where the states are one of these four:
	neither sensor detects anything
	sensor A detects something but sensor B does not
	sensor B detects something but sensor A does not
	sensors A and B both detect something
Inputs:
	clk: 1b clock to control timing for inputs and outputs
	reset: 1b signal to set sensors to default behavior
	ab: 2b representing reading from the sensors,
		where a is the signal from sensor A that it does/doesn't detect something
		where b is the signal from sensor B that it does/doesn't detect something
Output:
	dir: 2b for which direction the vehicle is heading (entering or exiting)
		depending on what the sensors have read
*/
module sensor (clk, reset, ab, dir);
	input logic  clk, reset;
	input logic [1:0] ab;
	output logic [1:0] dir;
	
	
	logic [1:0] checkChange; // 2b tracker for whether the car has changed direction from its original direction
										// for ex: if the car started entering the lot, but at some point reversed direction
										// to be exiting, but the parking lot counter should not change
	logic dirTrigger; // 1b tracker for once direction is determined, and prevents any inputs from future
								// changes in direction until a car has fully entered or exited
	logic carConfirm; // 1b tracker for whether the sensors detect a car, which is if input 2'b11 is recieved
	logic [1:0] prevS; // 2b tracker for previous state, which ensures output dir is sends signal for one clock cycle
								// immediately after the car has fully entered or exited, and no other time
	
	
	// Present (ps) and Next (ns) states can be one of four options
	enum logic [1:0] {empty = 2'b00, bumpA = 2'b10, bumpB = 2'b01, full = 2'b11} ps, ns; 
	// This logic describes all the possible state transitions from ps to ns
	always_comb begin
		case (ps)
		// the gate is empty, no car present
		empty: if (ab == 2'b01) 					ns = bumpB; // if sensor B detects something, the car bumper is at position B
				else if (ab == 2'b10)				ns = bumpA; // if sensor A detects something, the car bumper is at position A
				else if (ab == 2'b00)				ns = empty; // stay at empty if neither sensor detects something
				else 										ns = empty; // impossible input, stay at empty
		
		// something detected at the gate in front of sensorA
		bumpA: if (ab == 2'b00)						ns = empty; // if neither sensor detects anything, the gate is empty
				else if (ab == 2'b11)				ns = full; // if both sensors detects something, the gate is full
				else if (ab == 2'b10)				ns = bumpA; // if sensor A detects something, stay at bumpA
				else										ns = bumpA; // impossible input, stay at bumpA
		
		// something detected at the gate in front of sensor B
		bumpB: if (ab == 2'b00)						ns = empty; // if neither sensor detects anything, the gate is empty
				else if (ab == 2'b11)				ns = full; // if both sensors detects something, the gate is full
				else if (ab == 2'b01)				ns = bumpB; // if sensor B detects something, stay at bumpB
				else										ns = bumpB; // impossible input, stay at bumpB
		
		// car detected at the gate in front of both sensors
		full: if (ab == 2'b01)						ns = bumpB; // if sensor B detects something, the car bumper is at position B
				else if (ab == 2'b10)				ns = bumpA; // if sensor A detects something, the car bumper is at position A
				else if (ab == 2'b11)				ns = full; // if both sensors detects something, stay at full
				else										ns = full; // impossible input, stay at full
		endcase
	end
	
	// At every clock cycle, determine the direction of the car present at the gate, or if there is
		// no car present at the gate
	// D Flip Flop implementation (DFFs)
	always_ff @(posedge clk) begin
		// upon reset, present state of the gate is empty
		if (reset) begin
			ps <= empty;
		// if not reset, present state of the gate goes to next state in state diagram
			// set previous state (prevS) to the present state
			// and perform additional checking for the direction of the car
		end else begin
			ps <= ns;
			prevS <= ps;
			// When the gate detects something in front of the sensors, and direction has not yet been determined
				// set checkChange to the current state, which represents the initial direction of the assumed vehicle
				// later logic determines if it is actually a vehicle
				// Also set that direction has been determined
			if ((ps == bumpA || ps == bumpB) && !dirTrigger) begin
				checkChange <= ps;
				dirTrigger <= 1'b1;
			end
			
			// If the gate is currently empty, this could mean a vehicle has not passed through the gate yet,
				// or has completely gone through the gate, meaning the direction of the car should be output
			if (ps == empty) begin
				dirTrigger <= 1'b0; // set to LOW so that another car may pass through the gate and trigger a direction recording
				
				// If confirmed to be a vehicle, output the direction the vehicle was moving (enter or exit)
					// This is controlled by the recorded direction that was determined above when dirTrigger was set
						// and outputs the same clock cycle as when the gate is first empty, meaning the previous state
						// of the gate was that the car was almost completely passed through
				if (carConfirm) begin
					if ((checkChange == bumpB) && (prevS == 2'b10)) begin
						dir <= 2'b01; // exit
					end else if ((checkChange == bumpA) && (prevS == 2'b01)) begin
						dir <= 2'b10; // enter
					end else if (((checkChange != bumpA) || (prevS != 2'b01)) ||
									 ((checkChange != bumpB) || (prevS != 2'b10))) begin
						dir <= 2'b00;
					end
				// If not confirmed to be a car, dir set to 2'b00, as it is a pedestrian
				end else begin
					dir <= 2'b00;
				end
			end
			
			// If the gate is not both empty and has a car passing through it, the direction should not be updated
			if (!(ps == empty && carConfirm)) begin
				dir <= 2'b00;
			end
			
			// If the gate is full, this means both sensors recieve input, meaning a car is at the gate
				// update carConfirm to HIGH
			// Otherwise, if the direction of the object at the gate has not been confirmed (meaning the sensors
				// have only first encountered this object and even if it was a car, it has not entered the gate
				// fully yet) then keep carConfirm to LOW
			if (ps == full) begin
				carConfirm <= 1'b1;
			end else begin
				if (!dirTrigger) begin
					carConfirm <= 1'b0;
				end
			end
		end		
	end
endmodule	


// Test/Simulate Sensor state machine
module sensor_testbench();
	// creates corresponding variables to model sensor module
	logic  		clk, reset;
	logic [1:0] ab;
	logic [1:0] dir;
	
	// initializes sensor module for testing with name dut
	sensor dut (clk, reset, ab, dir);
	
	// Set up a simulated clock to toggle (from low to high or high to low)
	// every 50 time steps
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		// Forever toggle the clock
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end 

	
// Set up the inputs to the design.  Each line represents a clock cycle unless containing a repeat
// Simulation sends the state machine into all four possible states
	integer i;
	initial begin
			reset <= 1;    							@(posedge clk); // reset FSM at start
			reset <= 0;	ab <= 2'b00;				@(posedge clk); // start with both sensors reading nothing
												repeat(2)@(posedge clk);
			
			// Simulate a car entering the parking lot, appearing at sensor A first and at sensor B last
				// output dir should be 2'b10
			ab <= 2'b10;    							@(posedge clk);
			ab <= 2'b10;    							@(posedge clk);
			ab <= 2'b11;    							@(posedge clk);
			ab <= 2'b11;    							@(posedge clk);
			ab <= 2'b11;    							@(posedge clk);
			ab <= 2'b11;    							@(posedge clk);
			ab <= 2'b01;    							@(posedge clk);
			ab <= 2'b01;    							@(posedge clk);
			ab <= 2'b00;    							@(posedge clk);
			ab <= 2'b00;    							@(posedge clk);
							    				repeat(2)@(posedge clk);
															
			// Simulate a car exiting the parking lot, appearing at sensor B first and at sensor A last
				// output dir should be 2'b01
			ab <= 2'b01;    							@(posedge clk);
			ab <= 2'b11;    							@(posedge clk);
			ab <= 2'b11;    							@(posedge clk);
			ab <= 2'b10;    							@(posedge clk);
			ab <= 2'b10;    							@(posedge clk);
			ab <= 2'b00;    							@(posedge clk);
							    							@(posedge clk);
															
															
			// Simulate a pedestrian at the parking lot, appearing at sensor B first and at sensor A last,
				// but never occupying both sensors like a car would
				// output dir should be 2'b00
			ab <= 2'b10;    							@(posedge clk);
			ab <= 2'b01;    							@(posedge clk);
			ab <= 2'b00;    							@(posedge clk);
							    							@(posedge clk);
															
			// Simulate a car entering the parking lot, appearing at sensor A first and at sensor B last,
				// but changing direction within the gate before eventually fully entering
				// output dir should be 2'b10
			ab <= 2'b10;    							@(posedge clk);
			ab <= 2'b11;    							@(posedge clk);
			ab <= 2'b10;    							@(posedge clk);
			ab <= 2'b10;    							@(posedge clk);
			ab <= 2'b11;    							@(posedge clk);
			ab <= 2'b01;    							@(posedge clk);
			ab <= 2'b00;    							@(posedge clk);
							    				repeat(5)@(posedge clk);
												
			// Simulate cars consecutively entering the parking lot,
				// output dir should be 2'b10 at the end of each loop but 2'b00 otherwise			
			for (i = 0; i < 5; i++) begin
				ab <= 2'b10;    						@(posedge clk);
				ab <= 2'b11;    						@(posedge clk);
				ab <= 2'b01;    						@(posedge clk);
				ab <= 2'b00;    						@(posedge clk);
			end

		 $stop; // End the simulation.
	end
endmodule 