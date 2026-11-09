library ieee;
use ieee.std_logic_1164.all;
entity generic_dffe is generic(WIDTH:natural:=48); port(enable,clock:in std_logic; data:in std_logic_vector(WIDTH-1 downto 0); q:out std_logic_vector(WIDTH-1 downto 0)); end;
architecture rtl of generic_dffe is begin process(clock) begin if rising_edge(clock) then if enable='1' then q<=data; end if; end if; end process; end;
