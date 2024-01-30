// loseChecker determines whether the frog ran into a car or not
// car is the position of the cars on the 16x16 LED Array
// frog is the position of the frog on the 16x16 LED Array
// lose is whether the frog ran into a car or not, 1 if it did.
module loseChecker (car, frog, lose);
	input logic [15:0][15:0] car; // array of red LEDs
	input logic [15:0][15:0] frog; // array of green LEDs
	output logic lose;
	
	// lose is determined if the position of the frog matches
		// the position of a car. This is only relevant for the
		// 1st and 3rd rows of the LED Array (starting with 0th
		// row at the top), where the cars are.
	assign lose = ((car[1][15] && frog[1][15]) |
		(car[1][14] && frog[1][14]) |
		(car[1][13] && frog[1][13]) |
		(car[1][12] && frog[1][12]) |
		(car[1][11] && frog[1][11]) |
		(car[1][10] && frog[1][10]) |
		(car[3][10] && frog[3][10]) |
		(car[3][11] && frog[3][11]) |
		(car[3][12] && frog[3][12]) |
		(car[3][13] && frog[3][13]) |
		(car[3][14] && frog[3][14]) |
		(car[3][15] && frog[3][15]));
endmodule

// test situations for the frog and car positions
module loseChecker_testbench();
	// creates corresponding variables to model loseChecker module
	logic [15:0][15:0] car; // 16x16 array of red LEDs
	logic [15:0][15:0] frog; // 16x16 array of green LEDs
	logic lose;

	// initializes loseChecker module for testing with name dut
	loseChecker dut (.car, .frog, .lose);

	// checks whether a loss is output when the car and frog occupy the same position.
		// Expected results is that lose goes HIGH.
	// also checks whether a loss is recorded when they are in different positions.
		// Expected result is that lose stays LOW.
	initial begin
		car = '0; frog = '0;
		{car[1][15], frog[1][15]} = 2'b00;								 #10;
		{car[1][15], frog[1][15]} = 2'b10;								 #10;
		{car[1][15], frog[1][15]} = 2'b11;								 #10;
		{car[1][15], frog[1][15]} = 2'b00;								 #10;
		{car[1][15], frog[3][15]} = 2'b11;								 #10;
		$stop; // End the simulation
	end
endmodule