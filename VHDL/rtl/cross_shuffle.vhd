library	ieee;
	use ieee.std_logic_1164.all;
	
entity cross_shuffle is

generic(  Npadre : Natural := 48; -- Number of bits of the parent. It is 3xNParam.
			NParam : Natural := 16); -- Number of bits of each parameter. It is assumed that there are 3 parameters with an equal number of bits. Order [A, r, SigmaG2] in p1, p2, and offspring.
			
port(	bit_rand_A,bit_rand_r,bit_rand_Sigma : in  std_logic;  -- Random bits from any PRNG used for the selection of p1 or p2 per gene.
												 p1,p2 : in  std_logic_vector(Npadre - 1 downto 0);
												  hijo : out std_logic_vector(Npadre - 1 downto 0));
end entity;

architecture uno of cross_shuffle is

begin

	muxA: with bit_rand_A select
		hijo(Npadre - 1 downto Npadre - NParam) <= p1(Npadre - 1 downto Npadre - NParam) when '0',
																	  p2(Npadre - 1 downto Npadre - NParam) when others;
	
	muxr: with bit_rand_r select
		hijo(Npadre - NParam - 1 downto NParam) <= p1(Npadre - NParam - 1 downto NParam) when '0',
																		p2(Npadre - NParam - 1 downto NParam) when others;
		
	muxSigma: with bit_rand_Sigma select
		hijo(NParam - 1 downto 0) <= p1(NParam - 1 downto 0) when '0',
												 p2(NParam - 1 downto 0) when others;
	
end uno;
