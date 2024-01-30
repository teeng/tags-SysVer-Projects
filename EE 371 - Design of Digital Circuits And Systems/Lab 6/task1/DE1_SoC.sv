/* Module for EE/CSE371 Lab1.
 *
 * top level module for lab1
 * implements parknig lot counter
 * and connects functionality to DE1SoC GPIOs and HEX LEDs
 * can count cars coming in or out, and displays count
 *
 */
module DE1_SoC (V_GPIO, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, CLOCK_50);

	// SW and KEY cannot be declared if GPIO_0 is declared on LabsLand
	inout  logic [35:23] V_GPIO;
	output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	input  logic CLOCK_50;
	
	// internal signals
	logic reset, sensA, sensB, full, inc, dec;
	logic [4:0] count;
	logic [1:0] ab;
	logic [6:0] ones, tens;
	logic [3:0] one4, ten4;
	
	// connecting GPIO to signals
	assign sensA = V_GPIO[23];
	assign sensB = V_GPIO[24];
	assign reset = V_GPIO[30];
	
	assign V_GPIO[32] = sensA;
	assign V_GPIO[35] = sensB;
	
	assign ab[1] = sensA;
	assign ab[0] = sensB;
	
	// convert count into two 4'b signals
	// for each digit place
	always_comb begin
		if (count < 10) begin
			one4 = count[3:0];
			ten4 = 4'b0000;
		end
		else if (count < 20) begin
			one4 = (count - 10);
			ten4 = 4'b0001;
		end	
		else begin
			one4 = (count - 20);
			ten4 = 4'b0010;
		end
	end
	
	// declaring modules
	lotSensor main (.clk(CLOCK_50), .reset(reset), .ab(ab), .exit(dec), .enter(inc));
	lotCounter numb (.clk(CLOCK_50), .reset(reset), .inc(inc), .dec(dec), .count(count), .full(full));
	seg7 one (.in(one4), .leds(ones));
	seg7 ten (.in(ten4), .leds(tens));
	
	// assigning HEX values based on count
	always_comb begin
		if (full) begin
			HEX0 = 7'b1111111;
			HEX1 = 7'b1111111;
			HEX2 = 7'b1000111;
			HEX3 = 7'b1000111;
			HEX4 = 7'b1000001;
			HEX5 = 7'b0001110;
		end
		else if (count==0) begin
			HEX0 = 7'b1000000;
			HEX1 = 7'b1001110;
			HEX2 = 7'b0001000;
			HEX3 = 7'b0000110;
			HEX4 = 7'b1000111;
			HEX5 = 7'b1000110;
		end
		else begin
			HEX0 = ones;
			HEX1 = tens;
			HEX2 = 7'b1111111;
			HEX3 = 7'b1111111;
			HEX4 = 7'b1111111;
			HEX5 = 7'b1111111;
		end
	end

endmodule

// testbench for parking lot counter top module
module DE1_SoC_testbench();
	
	// logic for dut
	wire [35:23] V_GPIO;
	logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic clk, CLOCK_50;
	
	// internal logic to help simulating more clearly
	logic reset, A, B;
	assign V_GPIO[30] = reset;
	assign V_GPIO[23] = A;
	assign V_GPIO[24] = B;
	
	DE1_SoC dut (.V_GPIO, .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .CLOCK_50(clk));
	
	// clock setup
	parameter clock_period = 100;
	
	initial begin
		clk <= 0;
		forever #(clock_period /2) clk <= ~clk;
	end

	initial begin
	
		reset<=1; 						@(posedge clk);
		reset<=0; A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=1; B<=0;		@(posedge clk);
					 A<=1; B<=1;		@(posedge clk);
					 A<=0; B<=1;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=1; B<=0;		@(posedge clk);
					 A<=1; B<=1;		@(posedge clk);
					 A<=0; B<=1;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=1; B<=0;		@(posedge clk);
					 A<=1; B<=1;		@(posedge clk);
					 A<=0; B<=1;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=1; B<=0;		@(posedge clk);
					 A<=1; B<=1;		@(posedge clk);
					 A<=0; B<=1;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=1; B<=0;		@(posedge clk);
					 A<=1; B<=1;		@(posedge clk);
					 A<=0; B<=1;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=1; B<=0;		@(posedge clk);
					 A<=1; B<=1;		@(posedge clk);
					 A<=0; B<=1;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=1; B<=0;		@(posedge clk);
					 A<=1; B<=1;		@(posedge clk);
					 A<=0; B<=1;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=1; B<=0;		@(posedge clk);
					 A<=1; B<=1;		@(posedge clk);
					 A<=0; B<=1;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=1; B<=0;		@(posedge clk);
					 A<=1; B<=1;		@(posedge clk);
					 A<=0; B<=1;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=1;		@(posedge clk);
					 A<=1; B<=1;		@(posedge clk);
					 A<=1; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=1;		@(posedge clk);
					 A<=1; B<=1;		@(posedge clk);
					 A<=1; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=1;		@(posedge clk);
					 A<=1; B<=1;		@(posedge clk);
					 A<=1; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=1;		@(posedge clk);
					 A<=1; B<=1;		@(posedge clk);
					 A<=1; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=1;		@(posedge clk);
					 A<=1; B<=1;		@(posedge clk);
					 A<=1; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=1;		@(posedge clk);
					 A<=1; B<=1;		@(posedge clk);
					 A<=1; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=1;		@(posedge clk);
					 A<=1; B<=1;		@(posedge clk);
					 A<=1; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=1;		@(posedge clk);
					 A<=1; B<=1;		@(posedge clk);
					 A<=1; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=1;		@(posedge clk);
					 A<=1; B<=1;		@(posedge clk);
					 A<=1; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=1;		@(posedge clk);
					 A<=1; B<=1;		@(posedge clk);
					 A<=1; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=1;		@(posedge clk);
					 A<=1; B<=1;		@(posedge clk);
					 A<=1; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=1;		@(posedge clk);
					 A<=1; B<=1;		@(posedge clk);
					 A<=1; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=1;		@(posedge clk);
					 A<=1; B<=1;		@(posedge clk);
					 A<=1; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=1;		@(posedge clk);
					 A<=1; B<=1;		@(posedge clk);
					 A<=1; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=1;		@(posedge clk);
					 A<=1; B<=1;		@(posedge clk);
					 A<=1; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=1;		@(posedge clk);
					 A<=1; B<=1;		@(posedge clk);
					 A<=1; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
					 A<=0; B<=1;		@(posedge clk);
					 A<=1; B<=1;		@(posedge clk);
					 A<=1; B<=0;		@(posedge clk);
					 A<=0; B<=0;		@(posedge clk);
		$stop; // end simulation
	end  // initial
endmodule
