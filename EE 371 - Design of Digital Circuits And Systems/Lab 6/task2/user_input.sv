/*
 Lab 6

 this is the user_input module.
 
 uses clk and reset to manage states.
 
 input and output are both single bit signals.
 
 outputs true for one clock cycle when input is true, and doesn't
 output another true until input is false for at least one clock 
 cycle, then wais for next true input.

 also has double D flipflop on input to handle metastability

*/

module user_input (clk, reset, in, out);
	input	 logic  clk, reset, in;
	output logic  out;
	
	// intermediate logic in between initial double DFFs
	logic  q1, q2; 
	
	// double D flipflops
	always_ff@(posedge clk) begin
		q1 <= in;
	end
	
	always_ff@(posedge clk) begin
		q2 <= q1;
	end
	
	// sequential logic
	enum {none, pressed} ps, ns;
	
	always_comb begin 
		case (ps)
			none:		if (q2)		ns = pressed;
						else			ns = none;
			pressed:	if (q2)		ns = pressed;
						else			ns = none;
		endcase
	end
	
	// true only once 
	assign out = (q2 & (ps == none));
	
	always_ff @(posedge clk) begin  
		if (reset)  
		ps <= none;  
		else  
		ps <= ns;  
	end  
	
endmodule


// testbench for user input module
module user_input_testbench();
	logic  clk, reset, in;
	logic  out;
	logic  q1, q2; 

	user_input dut (clk, reset, in, out);
	
	// Set up a simulated clock.   
	parameter CLOCK_PERIOD=100;  
	initial begin  
		clk <= 0;  
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock 
	end  
	//
	
	// Set up the inputs to the design.  Each line is a clock cycle.  
	initial begin  
											@(posedge clk);   
		reset <= 1;        			@(posedge clk); // Always reset FSMs at start  
											@(posedge clk);   
											@(posedge clk);   
		in <= 0;							@(posedge clk);   
											@(posedge clk);
											@(posedge clk);
		reset <= 0;						@(posedge clk);   
											@(posedge clk);   
											@(posedge clk);   
					   in <= 1;			@(posedge clk);   
											@(posedge clk);   
											@(posedge clk);   
											@(posedge clk);   
											@(posedge clk);   
											@(posedge clk);   
											@(posedge clk);   
					   in <= 0;			@(posedge clk);
											@(posedge clk);   
											@(posedge clk);   
											@(posedge clk);
											@(posedge clk);   
											@(posedge clk);   
											@(posedge clk);
						in <= 1;			@(posedge clk);   
											@(posedge clk);   
											@(posedge clk);   
											@(posedge clk);   
											@(posedge clk);   
											@(posedge clk);   
											@(posedge clk);
						in <= 0;			@(posedge clk);   
											@(posedge clk);   
											@(posedge clk);   
											@(posedge clk);
											@(posedge clk);   
											@(posedge clk);   
											@(posedge clk);
					   in <= 1;			@(posedge clk);   
											@(posedge clk);   
											@(posedge clk);     
		$stop; // End the simulation.  
	end  
	
	
	
endmodule


