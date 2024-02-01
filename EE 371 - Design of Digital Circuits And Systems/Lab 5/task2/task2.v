/* 
 Lab 5 Task 2
 
 Top level module for synthesis on the DE-1 SoC Board.
 Sends audio data to the DE-1 SoC board. Audio is either a provided audio file or a
	generated note initialized in the memory. To play the audio file, SW9 should be LOW.
	To play the note stored in memory, SW9 should be HIGH.
 Inputs:
	CLOCK_50 and CLOCK2_50 - 1b 50 Mhz clocks responsible for timing
	KEY - 1b pushbutton on the DE-1 SoC board, KEY[0]
	SW - 1b ach for the 10 switches on the DE-1 SoC board, so 10b total
	AUD_* - These signals (1b each) go directly to the Audio CODEC already provided
				all are input except AUD_XCK, and AUD_DACDAT, which are output
	I2C_* - These signals (1b each) go directly to the Audio/Video Config module already provided
				FPGA_I2C_SCLK is output while FPGA_I2C_SDAT is inout
*/

`timescale 1 ps / 1 ps
module task2 (CLOCK_50, CLOCK2_50, KEY, SW, FPGA_I2C_SCLK, FPGA_I2C_SDAT, AUD_XCK, 
		        AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, AUD_DACDAT);
	input CLOCK_50, CLOCK2_50;
	input [0:0] KEY;
	input [9:0] SW;
	// I2C Audio/Video config interface
	output FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	// Audio CODEC
	output AUD_XCK;
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input AUD_ADCDAT;
	output AUD_DACDAT;
	
	// define reset to be KEY[0] press
	wire reset;
	assign reset = ~KEY[0];
	
	// Local wires for audio control
	wire read_ready, write_ready;
	// left and right channels data controlled by read/write signals
	wire [23:0] readdata_left, readdata_right;
	reg [23:0] writedata_left, writedata_right;
	
	// read and write only when ready
	wire read, write;
	assign read = read_ready;
	assign write = write_ready;
	
	// temporary 24b variables for storing the data of writes to left and right channels
	wire [23:0] data_left_file, data_right_file, data_left_note, data_right_note;
	
	// instantiated part1 module named fromFile is responsible for writing data to each channel
		// from the audio file provided
	// Inputs:
		// clk is 1b clock responsible for input/output timing
		// reset is 1b control signal for response on reset
		// readdata_left and readdata_left are the 24b data from the file to read for both
			// left and right channels
	// Output: writedata_left and writedata_right are the 24b data to write to the left and
		// right channels and send to the temporary variables
	part1 fromFile (.clk(CLOCK_50), .reset(reset), .readdata_left(readdata_left),
						 .readdata_right(readdata_right), .writedata_left(data_left_file),
						 .writedata_right(data_right_file));
	
	// instantiated part2 module named noteOnly is responsible for writing data to each channel
		// from a generated note
	// Inputs:
		// clk is 1b clock responsible for input/output timing
		// reset is 1b control signal for response on reset
	// Output: writedata_left and writedata_right are the 24b data to write to the left and
		// right channels and send to the temporary variables
	part2 noteOnly (.clk(CLOCK_50), .reset(reset), .write(write), .writedata_left(data_left_note),
						 .writedata_right(data_right_note));
	
	// controls whether the data to write to the DE-1 SoC should be from the audio file or from
		// the generated note, depending on SW9 and reset
	// If reset (KEY0) is HIGH, don't write any data (0)
	// If SW9 is high, write from the generated note
	// If SW9 is low, write from the audio file
	always @(posedge CLOCK_50) begin
		if (reset) begin
			{writedata_left, writedata_right} <= 0;
		end else begin
			if (~SW[9]) begin
				writedata_left <= data_left_file;
				writedata_right <= data_right_file;
			end else begin
				writedata_left <= data_left_note;
				writedata_right <= data_right_note;
			end
		end
	end
	
	
/////////////////////////////////////////////////////////////////////////////////
// Audio CODEC interface. 
//
// The interface consists of the following wires:
// read_ready, write_ready - CODEC ready for read/write operation 
// readdata_left, readdata_right - left and right channel data from the CODEC
// read - send data from the CODEC (both channels)
// writedata_left, writedata_right - left and right channel data to the CODEC
// write - send data to the CODEC (both channels)
// AUD_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio CODEC
// I2C_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio/Video Config module
/////////////////////////////////////////////////////////////////////////////////
	clock_generator my_clock_gen(
		// inputs
		CLOCK2_50,
		reset,

		// outputs
		AUD_XCK
	);

	audio_and_video_config cfg(
		// Inputs
		CLOCK_50,
		reset,

		// Bidirectionals
		FPGA_I2C_SDAT,
		FPGA_I2C_SCLK
	);

	audio_codec codec(
		// Inputs
		CLOCK_50,
		reset,

		read,	write,
		writedata_left, writedata_right,

		AUD_ADCDAT,

		// Bidirectionals
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,

		// Outputs
		read_ready, write_ready,
		readdata_left, readdata_right,
		AUD_DACDAT
	);
endmodule