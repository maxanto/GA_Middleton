library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mutacion is
    generic (
        Nparam : integer := 16;
         Nprng : integer := 8;
          Nmut : integer := 4;
             P : integer := 50;
            ID : integer := 0
    );
    port (
        gen_in     : in  std_logic_vector(Nparam-1 downto 0);
        prng_i     : in  std_logic_vector(Nprng-1 downto 0);
        mutate_req : in  std_logic;
        gen_out    : out std_logic_vector(Nparam-1 downto 0)
        --umbral     : out std_logic_vector(Nprng-1 downto 0);
        --pos_mut_o  : out std_logic_vector(Nprng-1 downto 0)
			);
end entity;

architecture rtl of mutacion is

    constant M : integer := (2**Nprng) - 1;
    constant THRESHOLD_INT : integer := ((100 - P) * M) / 100;
    constant THRESHOLD : unsigned(Nprng-1 downto 0) := to_unsigned(THRESHOLD_INT, Nprng);

    signal pos_mut_s : integer;

begin

process(gen_in, prng_i, mutate_req)
    variable aux_gen : std_logic_vector(Nparam-1 downto 0);
    variable pos_mut : integer;
begin
    aux_gen := gen_in;
    pos_mut := 0;  -- default

    if mutate_req = '1' then
        if unsigned(prng_i) > THRESHOLD then

            pos_mut := (to_integer(unsigned(prng_i)) + ID) mod (Nmut + 1);

            if pos_mut < Nparam then
                aux_gen(pos_mut) := not gen_in(pos_mut);
            end if;

        end if;
    end if;

    gen_out   <= aux_gen;
    pos_mut_s <= pos_mut;

end process;

-- salida como vector
--pos_mut_o <= std_logic_vector(to_unsigned(pos_mut_s, Nprng));

--umbral <= std_logic_vector(THRESHOLD);

end architecture;
