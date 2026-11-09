library ieee;
use ieee.std_logic_1164.all;

-- Integration helper introduced during migration; not an original Quartus block.
-- Suggested descriptive name: fitness_elite_bridge.
entity eval_elit is
 port(
  clk,rst,enable,teo_start,hab_guardar:in std_logic;
  individuo:in std_logic_vector(47 downto 0);
  fin_hist,eval_done:out std_logic;
  SAD:out std_logic_vector(18 downto 0);
  p1,p2:out std_logic_vector(47 downto 0)
 );
end;
architecture rtl of eval_elit is
 signal sad_i:std_logic_vector(18 downto 0);
 signal done_i:std_logic;
 signal ind_reg:std_logic_vector(47 downto 0);
 signal dato_i:std_logic_vector(66 downto 0);
begin
 SAD<=sad_i; eval_done<=done_i;
 dato_i <= sad_i & ind_reg;

 -- Capture the exact individual whose evaluation is started.
 process(rst,clk)
 begin
  if rst='0' then ind_reg<=(others=>'0');
  elsif rising_edge(clk) then
   if teo_start='1' then ind_reg<=individuo; end if;
  end if;
 end process;

 u_eval:entity work.eval port map(
  clk=>clk,rst=>rst,enable=>enable,teo_start=>teo_start,individuo=>individuo,
  fin_hist=>fin_hist,flag_sdone=>done_i,SAD=>sad_i);

 u_elit:entity work.elit generic map(Npadre=>48,Ncost=>19,NParam=>16)
  port map(dato=>dato_i,dato_valid=>done_i,hab_guardar=>hab_guardar,
           rst=>rst,clk=>clk,p1=>p1,p2=>p2);
end;
