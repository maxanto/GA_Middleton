library ieee;
use ieee.std_logic_1164.all;

-- GA computational core with minimal external interface.
-- C17: synthesis-oriented interface. Internal diagnostic signals are no longer
-- external ports; the final elite is published also at Hmejor so that the
-- result includes the last generation.
entity ga_core is
 generic(Npob:natural:=42; Ngen:natural:=120);
 port(
  clk       : in  std_logic;
  rst       : in  std_logic; -- asynchronous, active LOW
  resultado : out std_logic_vector(47 downto 0);
  valido    : out std_logic
 );
end;
architecture rtl of ga_core is
 signal hpob_i,sel_i,hguar_i,hcros_i,hpmut_i,hmejor_i,heval_i:std_logic;
 signal hist_i,done_i:std_logic;
 signal sad_i:std_logic_vector(18 downto 0);
 signal p1_i,p2_i:std_logic_vector(47 downto 0);
 signal pob_ind,evol_ind,eval_ind:std_logic_vector(47 downto 0);
 signal descendants:std_logic;
 signal publish_elite:std_logic;
 signal valid_i:std_logic;
begin
 resultado <= p1_i;
 valido    <= valid_i;

 -- Publish elites at the normal generation boundary and once more at the
 -- final Hmejor pulse. This makes p1_i contain the best individual including
 -- the last evaluated generation.
 publish_elite <= hguar_i or hmejor_i;

 -- Sticky result-valid flag: once the final elite is published, resultado
 -- remains valid until reset. At the Hmejor edge, elit and valid_i update in
 -- the same clock event; after delta propagation resultado=p1_i is final.
 process(clk,rst)
 begin
  if rst='0' then
   valid_i <= '0';
  elsif rising_edge(clk) then
   if hmejor_i='1' then valid_i <= '1'; end if;
  end if;
 end process;

 -- C16 protocol correction: do not select evol until its first descendant
 -- has actually been captured by the Hpmut-enabled output register.
 process(clk,rst)
 begin
  if rst='0' then descendants<='0';
  elsif rising_edge(clk) then
   if hpmut_i='1' then descendants<='1'; end if;
  end if;
 end process;
 eval_ind <= evol_ind when descendants='1' else pob_ind;

 u_ctrl:entity work.control_ga
  generic map(Npob=>Npob,Ngen=>Ngen,Nbins=>512)
  port map(clk=>clk,rst=>rst,fin_hist=>hist_i,fin_eval=>done_i,
   Hpob_i=>hpob_i,sel=>sel_i,Hguar=>hguar_i,Hcros=>hcros_i,
   Hpmut=>hpmut_i,Hmejor=>hmejor_i,Heval=>heval_i);

 u_pob:entity work.poblacion
  port map(clk=>clk,rst=>rst,enable=>hpob_i,individuo=>pob_ind);

 u_evol:entity work.evol
  generic map(Npadre=>48,Nparam=>16)
  port map(clk=>clk,rst=>rst,Hcros=>hcros_i,Hpmut=>hpmut_i,
   P1=>p1_i,P2=>p2_i,individuo=>evol_ind);

 u_eval_elit:entity work.eval_elit
  port map(clk=>clk,rst=>rst,enable=>'1',teo_start=>heval_i,
   hab_guardar=>publish_elite,individuo=>eval_ind,fin_hist=>hist_i,
   eval_done=>done_i,SAD=>sad_i,p1=>p1_i,p2=>p2_i);
end;
