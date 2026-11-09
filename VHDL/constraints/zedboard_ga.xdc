# ZedBoard Rev. C/D - GA top constraints
# Top entity: ga_zedboard_top
# GCLK = Y9, 100 MHz. SW0 = F22.

set_property PACKAGE_PIN Y9 [get_ports {clk}]
set_property IOSTANDARD LVCMOS33 [get_ports {clk}]
# 100 MHz
 create_clock -add -name sys_clk -period 10.000 -waveform {0.000 5.000} [get_ports {clk}]
# 1012 MHz 
# create_clock -add -name sys_clk -period 9.804 -waveform {0.000 4.902} [get_ports {clk}]
# Clock: 105 MHz
#create_clock -add -name sys_clk -period 9.524 -waveform {0.000 4.762} [get_ports {clk}]

# SW0 is used directly as the GA active-low reset:
#   SW0 = 0 -> reset asserted
#   SW0 = 1 -> run
set_property PACKAGE_PIN F22 [get_ports {SW0}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW0}]
