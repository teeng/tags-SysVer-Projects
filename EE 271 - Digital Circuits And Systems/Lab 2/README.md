# Intro
This lab was focused on using the physical breadboard on the DE-1 SoC board for connections. Therefore, the module's code is very simple and simple connects DE-1 SoC switch (SW) inputs to LED outputs.

# Modules:
1. DE1_SoC
The DE1_SoC module is the top level-entity in the design. This module controls the output,
LEDR[0], from the input signals of 8 total switches, SW[0] to SW[7]. If the input signal from
all 8 switches matches the last two digits of my student number, which is 44, then the
output to LEDR[0] will be high. Otherwise, the output will be low. The logic of the output is
controlled by multiple ANDs and NOTs. Additionally, the HEX display on the DE-1 SoC board
is reset to default, where it is turned off.

2. DE1_SoC_testbench
Within the DE1_SoC module is the DE1_SoC_testbench() module, which tests every possible
combination of inputs from the 8 total switches used in DE1_SoC module.