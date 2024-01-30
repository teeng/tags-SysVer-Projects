//This module describes the states and transitions associated with the state machine
//State machine has three inputs (clock, reset, SW), and three outputs, which are
//three LEDRs, and four states
module landing (clk, reset, SW, LEDR);
	// creates input variables clk and reset with type logic
	input logic  clk, reset;
	// creates input variables SW[9]... SW[0] with type logic. Only SW[1:0] will be used.
	input logic [9:0] SW;
	// creates output variables LEDR[2]... LEDR[0] with type logic.
	output logic [2:0] LEDR;
	
	//Present (ps) and Next (ns) states can be one of four options
	enum logic [2:0] {calm = 3'b101, all = 3'b010, turn0 = 3'b100, turn1 = 3'b001} ps, ns; 
	// This logic describes all the possible state transitions from ps to ns
	always_comb begin
		 case (ps)
			// if the state is currently at calm, then the circuit will
			// alternate between inner and outer LEDRs lit with inputs
			// SW[0] and SWp1[ both set to low.
			// Certain switch combinations do not occur (both SW[0] and SW[1] high,
			// and therefore, the state that they go to is defaulted to calm.
			calm: if (!SW[1] && !SW[0]) 				ns = all; // 00
					else if(!SW[1] && SW[0])			ns = turn0;
					else if(SW[1] && !SW[0])			ns = turn1;
					else										ns = all;
			// the all state is common in every state, and therefore controls
			// the majority of transitions between the states.
			all: if (!SW[1] && !SW[0])					ns = calm; // 00
					else if (!SW[1] && SW[0])			ns = turn0; // 01
					else if (SW[1] && !SW[0])			ns = turn1;
					else										ns = calm;
			
			// the turn0 state is the state where the leftmost LEDR is lit. This state
			// occurs only when turning.
			turn0: if (SW[1] && !SW[0])				ns = all; // 10
					else if (!SW[1] && SW[0])			ns = turn1; // 01
					else if (SW[1] && !SW[0])			ns = calm;
					else										ns = calm;
			
			// the turn1 state is the state where the rightmost LEDR is lit. This state
			// occurs only when turning/
			turn1: if (SW[1] && !SW[0])				ns = turn0; // 10
					else if (!SW[1] && SW[0])			ns = all; // 01
					else if (SW[1] && !SW[0])			ns = calm;
					else										ns = calm;
		endcase
	end

	// Output logic - could also be implemented as another always_comb block
	// Output to LEDR[2:0] matchest the present state, which is encoded
	// to represent which LEDR(s) in a sequence of three is lit
	assign LEDR[2:0] = ps;
	
	// D Flip Flop implementation (DFFs)
	always_ff @(posedge clk) begin
		if (reset)
			ps <= calm; //Returns to calm state when reset is active
		else
			ps <= ns; //Otherwise, advances to next state in state diagram
	end
endmodule

//Test/Simulate the State Machine
module landing_testbench();
	// creates corresponding variables to model landing module
	logic  clk, reset;
	logic [1:0] SW;
	logic [2:0] LEDR;
	
	// initializes landing module for testing with name dut
	landing dut (clk, reset, SW, LEDR);
	
	// Set up a simulated clock to toggle (from low to high or high to low)
	// every 50 time steps
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;//toggle the clock indefinitely
	end 

// Set up the inputs to the design.  Each line represents a clock cycle 
// Simulation sends the state machine into all three possible states
	initial begin
					// testing general functionality with every switch combination
																	@(posedge clk);
					reset <= 1;    							@(posedge clk); // Always reset FSMs at start
					reset <= 0; SW[1] <= 0; SW[0] <= 0; @(posedge clk);
													SW[0] <= 1; @(posedge clk);
									SW[1] <= 1; SW[0] <= 0; @(posedge clk);
													SW[0] <= 1; @(posedge clk);
																	@(posedge clk);
									
					// testing reset functionality with every input combination
					reset <= 1; SW[1] <= 0; SW[0] <= 0; @(posedge clk);
																	@(posedge clk);
					reset <= 0;	SW[1] <= 0; SW[0] <= 0; @(posedge clk);
																	@(posedge clk);
					reset <= 1; SW[1] <= 0;	SW[0] <= 1; @(posedge clk);
																	@(posedge clk);
					reset <= 0;	SW[1] <= 0; SW[0] <= 1; @(posedge clk);
																	@(posedge clk);
					reset <= 1;	SW[1] <= 1; SW[0] <= 0; @(posedge clk);
																	@(posedge clk);
					reset <= 0; SW[1] <= 1; SW[0] <= 0; @(posedge clk);
																	@(posedge clk);
					reset <= 1; SW[1] <= 1; SW[0] <= 1; @(posedge clk);
																	@(posedge clk);
					reset <= 0; SW[1] <= 1; SW[0] <= 1; @(posedge clk);

		 $stop; // End the simulation.
	end
endmodule 