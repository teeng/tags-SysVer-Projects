/* 
 Lab 5 Task 2
 
 Plays from a note stored in memory, which, the data at each index of
		the memory is sent to write for each channel.
 Read and Writes only occur when ready, which is controlled by the top-level module task2.
 
 Inputs:
		clk is 1b clock responsible for input/output timing
		reset is 1b control signal for response on reset
 Output: writedata_left and writedata_right are the 24b data to write to the left and
		right channels
*/

`timescale 1 ps / 1 ps
module part2 (clk, reset, write, writedata_left, writedata_right);
	input clk, reset, write;
	output [23:0] writedata_left, writedata_right;

	// internal signals for controlling address of the memory
		// and the data from that address
	reg [16:0] addr;
	wire [23:0] data;
	
	// assign left and right channel writes to be the data from memory
		// at specified address
	assign writedata_left = data;
	assign writedata_right = data;
	
	// instantiated rom_1port module named romModule is the memory unit initialized with
		// the generated note
	// Inputs:
		// 17b address to determine which address in the memory unit the data should be from
		// 1b clock to control input and output timing
		// 24b data for what was stored in the memory at the specified address	
	rom_1port romModule (.address(addr), .clock(clk), .q(data));
	
	// determine the address to read at each clock cycle.
	// if at reset, set address to 0, otherwise:
		// if write is HIGH and the address is not the end address of the memory,
			// increment address by 1
		// if the address is the end address of the memory, set address back to the start (0)
	always @(posedge clk) begin
		if (reset) begin
			addr <= 17'b0;
		end else begin
			if (write && addr != 48000) begin
				addr <= addr + 17'b1;
			end
			if (addr == 48000) begin
				addr <= 17'b0;
			end
		end
	end
endmodule

// Test/Verify results of part1 module
module part2_testbench();
	reg clk, reset, write;
	wire [23:0] writedata_left, writedata_right;
	
	// instantiate part1 module for testing named dut
	part2 dut (.clk(clk), .reset(reset), .write(write),
				  .writedata_left(writedata_left), .writedata_right(writedata_right));
	
	// Set up clock for simulation
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		// Forever toggle the clock
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end 
	
	integer i;
	initial begin
		// model results of module with respect to expected behavior of the top-level module
		reset <= 1'b1;		@(posedge clk);
		reset <= 1'b0;
		
		// overall expect values are updated after two clock cycles (for when write is enabled/disabled)
			// as write signal is sent to the memory unit for one clock cycle, and
			// then the memory unit is read for another clock cycle
		
		// enable write
		// expect that writedata for each channel is the value stored in memory
			// as addr is internally incremented for each clock cycle
		write <= 1'b1;
		repeat(10) @(posedge clk);
		
		// disable write
		// expect that writedata does not update for each channel
		write <= 1'b0;
		repeat(10) @(posedge clk);
		
		// reenable write
		// expect that writedata updates for each channel
		write <= 1'b1;
		repeat(10) @(posedge clk);
	$stop;
	end
endmodule