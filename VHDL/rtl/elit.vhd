-- ============================================================================
-- Clean migrated GA source. Keeps the two best individuals globally and publishes them on hab_guardar.
-- Suggested descriptive name (documentation only; NOT applied): elite_selector
-- Original identifiers are intentionally retained wherever verified.
-- ============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity elit is
  generic(Npadre:natural:=48; Ncost:natural:=19; NParam:natural:=16);
  port(
    dato        : in std_logic_vector(Npadre+Ncost-1 downto 0);
    dato_valid  : in std_logic;
    hab_guardar : in std_logic;
    rst         : in std_logic;
    clk         : in std_logic;
    p1          : out std_logic_vector(Npadre-1 downto 0);
    p2          : out std_logic_vector(Npadre-1 downto 0)
  );
end;

architecture rtl of elit is
  constant Ndato:natural:=Npadre+Ncost;
  signal reg1,reg2:std_logic_vector(Ndato-1 downto 0);
  signal reg_p1,reg_p2:std_logic_vector(Npadre-1 downto 0);
begin
  process(rst,clk)
    variable dc,c1,c2:unsigned(Ncost-1 downto 0);
  begin
    if rst='0' then
      reg1 <= (others=>'1');
      reg2 <= (others=>'1');
    elsif rising_edge(clk) then
      if dato_valid='1' then
        dc := unsigned(dato(Ndato-1 downto Npadre));
        c1 := unsigned(reg1(Ndato-1 downto Npadre));
        c2 := unsigned(reg2(Ndato-1 downto Npadre));
        if dc < c1 then
          reg2 <= reg1;
          reg1 <= dato;
        elsif (dc > c1) and (dc < c2) then
          reg2 <= dato;
        end if;
      end if;
    end if;
  end process;

  process(rst,clk)
  begin
    if rst='0' then
      reg_p1 <= (others=>'0'); reg_p2 <= (others=>'0');
    elsif rising_edge(clk) then
      if hab_guardar='1' then
        reg_p1 <= reg1(Npadre-1 downto 0);
        reg_p2 <= reg2(Npadre-1 downto 0);
      end if;
    end if;
  end process;
  p1<=reg_p1; p2<=reg_p2;
end;
