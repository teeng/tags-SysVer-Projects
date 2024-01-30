/* Module for EE/CSE371 Lab 6
*
* takes in inc and dec signals to count
* maximum at either 5 or 25 count
* full signal indicates max count reached
*/
module lotCounter (clk, reset, inc, dec, count, full);

    input logic clk, reset, inc, dec;
    output logic [4:0] count;
    output logic full;

    // sequential logic
    // update count depending on input
    always_ff @(posedge clk) begin
        if (reset) begin
            count <= 0;
            full <= 0;
        end
        else if (inc) begin
            // max of 5
            if (count == 4) begin
                count <= count + 1;
                full <= 1;
            end
            else if (count < 4) begin
                count <= count + 1;
                full <= 0;
            end
        end
        else if (dec) begin
            if (count > 0) begin
                full <= 0;
                count <= count - 1;
            end
        end
        else begin
            count <= count;
            full <= full;
        end
    end
endmodule

/* testbench for counter */
module lotCounter_testbench();
    logic clk, reset, inc, dec, full;
    logic [4:0] count;
    lotCounter dut (clk, reset, inc, dec, count, full);
    // clock setup
    parameter clock_period = 100;
    initial begin
        clk <= 0;
        forever #(clock_period /2) clk <= ~clk;
    end
    
    initial begin
        reset<=1; @(posedge clk);
        reset<=0; inc<=0; dec<=0; @(posedge clk);
					  inc<=0; dec<=0; @(posedge clk);
					  inc<=0; dec<=1; @(posedge clk);
					  inc<=0; dec<=0; @(posedge clk);
					  inc<=1; dec<=0; @(posedge clk);
					  inc<=0; dec<=0; @(posedge clk);
					  inc<=1; dec<=0; @(posedge clk);
					  inc<=0; dec<=0; @(posedge clk);
					  inc<=1; dec<=0; @(posedge clk);
					  inc<=0; dec<=0; @(posedge clk);
					  inc<=1; dec<=0; @(posedge clk);
					  inc<=0; dec<=0; @(posedge clk);
					  inc<=1; dec<=0; @(posedge clk);
					  inc<=0; dec<=0; @(posedge clk);
					  inc<=1; dec<=0; @(posedge clk);
					  inc<=0; dec<=0; @(posedge clk);
					  inc<=1; dec<=0; @(posedge clk);
					  inc<=0; dec<=0; @(posedge clk);
					  inc<=1; dec<=0; @(posedge clk);
					  inc<=0; dec<=0; @(posedge clk);
					  inc<=1; dec<=0; @(posedge clk);
					  inc<=0; dec<=0; @(posedge clk);
					  inc<=0; dec<=0; @(posedge clk);
					  inc<=0; dec<=1; @(posedge clk);
					  inc<=0; dec<=0; @(posedge clk);
					  inc<=0; dec<=0; @(posedge clk);
					  inc<=0; dec<=1; @(posedge clk);
					  inc<=0; dec<=0; @(posedge clk);
					  inc<=0; dec<=0; @(posedge clk);
					  inc<=0; dec<=0; @(posedge clk);

		$stop; // end simulation
	end // initial

 endmodule // hw1p1_testbench