library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ccdf_samples_pkg.all;

entity ccdf_rom_sync is
    port(
        clk  : in  std_logic;
        en   : in  std_logic;
        addr : in  unsigned(8 downto 0);
        data : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of ccdf_rom_sync is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if en='1' then
                data <= CCDF_SAMPLES_ROM(to_integer(addr));
            end if;
        end if;
    end process;
end architecture;
