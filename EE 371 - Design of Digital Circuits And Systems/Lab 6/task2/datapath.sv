`timescale 1 ps / 1 ps
module datapath (clk, reset, hour, rushStartTrigger, rushEndTrigger, rushStart, rushEnd);
	input logic reset, clk;
	input logic rushStartTrigger, rushEndTrigger;
	input logic [2:0] hour;
	output logic [2:0] rushStart, rushEnd;
	
	always_ff @(posedge clk) begin
		if (reset) begin
			rushStart <= 3'b0; rushEnd <= 3'b0;
		end else begin
			if (rushStartTrigger)	rushStart <= hour;
			else							rushStart <= rushStart;
			if (rushEndTrigger)		rushEnd <= hour;
			else							rushEnd <= rushEnd;
		end
	end
endmodule

module datapath_testbench();
	logic reset, clk;
	logic rushStartTrigger, rushEndTrigger;
	logic [2:0] hour;
	logic [2:0] rushStart, rushEnd;
	
	datapath dut (.*);
	
	// Set up a simulated clock to toggle (from low to high or high to low)
	// every 50 time steps
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		// Forever toggle the clock
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end		
	
	integer i;
	initial begin
		reset <= 1'b1;	@(posedge clk);
		reset <= 1'b0;
		
		hour <= 3'b1;		
		// when rushStartTrigger goes HIGH, rushStart = hour (1)
		rushStartTrigger <= 1'b1;						 @(posedge clk);
		rushStartTrigger <= 1'b0;			repeat(2) @(posedge clk);
		
		hour <= 3'b011;
		// when rushStartTrigger goes HIGH, rushStart = hour (3)
		rushStartTrigger <= 1'b1;						 @(posedge clk);
		rushStartTrigger <= 1'b0;			repeat(2) @(posedge clk);
		
		
		hour <= 3'b1;		
		// when rushEndTrigger goes HIGH, rushEnd = hour (1)
		rushEndTrigger <= 1'b1;						 @(posedge clk);
		rushEndTrigger <= 1'b0;			repeat(2) @(posedge clk);
		
		hour <= 3'b011;
		// when rushEndTrigger goes HIGH, rushEnd = hour (3)
		rushEndTrigger <= 1'b1;						 @(posedge clk);
		rushEndTrigger <= 1'b0;			repeat(2) @(posedge clk);
		repeat(3) @(posedge clk);
		
	$stop;
	end
endmodule