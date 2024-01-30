/*
 Lab 5 Task 1
 
 Top level module for synthesis on the De-1 SoC Board.
 Sends audio data to the De-1 SoC board. Audio is either a provided audio file or a
	generated note initialized in the memory. To play the audio file, SW9 should be LOW.
	To play the note stored in memory, SW9 should be HIGH.
 Inputs:
	CLOCK_50 and CLOCK2_50 - 1b 50 Mhz clocks responsible for timing
	KEY - 1b pushbutton on the De-1 SoC board, KEY[0]
	AUD_* - These signals (1b each) go directly to the Audio CODEC already provided
				all are input except AUD_XCK, and AUD_DACDAT, which are output
	I2C_* - These signals (1b each) go directly to the Audio/Video Config module already provided
				FPGA_I2C_SCLK is output while FPGA_I2C_SDAT is inout
*/

`timescale 1 ps / 1 ps
module part1 (CLOCK_50, CLOCK2_50, KEY, FPGA_I2C_SCLK, FPGA_I2C_SDAT, AUD_XCK, 
		        AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, AUD_DACDAT);

	input CLOCK_50, CLOCK2_50;
	input [0:0] KEY;
	// I2C Audio/Video config interface
	output FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	// Audio CODEC
	output AUD_XCK;
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input AUD_ADCDAT;
	output AUD_DACDAT;
	
	// Local wires.
	wire read_ready, write_ready, read, write;
	wire [23:0] readdata_left, readdata_right;
	wire [23:0] writedata_left, writedata_right;
	wire reset = ~KEY[0]; // assign reset to pressing KEY0

	// write to the left channel with whatever data was read from the
		// left channel only when write is ready (and data to read from left channel is only
		// read when enabled when read is ready)
	// write to the right channel with whatever data was read from the
		// right channel when write is ready (and data to read from right channel is only
		// read when enabled when read is ready)
	assign writedata_left = readdata_left;
	assign writedata_right = readdata_right;
	assign read = read_ready;
	assign write = write_ready;
	
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


