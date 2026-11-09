library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity cross_creep is
    generic(
        Nprng  : integer := 3;
        Npadre : integer := 48;
        NParam : integer := 16
    );
    port(
        prng_A       : in  std_logic_vector(Nprng-1 downto 0);
        prng_r       : in  std_logic_vector(Nprng-1 downto 0);
        prng_SigmaG2 : in  std_logic_vector(Nprng-1 downto 0);
        padre        : in  std_logic_vector(Npadre-1 downto 0);
        hijo         : out std_logic_vector(Npadre-1 downto 0)
    );
end entity;

architecture rtl of cross_creep is
begin
    hijo(Npadre-1 downto Npadre-NParam) <=
        padre(Npadre-1 downto Npadre-NParam+Nprng) &
        (padre(Npadre-NParam+Nprng-1 downto Npadre-NParam) xor prng_A);

    hijo(Npadre-NParam-1 downto NParam) <=
        padre(Npadre-NParam-1 downto NParam+Nprng) &
        (padre(NParam+Nprng-1 downto NParam) xor prng_r);

    hijo(NParam-1 downto 0) <=
        padre(NParam-1 downto Nprng) &
        (padre(Nprng-1 downto 0) xor prng_SigmaG2);


end architecture;
