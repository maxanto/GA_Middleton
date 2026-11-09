library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	
entity mux_hijos is

generic(	Nprng : Natural := 4;    -- Number of bits of the input PRNG.
		  Npadre : Natural := 48;  -- Number of bits of the parent. It is 3xNParam.
	     NParam : Natural := 16); -- Number of bits of each parameter. It is assumed that there are 3 parameters with an equal number of bits. Order [A, r, SigmaG2] in p1, p2, and offspring.
	     
port( h_bin,h_creep,h_shuffle,p1,p2 : in  std_logic_vector(Npadre - 1 downto 0);
						         val_prng : in  std_logic_vector(Nprng - 1 downto 0);
									   o_sel : out std_logic_vector(Npadre - 1 downto 0));
										
end entity;

architecture rtl of mux_hijos is

--begin original

--	o_sel <= h_bin     when unsigned(val_prng) < 25 else
--				h_creep   when unsigned(val_prng) < 38 else
--				h_shuffle when unsigned(val_prng) < 70 else
--				p1        when unsigned(val_prng) < 98 else
--				p2;

--end rtl;

begin

             o_sel <= h_bin     when unsigned(val_prng) < 26  else  -- 20% 
             h_shuffle when unsigned(val_prng) < 39  else  -- 10% 
             h_creep   when unsigned(val_prng) < 71  else  -- 25% 
             p1        when unsigned(val_prng) < 100 else  -- ~22.5% 
             p2;                                           -- ~22.5% 

end rtl;
