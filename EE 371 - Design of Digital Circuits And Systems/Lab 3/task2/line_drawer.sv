/*
 Lab 3 Task 2
*/
module line_drawer(
	input logic clk, reset,
	
	// x and y coordinates for the start and end points of the line
	input logic [9:0]	x0, x1, 
	input logic [8:0] y0, y1,

	//outputs cooresponding to the coordinate pair (x, y)
	output logic [9:0] x,
	output logic [8:0] y 
	);
	
	// internal logic registers for computation
	logic signed [11:0] error;
	logic signed [10:0] dx; 
	logic signed [9:0] dy;
	logic [9:0] x0_final, x1_final;
	logic [8:0] y0_final, y1_final;
	
   // internal control signals
	logic is_steep;
	
	// assign delta values
	// if x1>x0 then dx = x1-x0 and vice versa
	assign dx = (x1>x0) ? (x1-x0) : (x0-x1);
	assign dy = (y1>y0) ? (y1-y0) : (y0-y1);
	
	// assign value for is_steep
	// from pseudocode -> abs(dy)>abs(dx)
	assign is_steep = dy>dx;
	
	// combinational logic to setp up final inputs
	// swap inital inputs based on is_steep
	// also swap based on e.g. x0>x1
	always_comb begin
		if (is_steep) begin
			if (y0>y1) begin
				x0_final = x1;
				x1_final = x0;
				y0_final = y1;
				y1_final = y0;
			end else begin
				x0_final = x0;
				x1_final = x1;
				y0_final = y0;
				y1_final = y1;
			end
		end else begin 
			if (x0>x1) begin
				x0_final = x1;
				x1_final = x0;
				y0_final = y1;
				y1_final = y0;
			end else begin
				x0_final = x0;
				x1_final = x1;
				y0_final = y0;
				y1_final = y1;
			end
		end
		
	end
	
	// use final inputs to output pixel values
	// sequential logic
	always_ff @(posedge clk) begin
		if (reset) begin
			x <= x0_final;
			y <= y0_final;
			if (is_steep)	error <= -(dy/2);
			else				error <= -(dx/2);
		end
		// not steep:
		// iterate x value, calculate y
		else if ((~is_steep) && (x<x1_final)) begin
			if ((dy + error)>=0) begin
				error <= error + dy - dx;
				// iterate y based on calcs
				if (y1_final>y0_final) 	y <= y + 1'b1;
				else							y <= y - 1'b1;
			end else 
				error <= error + dy;
			// iteration
			x <= x + 1'b1;
		end
		// steep:
		// iterate y value, calculate x
		else if ((is_steep) && (y<y1_final)) begin
			if ((dx + error)>=0) begin
				error <= error + dx - dy;
				// iterate x based on calcs
				if (x1_final>x0_final) 	x <= x + 1'b1;
				else							x <= x - 1'b1;
			end else
				error <= error + dx;
			// iteration
			y <= y + 1'b1;
		end
	end
	  
endmodule


// Test and simulate the DE1_SoC module by testing every combination of switch inputs
// as well as testing key input (for reset) to verify design.
module line_drawer_testbench();
	logic clk, reset;
	logic [9:0]	x0, x1; // 10b x
	logic [8:0] y0, y1; // 9b y
	logic [9:0] x;
	logic [8:0] y;
    
	line_drawer dut (.clk, .reset, .x0, .x1, .y0, .y1, .x, .y);
	
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		// Forever toggle the clock
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	// Test the design.
	initial begin
		x0 <= 10; y0 <= 10; x1 <= 50; y1 <= 10;
						repeat (2) @(posedge clk);
		reset <= 1; repeat (2) @(posedge clk);
		
		// (10, 10) & (50, 10) horizontal line
		x0 <= 10; y0 <= 10; x1 <= 50; y1 <= 10; @(posedge clk);
		reset <= 0; repeat (100) @(posedge clk);

		reset <= 1; @(posedge clk);
		// (10, 10) & (10, 50) vertical line
		x0 <= 10; y0 <= 10; x1 <= 10; y1 <= 50; @(posedge clk);
		reset <= 0; repeat (100) @(posedge clk);

		reset <= 1; @(posedge clk);
		// (0, 0) & (100, 100) line with slope = 1
		x0 <= 0; y0 <= 0; x1 <= 100; y1 <= 100; @(posedge clk);
		reset <= 0; repeat (100) @(posedge clk);

		reset <= 1; @(posedge clk);
		// (0, 100) & (100, 0) line with slope = -1
		x0 <= 0; y0 <= 100; x1 <= 100; y1 <= 0; @(posedge clk);
		reset <= 0; repeat (100) @(posedge clk);

		reset <= 1; @(posedge clk);
		// (0, 0) & (25, 400) line with slope greater than 1 
		x0 <= 0; y0 <= 0; x1 <= 25; y1 <= 400; @(posedge clk);
		reset <= 0; repeat (100) @(posedge clk);

		reset <= 1; @(posedge clk);
		// (0, 0) & (120, 70) line with slope between 0 and 1 
		x0 <= 0; y0 <= 0; x1 <= 120; y1 <= 70; @(posedge clk);
		reset <= 0; repeat (100) @(posedge clk);

		reset <= 1; @(posedge clk);
		// (0, 70) & (150, 0) line with slope between 0 and -1
		x0 <= 0; y0 <= 70; x1 <= 150; y1 <= 0; @(posedge clk);
		reset <= 0; repeat (100) @(posedge clk);
		
		$stop; // End the simulation.
		end 
endmodule 


