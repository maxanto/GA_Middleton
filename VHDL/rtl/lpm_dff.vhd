-- Copyright (C) 2020  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and any partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details, at
-- https://fpgasoftware.intel.com/eula.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 20.1.1 Build 720 11/11/2020 SJ Lite Edition"
-- CREATED		"Mon May 18 13:40:32 2026"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 
-- use the following when compiling in Quartus Prime
--LIBRARY lpm;
--USE lpm.lpm_components.all; 

-- use the following when compiling in third party tools --
-- add lpm_pack.vhd from the Quartus Prime library

ENTITY lpm_dff IS 
generic (
    LPM_SVALUE : natural := 0;
    LPM_WIDTH  : natural := 1
);
PORT 
( 
	-- enable	:	IN	 STD_LOGIC;
	clock	:	IN	 STD_LOGIC;
	data	:	IN	 STD_LOGIC_VECTOR(LPM_WIDTH-1 DOWNTO 0);
	q	:	OUT	 STD_LOGIC_VECTOR(LPM_WIDTH-1 DOWNTO 0)
); 
END lpm_dff;

ARCHITECTURE bdf_type OF lpm_dff IS 
BEGIN 

-- instantiate LPM macrofunction 
p_latch: process(clock)
begin
    if rising_edge(clock) then
        -- if enable='1' then
            q <= data;
        -- end if;
    end if;
end process; 

END bdf_type; 