/*
 Lab 2 Task 3
 
 FIFO_Control is the brains of the FIFO module.  This
 module handles 'pointers' to different addresses
 in the RAM to keep track of which spaces will be written
 to and read from next.  This module also keeps track of 
 when the full/empty signals are true.
 
 Parameters:
	Inputs: 
		clk and reset are used to manage the states of the module
		read and write are each used to tell the control module
			when these actions are being requested
	Outputs:
		wr_en is the write enable for the RAM, and is controlled
			here by combinational logic based on the write input
			and whether the FIFO is full
		empty and full are single bit signals which indicate the 
			current state of the FIFO
		readAddr and writeAddr are 'pointers' whose size depends on
			the depth of the FIFO.  They keep track of where in the 
			RAM will be read from and written to next.  They are to
			be connected directly to the RAM.
 */
 

module FIFO_Control #(
							 parameter depth = 4
							 )(
								input logic clk, reset,
								input logic read, write,
							  output logic wr_en,
							  output logic empty, full,
							  output logic [depth-1:0] readAddr, writeAddr
							  );
	
	/* 	Define_Variables_Here		*/
	logic [depth-1:0] storage_counter;
	
	
	/*		Combinational_Logic_Here	*/
	always_comb begin
		wr_en = (~full) & (write);
		if(storage_counter=='0)
			empty=1;
		else
			empty=0;
		if(storage_counter=='1)
			full=1;
		else
			full=0;
	end
	
	
	/*		Sequential_Logic_Here		*/	
	always_ff @(posedge clk) begin
		// reset conditions
		if(reset) begin
			 readAddr <= '0;
			writeAddr <= '0;
	storage_counter <= '0;
		end else begin
		
			// if read is input
			if(read) begin
				if(~(storage_counter=='0)) begin
					storage_counter<=storage_counter - 1;
					if(readAddr=='1)
						readAddr<='0;
					else
						readAddr<=readAddr + 1;
				end
			end
			
			// if write is input
			if(write) begin
				if(~(storage_counter=='1)) begin
					storage_counter<=storage_counter + 1;
					if(writeAddr=='1)
						writeAddr<='0;
					else
						writeAddr<=writeAddr + 1;
				end
			end
			
		end
	end
endmodule 


// tesetbench for FIFO_Control task3
module FIFO_Control_testbench ();

	logic clk, reset;
	logic read, write;
	logic wr_en;
	logic empty, full;
	logic [3:0] readAddr, writeAddr;
	
	FIFO_Control dut (.clk, .reset, .read, .write, .wr_en, .empty, .full, .readAddr, .writeAddr);
	
	// clock setup
	parameter clock_period = 100;
	
	initial begin
		clk <= 0;
		forever #(clock_period /2) clk <= ~clk;
	end
	
	initial begin
		reset<=1;					@(posedge clk);
		read<=0; write<=0;		@(posedge clk);
		reset<=0;					@(posedge clk);
										@(posedge clk);
		read<=1; write<=0;		@(posedge clk);
										@(posedge clk);
										@(posedge clk);
		read<=0; write<=0;		@(posedge clk);
										@(posedge clk);
										@(posedge clk);
		read<=0; write<=1;		@(posedge clk);
										@(posedge clk);
										@(posedge clk);
		read<=0; write<=0;		@(posedge clk);
										@(posedge clk);
										@(posedge clk);
		read<=0; write<=1;		@(posedge clk);
										@(posedge clk);
										@(posedge clk);
		read<=0; write<=0;		@(posedge clk);
										@(posedge clk);
										@(posedge clk);
		read<=0; write<=1;		@(posedge clk);
										@(posedge clk);
										@(posedge clk);
		read<=0; write<=0;		@(posedge clk);
										@(posedge clk);
										@(posedge clk);
		read<=0; write<=1;		@(posedge clk);
										@(posedge clk);
										@(posedge clk);
		read<=0; write<=0;		@(posedge clk);
										@(posedge clk);
										@(posedge clk);
		read<=0; write<=1;		@(posedge clk);
										@(posedge clk);
										@(posedge clk);
		read<=0; write<=0;		@(posedge clk);
										@(posedge clk);
										@(posedge clk);
		read<=0; write<=1;		@(posedge clk);
										@(posedge clk);
										@(posedge clk);
		read<=0; write<=0;		@(posedge clk);
										@(posedge clk);
										@(posedge clk);
		read<=0; write<=1;		@(posedge clk);
										@(posedge clk);
										@(posedge clk);
		read<=0; write<=0;		@(posedge clk);
										@(posedge clk);
										@(posedge clk);
		read<=1; write<=0;		@(posedge clk);
										@(posedge clk);
										@(posedge clk);
		read<=0; write<=0;		@(posedge clk);
										@(posedge clk);
										@(posedge clk);
		read<=1; write<=0;		@(posedge clk);
										@(posedge clk);
										@(posedge clk);
		read<=0; write<=0;		@(posedge clk);
										@(posedge clk);
										@(posedge clk);
		read<=1; write<=0;		@(posedge clk);
										@(posedge clk);
										@(posedge clk);
		read<=0; write<=0;		@(posedge clk);
										@(posedge clk);
										@(posedge clk);
		read<=1; write<=0;		@(posedge clk);


		$stop; // end simulation
		
	end  // initial

endmodule
