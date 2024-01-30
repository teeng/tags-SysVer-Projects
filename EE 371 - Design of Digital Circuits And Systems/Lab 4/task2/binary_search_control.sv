/*
 Lab 4 Task 2

 This module is the control logic for the binary search algorithm
 accelerator.  This module manages a FSM to and outputs signals controlling
 data and variables needed to use binary search on a 32x8 word array.
 
 Parameters:
	Inputs:
		clk, reset are usual signals which input the clock and a reset for the
			system
		start is a single bit signal which is used to indicate that the data_i
			is valid and while start is up, the agorithm runs, when start is set
			back to 0, the algorithm is reset and ready to go again when start
			is set again
		data_i is the data that is sent from the datapath that is the loaded
			user input data which was set when start was set last.
		data_o is the data from the ram32x8 array which represents the data
			at the current address we are looking at
		size is a 6 bit value which represents the size of the array we are 
			currently viewing, and is used in computations for future search
			values for binary search
			
	Outputs:
		load_data is a control signal which is set when the system is waiting
			for start to be set
		data_big is a control signal which indicates that the user input data
			is larger than the data currently being read from the array
		data_small is a control signal which indicates that the user input
			data is smaller than the data currently being red from the array
		found_ctrl is a control signal to indicate that a matching value
			has been found in the array
		notFound_ctrl is a control signal which indicates there is no match
			in the array to the user input value
		check_zero is a control signal which indicates that we have checked
			every value in the array except address 0, so we should check that 
			last before declaring notFound_ctrl
*/

`timescale 1 ps / 1 ps
module binary_search_control (clk, reset, start, data_i, data_o, size,
										load_data, data_big, data_small, found_ctrl, 
										notFound_ctrl, check_zero);

	// i/o parameters
	input  logic clk, reset, start;
	input  logic [7:0] data_i, data_o;
	input  logic [5:0] size;
	output logic load_data, data_big, data_small, found_ctrl, notFound_ctrl, check_zero;
	

	// states for control
	enum logic [2:0] {s1, s2, s3, s4, s5, s6} ps, ns;
	
	// define next state logic
	always_comb begin
		case (ps)
			// waitng for start stage
			s1: 	if (start)				ns = s2;
					else						ns = s1;
			// curr_addr sent to RAM
			s2:								ns = s3;
			// compare data_o to given data
			s3:	if (data_i==data_o)	ns = s5;
					else						ns = s4;
			// check status of binary search
			s4:	if (size==0)			ns = s5;
					else						ns = s6;
			// extra wait one clk cycle
			s6:								ns = s2;
			// completed stage (found or not found)
			s5:	if (start)				ns = s5;
					else						ns = s1;
			default:							ns = s1;
		endcase
	end
	
		// if reset, go to s1, otherwise, go to the next state designated above
	always_ff @(posedge clk) begin
		if (reset) 	ps <= s1;
		else 			ps <= ns;
	end

	
	/* CONTROL SIGNALS */
	
	// load_data is reset state actions
	assign load_data 		= ((ps==s1) && (start==1'b0));
	
	// data_big is for when the curr_addr value is smaller than data_i
	assign data_big		= ((ps==s3) && (ns==s4) && (data_i>data_o));
	
	// data_small is for when the curr_addr value is bigger than data_i
	assign data_small		= ((ps==s3) && (ns==s4) && (data_i<data_o));
	
	// if we found address, this should be asserted
	assign found_ctrl		= ((ps==s3) && (ns==s5));
	
	// if we searched all address with no match this should be asserted
	assign notFound_ctrl	= ((ps==s4) && (ns==s5));
	
	// if we have searched all addresses except address 0 this address 
	// always checked last before exiting with a notFound signal
	assign check_zero		= ((ps==s4) && (ns==s6) && (size==1));
	
endmodule


module binary_search_control_testbench();
	logic clk, reset, start;
	logic [7:0] data_i, data_o;
	logic [5:0] size;
	logic load_data, data_big, data_small, found_ctrl, notFound_ctrl, check_zero;

	
	binary_search_control dut (.clk, .reset, .start, .data_i, .data_o, .size,
										.load_data, .data_big, .data_small, .found_ctrl, 
										.notFound_ctrl, .check_zero);
										
	// Set up a simulated clock to toggle (from low to high or high to low)
	// every 50 time steps
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;//toggle the clock indefinitely
	end
	
	integer i;
	initial begin
		reset <= 1'b1;					 @(posedge clk);
		reset <= 1'b0;
		
		// start is initially 0 to not yet start search algorithm. State should be in s1.
		// size of memory set to 32 at start
		start <= 1'b0; size <= 32;	 			@(posedge clk);
		
		// start algorithm, state transitions to s2.
		start <= 1'b1;					 			@(posedge clk);
		
		// check immediate match, should go to s3 for a clock cycle and then
			// indicate that data was found. Go to s5 for done until start is LOW,
			// which would make state transition back to s1
		data_o <= 8'b011;
		data_i <= 8'b011; 		  repeat(3) @(posedge clk);
		start <= 1'b0;				  repeat(3) @(posedge clk);
		
		data_o <= 8'b0; start <= 1'b1;		@(posedge clk);
		// check response to not immediately found data by running
			// a for loop to update data_0
		// since this for loop increments, data_big should go HIGH on each iteration,
			// indicating that finding data_i will require the larger half of the search scope
		// again, once data_o and data_i match, found goes HIGH and state transitions
			// to s5 until start goes LOW, then it returns to s1.
		for (i=0; i<5; i++) begin
			data_o <= i;			  repeat(3) @(posedge clk);
		end
										  repeat(2) @(posedge clk);
		start <= 1'b0;					 			@(posedge clk);
		
		
		data_o <= 8'b0;
		start <= 1'b1;					 			@(posedge clk);
		// check response to not immediately found data by running
			// a for loop to update data_0
		// since this for loop decrements, data_small should go HIGH on each iteration,
			// indicating that finding data_i will require the smaller half of the search scope
		for (i=5; i>0; i--) begin
			data_o <= i;			  repeat(3) @(posedge clk);
		end
										  repeat(2) @(posedge clk);
		start <= 1'b0;					 			@(posedge clk);
		
		// check if notFound goes HIGH by having size equal to 0
			// meaning searched the entire memory but the data was not found
		data_o <= 8'b0; size <= '0; 			@(posedge clk);
		start <= 1'b1;					 			@(posedge clk);
										  repeat(3) @(posedge clk);
		start <= 1'b0;				  repeat(3) @(posedge clk);
		
		// check address 0 with size = 1
		// where data would not be found (data_o and data_i do not match)
		data_o <= 8'b000; size <= 6'b1; start <= 1'b1; @(posedge clk);
														repeat(3)  @(posedge clk);
		start <= 1'b0;								repeat(2)  @(posedge clk);
	$stop;
	end

endmodule
