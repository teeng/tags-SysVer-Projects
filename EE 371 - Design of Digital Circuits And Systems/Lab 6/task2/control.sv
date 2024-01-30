`timescale 1 ps / 1 ps
module control (clk, reset, keyPress, park1, park2, park3, enter, exit, keyPressConfirm,
					 opengate_enter, opengate_exit, rushStartTrigger, rushEndTrigger);
	input logic reset, clk, keyPress;
	input logic park1, park2, park3, enter, exit;
	output logic keyPressConfirm,
					 opengate_enter, opengate_exit, rushStartTrigger, rushEndTrigger;

	logic firstRush, firstEnd;				 
	
	enum logic [1:0] {pre, full, mid, leave} ps, ns;
	enum logic {none, pressed} psKEY, nsKEY;
	
	// rush hour states
	always_comb begin
		case (ps)
		pre: if (park1 && park2 && park3) 		ns = full;
			  else								 		ns = pre;
		full: 									 		ns = mid;
		mid: if (!(park1 || park2 || park3)) 	ns = leave;
			  else									  	ns = mid;
		leave:										 	ns = pre;
		endcase
	end
	
	assign rushStartTrigger = (ps == full && !firstRush);
	assign rushEndTrigger = (ps == leave && !firstEnd);
	
	always_ff @(posedge clk) begin
		if (reset)	ps <= pre;
		else			ps <= ns;
	end
	
	
	always_ff @(posedge clk) begin
		if (reset) begin
			opengate_enter <= 1'b0;
			opengate_exit <= 1'b0;
			firstRush <= 1'b0;
		end else begin
			if (rushStartTrigger)							firstRush <= 1'b1;
			if (rushEndTrigger)								firstEnd <= 1'b1;
			if (!(park1 && park2 && park3) && enter)	opengate_enter <= 1'b1;
			else													opengate_enter <= 1'b0;
			
			if (exit)											opengate_exit <= 1'b1;
			else													opengate_exit <= 1'b0;
		end
	end
	
	
	// keypress control
	always_comb begin 
		case (psKEY)
			none:		if (keyPress)					nsKEY = pressed;
						else								nsKEY = none;
			pressed:	if (keyPress)					nsKEY = pressed;
						else								nsKEY = none;
		endcase
	end
	
	// true only once 
	assign keyPressConfirm = (keyPress & (psKEY == none));
	
	always_ff @(posedge clk) begin  
		if (reset)	psKEY <= none;  
		else			psKEY <= nsKEY;  
	end  
	
	
	
endmodule

module control_testbench();
	logic reset, clk, keyPress;
	logic park1, park2, park3, enter, exit;
	logic keyPressConfirm, opengate_enter, opengate_exit, rushStartTrigger, rushEndTrigger;
	
	control dut (.*);
	
	// Set up a simulated clock to toggle (from low to high or high to low)
	// every 50 time steps
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		// Forever toggle the clock
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end		
	
	
	initial begin
		reset <= 1'b1;	@(posedge clk);
		reset <= 1'b0;
		
		// check enter when parking lot is empty, expect open gate
		{park1, park2, park3} <= 3'b0;
		enter <= 1'b1;										 @(posedge clk);
		enter <= 1'b0;										 @(posedge clk);
		repeat(2) @(posedge clk);
		
		// check enter when parking lot is full, expect not open gate
		// also rushStartTrigger should go HIGH
		{park1, park2, park3} <= 3'b111;
		enter <= 1'b1;										 @(posedge clk);
		enter <= 1'b0;										 @(posedge clk);
		repeat(2) @(posedge clk);
		
		
		// check exit when parking lot is full, expect open gate
		// also rushStartTrigger should go HIGH
		{park1, park2, park3} <= 3'b111;
		exit <= 1'b1;										 @(posedge clk);
		exit <= 1'b0;										 @(posedge clk);
		
		// check if after rushStartTrigger went HIGH,
		// if rushStartEnd goes high when parking lot is empty
		{park1, park2, park3} <= 3'b0;
		repeat(3) @(posedge clk);
		
	$stop;
	end
endmodule