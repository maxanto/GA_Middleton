-- ============================================================================
-- Clean migrated GA source. GA finite-state controller; includes LOAD_PARENTS synchronization state.
-- Suggested descriptive name (documentation only; NOT applied): ga_controller
-- Original identifiers are intentionally retained wherever verified.
-- ============================================================================
library ieee;
use ieee.std_logic_1164.all;

entity control_ga is
    generic (
        Npob  : natural := 40;
        Ngen  : natural := 100;
        Nbins : natural := 512
    );
    port(
        clk,rst : in std_logic;
        fin_hist : in std_logic;
        fin_eval : in std_logic;
        Hpob_i,sel,Hguar,Hcros,Hpmut,Hmejor,Heval : out std_logic
    );
end entity;

architecture uno of control_ga is

    type state_type is (INICIO,CONTEO,EVAL,ELITE,PADRE,LOAD_PARENTS,CRUCE,MUT,FIN);
    signal state : state_type;

    -- C: these counters represent COMPLETED quantities.
    -- Therefore, they must be able to hold the value Npob.
    signal Cpob_i, Cpob : integer range 0 to Npob;
    signal Cgen         : integer range 0 to Ngen;

begin

    process(clk,rst)
    begin
        if rst='0' then
            state  <= INICIO;
            Cpob_i <= 0;
            Cpob   <= 0;
            Cgen   <= 0;
            Heval  <= '0';
            Hmejor <= '0';

        elsif rising_edge(clk) then
            Heval  <= '0';
            Hmejor <= '0';

            case state is
                when INICIO =>
                    if fin_hist='1' then
                        state <= CONTEO;
                    end if;

                when CONTEO =>
                    -- The original timing reference of Heval is preserved.
                    state <= EVAL;
                    Heval <= '1';

                when EVAL =>
                    if fin_eval='1' then
                        -- The evaluation that just completed counts as
                        -- one completed individual.
                        if Cpob_i < Npob then
                            Cpob_i <= Cpob_i + 1;
                        end if;

                        if Cpob < Npob then
                            Cpob <= Cpob + 1;
                        end if;

                        state <= ELITE;
                    end if;

                when ELITE =>
                    if Cpob_i < Npob then
                        -- The initial population is still being formed.
                        state <= INICIO;
                    elsif Cpob = Npob then
                        -- Population/generation complete.
                        if Cgen = Ngen then
                            state  <= FIN;
                            Hmejor <= '1';
                        else
                            state <= PADRE;
                        end if;
                    else
                        -- Initial population already formed; generate another offspring.
                        state <= CRUCE;
                    end if;

                when PADRE =>
                    -- Publishes the best parents and starts a new generation.
                    Cpob <= 0;
                    if Cgen < Ngen then
                        Cgen <= Cgen + 1;
                    end if;
                    -- C9: allow one full cycle for elit to publish p1/p2.
                    state <= LOAD_PARENTS;

                when LOAD_PARENTS =>
                    -- C9: on the outgoing edge of this state, the internal
                    -- registers of evol capture the already published p1/p2.
                    state <= CRUCE;

                when CRUCE =>
                    state <= MUT;

                when MUT =>
                    -- The timing sequence CROSSOVER -> MUT -> EVAL is preserved.
                    state <= EVAL;
                    Heval <= '1';

                when FIN =>
                    state <= FIN;
            end case;
        end if;
    end process;

    process(state)
    begin
        case state is
            when INICIO =>
                Hpob_i<='1'; sel<='0'; Hguar<='0'; Hcros<='0'; Hpmut<='0';
            when CONTEO =>
                Hpob_i<='0'; sel<='0'; Hguar<='0'; Hcros<='0'; Hpmut<='0';
            when EVAL =>
                Hpob_i<='0'; sel<='0'; Hguar<='0'; Hcros<='0'; Hpmut<='0';
            when ELITE =>
                Hpob_i<='0'; sel<='0'; Hguar<='0'; Hcros<='0'; Hpmut<='0';
            when PADRE =>
                Hpob_i<='0'; sel<='0'; Hguar<='1'; Hcros<='0'; Hpmut<='0';
            when LOAD_PARENTS =>
                Hpob_i<='0'; sel<='0'; Hguar<='0'; Hcros<='0'; Hpmut<='0';
            when CRUCE =>
                Hpob_i<='0'; sel<='1'; Hguar<='0'; Hcros<='1'; Hpmut<='0';
            when MUT =>
                Hpob_i<='0'; sel<='0'; Hguar<='0'; Hcros<='0'; Hpmut<='1';
            when FIN =>
                Hpob_i<='0'; sel<='0'; Hguar<='0'; Hcros<='0'; Hpmut<='0';
        end case;
    end process;

end uno;
