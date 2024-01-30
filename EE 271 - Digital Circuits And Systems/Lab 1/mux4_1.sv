/*
Constructs a 4x1 multiplexer module named mux4_1, which has
7 total ports, the first being the output for the module,
the next four being the four inputs of the 4x1 multiplexer,
and the next two being the two select lines for the 4x1 multiplexer
*/
module mux4_1(out, i00, i01, i10, i11, sel0, sel1);  
	// out is an output for the mux4_1 module with type logic, meaning
	// it has possible values of z, x, 0, or 1
	output logic out;   
	// i00, i01, i10, i11, sel0, sel1 are outputs for the mux4_1 module
	// with type logic
	input  logic i00, i01, i10, i11, sel0, sel1;
	// v0 and v1 are not inputs or outputs, but are internal signals of mux4_1
	// and are type logic
	logic  v0, v1;
	// instantiates three 2x1 multiplexers, previously constructed and named mux2_1.
	// The three mux2_1 instances are named m0, m1, and then m.
	// m0 and m1 both have outputs to the internal signals v0 and v1, which are
	// delivered as mux2_1 inputs i0 and i1 in the instance m.
	// m0 and m1 are each controlled by one select line, sel0 and
	// m0 has i00 and i01 as input signals, while
	// m1 has i10 and i11 as input signals.
	// m has sel1 as its mux2_1 select line, with output out for the mux4_1 module.
	mux2_1 m0(.out(v0),  .i0(i00), .i1(i01), .sel(sel0));   
	mux2_1 m1(.out(v1),  .i0(i10), .i1(i11), .sel(sel0));   
	mux2_1 m (.out(out), .i0(v0),  .i1(v1),  .sel(sel1));   
endmodule   

/*
Constructs a testbench for the 4x1 multiplexer, testing 
all possible input and select line combinations
with a for loop, and a time delay of 10 units
*/
module mux4_1_testbench();
	// creates variables i00,i01, i10, i11, sel0, sel1, and out as type object
	logic  i00, i01, i10, i11, sel0, sel1;    
	logic  out;
	
	// sets up the mux4_1 module for testing, named as dut   
	mux4_1 dut (.out, .i00, .i01, .i10, .i11, .sel0, .sel1);    
   
	// tests every possible combination of the six input signals for the mux4_1,
	// which is sel1, sel0, i00, i01, i10, and i11 with a for loop and time delay of 10 time units
	integer i;   
	initial begin  
		for(i=0; i<64; i++) begin  
			{sel1, sel0, i00, i01, i10, i11} = i; #10;   
		end  
	end  
endmodule 