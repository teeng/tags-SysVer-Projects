/* Module for EE/CSE371 Lab 6.

 FSM which takes in two signals from parking lot
 determines if car went in or out, and outputs this
 can detect a car vs a pedestrian
*/
module lotSensor (clk, reset, ab, exit, enter);
	input logic reset, clk;
	input logic [1:0] ab;
	output logic exit, enter;
	// present and next state
	enum {idle, in1, in2, in3, out1, out2, out3, ped1, ped2} ps, ns;
	// Next state logic
	always_comb begin
		case (ps)
			idle: if (ab==2'b00) ns = idle;
				else if (ab==2'b10) ns = in1;
				else if (ab==2'b01) ns = out1;
				else ns = ped1;
			in1: if (ab==2'b00) ns = idle;
				else if (ab==2'b10) ns = in1;
				else if (ab==2'b01) ns = out1;
				else ns = in2;
			in2: if (ab==2'b00) ns = idle;
				else if (ab==2'b10) ns = in1;
				else if (ab==2'b01) ns = in3;
				else ns = in2;
			in3: if (ab==2'b00) ns = idle;
				else if (ab==2'b10) ns = in1;
				else if (ab==2'b01) ns = in3;
				else ns = in2;
			out1: if (ab==2'b00) ns = idle;
				else if (ab==2'b10) ns = in1;
				else if (ab==2'b01) ns = out1;
				else ns = out2;
			out2: if (ab==2'b00) ns = idle;
				else if (ab==2'b10) ns = out3;
				else if (ab==2'b01) ns = out1;
				else ns = out2;
			out3: if (ab==2'b00) ns = idle;
				else if (ab==2'b10) ns = out3;
				else if (ab==2'b01) ns = out1;
				else ns = out2;
			ped1: if (ab==2'b00) ns = idle;
				else if (ab==2'b10) ns = ped2;
				else if (ab==2'b01) ns = ped2;
				else ns = ped1;
			ped2: if (ab==2'b00) ns = idle;
				else if (ab==2'b10) ns = ped2;
				else if (ab==2'b01) ns = ped2;
				else ns = ped1;
		endcase
	end
		
	// sequential state logic (DFFs)
	always_ff @(posedge clk) begin
		if (reset) begin
			ps <= idle;
			exit <= 0;
			enter <= 0;
		end
		else begin
			case (ps)
				in3: begin
					exit <= 0;
					if (ns==idle) enter <= 1;
					else if (ns==in1) enter <= 1;
					else enter <= 0;
				end
				out3: begin
					enter <= 0;
					if (ns==idle) exit <= 1;
					else if (ns==out1) exit <= 1;
					else exit <= 0;
				end
				default: begin
					enter <= 0;
					exit <= 0;
				end
				
			endcase
			ps <= ns;
		end
	end
endmodule



/* Testbench */
module lotSensor_testbench();

	logic clk, reset, enter, exit;
	logic [1:0] ab;

	lotSensor dut (clk, reset, ab, exit, enter);

	// clock setup
	parameter clock_period = 100;

	initial begin
		clk <= 0;
		forever #(clock_period /2) clk <= ~clk;
	end

	initial begin

		reset<=1; @(posedge clk);
		reset<=0; ab<=2'b00; @(posedge clk);
									@(posedge clk);
									@(posedge clk);
									@(posedge clk);
					ab<=2'b10; @(posedge clk);
									@(posedge clk);
									@(posedge clk);
					ab<=2'b11; @(posedge clk);
									@(posedge clk);
									@(posedge clk);
					ab<=2'b01; @(posedge clk);
									@(posedge clk);
									@(posedge clk);
					ab<=2'b00; @(posedge clk);
									@(posedge clk);
									@(posedge clk);
					ab<=2'b01; @(posedge clk);
									@(posedge clk);
									@(posedge clk);
					ab<=2'b11; @(posedge clk);
									@(posedge clk);
									@(posedge clk);

					ab<=2'b10; @(posedge clk);
									@(posedge clk);
									@(posedge clk);
					ab<=2'b00; @(posedge clk);
									@(posedge clk);
									@(posedge clk);
					ab<=2'b11; @(posedge clk);
									@(posedge clk);
									@(posedge clk);
					ab<=2'b10; @(posedge clk);
									@(posedge clk);
									@(posedge clk);
					ab<=2'b00; @(posedge clk);
									@(posedge clk);
									@(posedge clk);
					ab<=2'b10; @(posedge clk);
									@(posedge clk);
									@(posedge clk);
					ab<=2'b11; @(posedge clk);
									@(posedge clk);
									@(posedge clk);
					ab<=2'b01; @(posedge clk);
									@(posedge clk);
									@(posedge clk);
					ab<=2'b10; @(posedge clk);
									@(posedge clk);
									@(posedge clk);
					ab<=2'b11; @(posedge clk);
									@(posedge clk);
									@(posedge clk);
					ab<=2'b01; @(posedge clk);
									@(posedge clk);
									@(posedge clk);
					ab<=2'b00; @(posedge clk);
									@(posedge clk);

		$stop; // end simulation

	end // initial

endmodule