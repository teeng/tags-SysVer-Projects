/*
 Lab 4 Task 2

 This module is the datapath module for the binary search
 algorithm accelerator.  This module manages the variables and data
 which are used to implement the binary search algorithm.  It works
 in parallel to the control logic module using control signals as inputs
 
 Parameters:
	Inputs:
		clk, reset are usual signals which input the clock and a reset for the
			system
		data_i is the direct input from the user which can change at anytime
			regardless of clock cycle, thus we load it at set times depending 
			on control signals
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
			
	Outputs:
		found is a signal which is on when we have found a value and the address
			we are outputing is the solution
		notFound is a signal which is on when the given value is not found in the 
			array
		address_o is the output of the address we are currently working at, and it
			should only be taking as a valid signal when the found signal is on.
		data_ans is the user input data stored at the last load_data signal, and is
			mainly used for the control logic module
		size is a 6 bit value which represents the size of the array we are 
			currently viewing, and is used in computations for future search
			values for binary search and is primarily output for the control logic 
			module.
*/

`timescale 1 ps / 1 ps
module binary_search_datapath (clk, reset, data_i, load_data, data_big, 
										data_small, found_ctrl, notFound_ctrl, check_zero, 
										found, notFound, address_o, data_ans, size);

	// i/o parameters
	input  logic clk, reset;
	input  logic [7:0] data_i;
	input  logic load_data, data_big, data_small, found_ctrl, notFound_ctrl, check_zero;
	output logic found, notFound;
	output logic [4:0] address_o;
	output logic [7:0] data_ans;
	output logic [5:0] size;
	
	// internal logic signals
	logic [4:0] curr_addr;
	
	// internal logic
	assign address_o = curr_addr;
	
	// sequential logic for datapath variables
	always_ff @(posedge clk) begin
		// reset variables
		if (reset) begin
			curr_addr 	<= 5'b10000;
			size			<= 6'b100000;
			found			<= 1'b0;
			notFound		<= 1'b0;
		end else begin
			// load current input data
			if (load_data) begin
				data_ans 	<= data_i;
				curr_addr 	<= 5'b10000;
				size			<= 6'b100000;
				found			<= 1'b0;
				notFound		<= 1'b0;
			end 
			// change curr_addr to larger half
			else if (data_big) begin
				curr_addr	<= curr_addr + (size>>2);
				size			<= size >> 1;
				found			<= found;
				notFound		<= notFound;
				data_ans 	<= data_ans;
			end 
			// change curr_addr to smaller half
			else if (data_small) begin
				curr_addr	<= curr_addr - (size>>2);
				size			<= size >> 1;
				found			<= found;
				notFound		<= notFound;
				data_ans 	<= data_ans;
			end 
			// toggle found signal
			else if (found_ctrl) begin
				found			<= 1'b1;
				curr_addr 	<= curr_addr;
				size			<= size;
				notFound		<= notFound;
				data_ans 	<= data_ans;
			end 
			// toggle notFound signal
			else if (notFound_ctrl) begin
				notFound		<= 1'b1;
				curr_addr 	<= curr_addr;
				size			<= size;
				found			<= found;
				data_ans 	<= data_ans;
			end 
			// change curr_addr to zero
			else if (check_zero) begin
				curr_addr	<= '0;
				size			<= size;
				found			<= found;
				notFound		<= notFound;
				data_ans 	<= data_ans;
			end 
			// default
			else begin
				curr_addr 	<= curr_addr;
				size			<= size;
				found			<= found;
				notFound		<= notFound;
				data_ans 	<= data_ans;
			end
		end
	end
	
endmodule


module binary_search_datapath_tesetbench();

	logic clk, reset;
	logic [7:0] data_i;
	logic load_data, data_big, data_small, found_ctrl, notFound_ctrl, check_zero;
	logic found, notFound;
	logic [4:0] address_o;
	logic [7:0] data_ans;
	logic [5:0] size;
	

	binary_search_datapath dut (.clk, .reset, .data_i, .load_data, .data_big, 
										.data_small, .found_ctrl, .notFound_ctrl, .check_zero, 
										.found, .notFound, .address_o, .data_ans, .size);

	// clock setup
	parameter clock_period = 100;
	
	initial begin
		clk <= 0;
		forever #(clock_period /2) clk <= ~clk;
	end
	
		initial begin
		// reset
		reset  <= 1; 	data_i <= 8'b00001111;				
											repeat(2) 	@(posedge clk);
		reset  <= 0;					repeat(2) 	@(posedge clk);
		
		// load_data
		load_data  <= 1; 								@(posedge clk);
		load_data  <= 0;				repeat(2) 	@(posedge clk);
		
		// data_big
		data_big  <= 1; 								@(posedge clk);
		data_big  <= 0;				repeat(2) 	@(posedge clk);
		
		// data_small
		data_small  <= 1; 							@(posedge clk);
		data_small  <= 0;				repeat(2) 	@(posedge clk);
		
		// data_big
		data_big  <= 1; 								@(posedge clk);
		data_big  <= 0;				repeat(2) 	@(posedge clk);
		
		// found
		found_ctrl  <= 1; 							@(posedge clk);
		found_ctrl  <= 0;				repeat(2) 	@(posedge clk);

		// reset
		reset  <= 1; 					repeat(2) 	@(posedge clk);
		reset  <= 0;					repeat(2) 	@(posedge clk);
		
		// load_data
		load_data  <= 1; 								@(posedge clk);
		load_data  <= 0;				repeat(2) 	@(posedge clk);
		
		// data_big
		data_big  <= 1; 								@(posedge clk);
		data_big  <= 0;				repeat(2) 	@(posedge clk);
		
		// data_small
		data_small  <= 1; 							@(posedge clk);
		data_small  <= 0;				repeat(2) 	@(posedge clk);
		
		// data_big
		data_big  <= 1; 								@(posedge clk);
		data_big  <= 0;				repeat(2) 	@(posedge clk);
		
		// check_zero
		check_zero  <= 1; 							@(posedge clk);
		check_zero  <= 0;				repeat(2) 	@(posedge clk);
		
		// reset
		reset  <= 1; 					repeat(2) 	@(posedge clk);
		reset  <= 0;					repeat(2) 	@(posedge clk);
		
		// load_data
		load_data  <= 1; 								@(posedge clk);
		load_data  <= 0;				repeat(2) 	@(posedge clk);
		
		// data_big
		data_big  <= 1; 								@(posedge clk);
		data_big  <= 0;				repeat(2) 	@(posedge clk);
		
		// data_small
		data_small  <= 1; 							@(posedge clk);
		data_small  <= 0;				repeat(2) 	@(posedge clk);
		
		// data_big
		data_big  <= 1; 								@(posedge clk);
		data_big  <= 0;				repeat(2) 	@(posedge clk);
		
		// notFound_ctrl
		notFound_ctrl  <= 1; 						@(posedge clk);
		notFound_ctrl  <= 0;			repeat(2) 	@(posedge clk);

		$stop; // end simulation
		
	end  // initial
										
endmodule
