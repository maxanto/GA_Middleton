library ieee;
use ieee.std_logic_1164.all;

-- ZedBoard implementation top for C17.3.
-- Physical PL ports: 100 MHz GCLK and SW0 only.
-- SW0='0': reset asserted. SW0='1': GA runs.
-- The 48-bit final result and sticky valid flag are observed by ila_0.
entity ga_zedboard_top is
 port(
  clk : in std_logic;
  SW0 : in std_logic
 );
end entity;

architecture rtl of ga_zedboard_top is
 component ila_0 is
  port(
   clk    : in std_logic;
   probe0 : in std_logic_vector(47 downto 0);
   probe1 : in std_logic_vector(0 downto 0)
  );
 end component;

 signal resultado_i : std_logic_vector(47 downto 0);
 signal valido_i    : std_logic;
 signal valido_vec  : std_logic_vector(0 downto 0);
begin
 u_ga: entity work.ga_core
  port map(
   clk       => clk,
   rst       => SW0,
   resultado => resultado_i,
   valido    => valido_i
  );

 valido_vec(0) <= valido_i;

 u_ila: ila_0
  port map(
   clk    => clk,
   probe0 => resultado_i,
   probe1 => valido_vec
  );
end architecture;
