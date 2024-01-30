# Modules:
1.	DE1_SoC:
The DE1_SoC module is the top level-entity in the design. This module overall controls the output LEDs LEDR[9] through LEDR[1], as well as the HEX0 and HEX1 displays on the De1 SoC board. The output is controlled from the input signals of 2 buttons, KEY[3], KEY[0], and switches SW[9:0]. The behavior of the circuit originates from the modules instantiated in the DE1_SoC module, which are listed below.
2.	DE1_SoC_testbench:
Within the DE1_SoC module is the DE1_SoC_testbench() module, which tests possible combinations of inputs from the button as well as the switches used in DE1_SoC module.
3.	inputTug:
Receives user input and checks whether it is occurred on a clock edge, or missed the clock edge, and ensures that a single button press only counts as one press, even if held over several clock cycles.
4.	inputTug_testbench:
Within the inputTug module is the inputTug_testbench() module, which tests if all button presses that occur on a clock edge only count as one press
5.	inputDejammer:
Instantiated within inputTug is inputDejammer, which receives the user input from inputTug and connects this input to two flip flops to ensure a stable input for the rest of the system, which also ensures stable outputs.
6.	inputDejammer_testbench:
Within the inputDejammer module is the inputDejammer _testbench() module, which tests combinations of inputs from button presses used in inputDejammer module.
7.	computer:
The opposing and automated player, computer, is controlled by SW[8:0] on the DE1-SoC board, with SW[1] being the lowest difficulty, and SW[9] being a much greater difficulty. All switches on is the maximum difficulty. Difficulty is determined by how often the computer will simulate a button press.
8.	computer_testbench:
Within the computer module is the computer_testbench() module, which tests the change in difficulty using the switches and how often the computer will simulate a button press as a result.
9.	LFSRTen:
Instantiated within the computer module is LFSRTen, which generates a random 10-bit number.
10.	LFSRTen_testbench:
Within the LFSRTen module is the LFSRTen_testbench module, which checks the first 20 numbers generated and ensures sufficient randomness
11.	compareTen:
Instantiated within the computer module is compareTen, which compares the randomly-generated number from LFSRTen to the input combination of SW[8:0] on the De1-SoC board. If the switch value is greater than the random number, then the output is HIGH.
12.	compareTen_testbench
Within the compareTen module is the compareTen_testbench(), which checks outputs are accurate for inputs such as 100 > 90 (TRUE), 10 > 9 (TRUE), 5 > 9 (FALSE).
13.	normalLight:
Controls normal playfield light functionality, turning the light on or off depending on which buttons are pressed (as received by the inputDejammer) and whether the adjacent lights are on. This module is used for the center light and used in the victory lights. Upon reset, if the light is specified to be a center light, then it will turn on. Otherwise, it will turn off. If a round is completed, meaning one round was won by a player, all lights are maintained off.
14.	normalLight_testbench:
Within the normalLight module is the normalLight _testbench() module, which tests combinations of inputs from button presses used in normalLight module, as well as testing whether the light stays off after a round is won.
15.	victoryLight:
Controls victory (edge) playfield light functionality, therefore checking if a win will occur, depending on the button presses from both players and if the adjacent light is on. If there is a winner, the result is sent to module counter to increment the number of wins for that player, with a maximum of seven wins. Then, the result of the counter is sent to seg7 to update the number of wins for the players on the HEX display.
16.	victoryLight_testbench:
Within the victoryLight module is the victoryLight _testbench() module, which tests combinations of inputs from button presses used in victoryLight module to see if victory is properly displayed. Also includes an instantiated normalLight module for basic functionality of turning the light on and off as well as checking if the adjacent light is on. Also checks whether the HEX displays the accurate number and information for a player win.
17.	counter:
Instantiated within the victoryLight module is the counter module, which updates the amount of wins a player has, with a maximum of seven, and returns this value.
18.	counter_testbench:
Within the counter module is the counter _testbench() module, which checks if the output increments by 1 every time a win is recorded.
19.	seg7:
Instantiated within the victoryLight module is the seg7 module, which assigns case-by-case the Hex display depending on how many times a player has won. HEX1 displays player 1’s win count, HEX2 displays the computer’s win count. A maximum of 7 rounds are won before no more wins are recorded.
20.	clock_divider:
Allows for the clock cycles to appear more visibly in simulation by dividing the clock at 50 Mhz to multiple levels, with the length of the clock increasing by one each time.
