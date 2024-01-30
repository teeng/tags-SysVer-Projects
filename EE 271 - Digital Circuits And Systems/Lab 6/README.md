# Modules:
1.	DE1_SoC:
The DE1_SoC module is the top level-entity in the design. This module overall controls the output LEDs LEDR[9] through LEDR[1], as well as the HEX0 and HEX1 displays on the De1 SoC board. The output is controlled from the input signals of 2 buttons, KEY[3], KEY[0], and the switch SW[9]. The behavior of the circuit originates from the modules instantiated in the DE1_SoC module, which are listed below.
2.	DE1_SoC_testbench:
Within the DE1_SoC module is the DE1_SoC_testbench() module, which tests possible combinations of inputs from the 2 buttons as well as the reset switch used in DE1_SoC module.
3.	inputDejammer:
Receives user input from the pushbuttons and determines whether it was on a clock edge or not, as well as if the button is pressed continuously and is therefore a cheat. If the button press is valid, it is sent to further submodules to transfer to output.
4.	inputDejammer_testbench:
Within the inputDejammer module is the inputDejammer _testbench() module, which tests combinations of inputs from button presses used in inputDejammer module.
5.	normalLight:
Controls normal playfield light functionality, turning the light on or off depending on which buttons are pressed (as received by the inputDejammer) and whether the adjacent lights are on. This module is used for both the center light and the victory lights. Upon reset, if the light is specified to be a center light, then it will turn on. Otherwise, it will turn off.
6.	normalLight_testbench:
Within the normalLight module is the normalLight _testbench() module, which tests combinations of inputs from button presses used in normalLight module.
7.	victoryLight:
Controls victory (edge) playfield light functionality, therefore checking if a win will occur, depending on the button presses (from inputDejammer) and if the adjacent light is on. If there is a winner, the result is sent to seg7 to display the winner on the HEX display.
8.	victoryLight_testbench:
Within the victoryLight module is the victoryLight _testbench() module, which tests combinations of inputs from button presses used in normalLight module to see if victory is properly displayed. Also includes an instantiated normalLight module for basic functionality of turning the light on and off as well as checking if the adjacent light is on.
9.	seg7:
Instantiated within the victoryLight module is the seg7 module, which assigns case-by-case the Hex display depending on who the winner is, either player 1 or player 2. Therefore, displaying a 1, or 2, depending on the winning player.
10.	clock_divider:
Allows for the clock cycles to appear more visibly in simulation by dividing the clock at 50 Mhz to multiple levels, with the length of the clock increasing by one each time.

