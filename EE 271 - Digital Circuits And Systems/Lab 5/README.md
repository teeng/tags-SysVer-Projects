# Modules:
1.	DE1_SoC:
The DE1_SoC module is the top level-entity in the design. This module overall controls the output LEDs LEDR[9], LEDR[2], LEDR[1], LEDR[0] on the De1 SoC board. The output is controlled from the input signals of 2 switches, SW[1], SW[0], and the pushbutton KEY[0]. The behavior of the circuit originates from the modules instantiated in the DE1_SoC module, which are landing and clock_divider.
2.	DE1_SoC_testbench:
Within the DE1_SoC module is the DE1_SoC_testbench() module, which tests every possible combination of inputs from the 2 total switches and single pushbutton used in DE1_SoC module.
3.	landing:
Determines the output to the LEDR[2:0] through the combination of input switches, SW[1] and SW[0]. This is also dependent on the current state of the circuit, as this module determines the next state. 
4.	landing_testbench:
Within the landing module is the landing _testbench() module, which tests combinations of inputs from the 2 total switches used in landing module.
5.	clock_divider:
Allows for the clock cycles to appear more visibly on the De1-SoC board by dividing the on-board FPGA clock at 50 Mhzto multiple levels, with the length of the clock increasing by one each time.

