-- ============================================================================
-- Clean migrated GA source. Evaluates one 48-bit individual using theoretical vs empirical distribution SAD.
-- Suggested descriptive name (documentation only; NOT applied): fitness_evaluator
-- Original identifiers are intentionally retained wherever verified.
-- ============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity eval is
    port(
        clk       : in  std_logic;
        rst       : in  std_logic; -- active low
        enable    : in  std_logic; -- starts empirical histogram acquisition
        teo_start : in  std_logic; -- one-cycle evaluation request
        individuo : in  std_logic_vector(47 downto 0);

        fin_hist   : out std_logic;
        flag_sdone : out std_logic; -- one-cycle pulse: final SAD is valid
        SAD        : out std_logic_vector(18 downto 0)
    );
end entity;

architecture rtl of eval is
    signal individuo_reg : std_logic_vector(47 downto 0);
    signal hls_start : std_logic;
    signal hls_done,hls_write : std_logic;
    signal hls_out : std_logic_vector(8 downto 0);
    signal hls_rst : std_logic;

    signal exp_data : unsigned(9 downto 0);
    signal hist_done : std_logic;
    signal empirical_done : std_logic;

    signal teo_reg : unsigned(9 downto 0);
    signal pair_valid : std_logic;
    signal pair_count : integer range 0 to 512;
    signal sad_acc : unsigned(18 downto 0);
begin
    hls_rst <= not rst;
    fin_hist <= hist_done;
    SAD <= std_logic_vector(sad_acc);


    -- C3: capture the complete individual first, then start HLS one clock later.
    process(clk,rst)
    begin
        if rst='0' then
            individuo_reg <= (others=>'0');
            hls_start <= '0';
        elsif rising_edge(clk) then
            hls_start <= teo_start;
            if teo_start='1' then
                individuo_reg <= individuo;
            end if;
        end if;
    end process;

    -- Empirical CCDF:
    -- every HLS write advances exactly one empirical bin.
    -- teo_start is used only to rewind from S_DONE for subsequent evaluations.
    u_emp: entity work.CCDF_empirica
        generic map(
            DATA_WIDTH=>32, DATA_entero=>24, Width_bins=>9,
            Adress_Width=>9, N_BINS=>512, Rango=>128,
            Rango_width=>7, Min=>-90)
        port map(
            clk=>clk, rst=>rst, enable=>enable,
            flag_bin=>hls_write,
            flag_reenvio=>teo_start,
            data_bloque_siguiente=>exp_data,
            flag_sdone=>empirical_done,
            fin_hist=>hist_done);

    u_hls: entity work.ccdf_stream
        port map(
            ap_clk=>clk, ap_rst=>hls_rst, ap_start=>hls_start,
            ap_done=>hls_done, ap_idle=>open, ap_ready=>open,
            A=>individuo_reg(47 downto 32),
            r=>individuo_reg(31 downto 16),
            s=>individuo_reg(15 downto 0),
            out_r_din=>hls_out, out_r_full_n=>'1',
            out_r_write=>hls_write);

    -- At a write edge:
    --   1) capture teo[k]
    --   2) CCDF_empirica advances and produces exp[k]
    -- On the next edge pair_valid=1 and the cost process sees both registered k values.
    process(clk,rst)
    begin
        if rst='0' then
            teo_reg <= (others=>'0');
            pair_valid <= '0';
        elsif rising_edge(clk) then
            pair_valid <= hls_write;
            if hls_write='1' then
                teo_reg <= unsigned(hls_out & '0');
            end if;
        end if;
    end process;

    -- C4/C5/C7/C8:
    -- clear once per evaluation; 19-bit non-wrapping SAD;
    -- exactly 512 aligned pairs; done after pair #512 has been accumulated.
    process(clk,rst)
        variable diff_v : unsigned(9 downto 0);
    begin
        if rst='0' then
            sad_acc <= (others=>'0');
            pair_count <= 0;
            flag_sdone <= '0';
        elsif rising_edge(clk) then
            flag_sdone <= '0';

            if teo_start='1' then
                sad_acc <= (others=>'0');
                pair_count <= 0;
            elsif pair_valid='1' then
                if exp_data >= teo_reg then
                    diff_v := exp_data - teo_reg;
                else
                    diff_v := teo_reg - exp_data;
                end if;

                sad_acc <= sad_acc + resize(diff_v,sad_acc'length);

                if pair_count=511 then
                    pair_count <= 512;
                    flag_sdone <= '1';
                else
                    pair_count <= pair_count + 1;
                end if;
            end if;
        end if;
    end process;

    -- HLS done is intentionally not used as the cost-complete signal:
    -- it coincides with write #512, one clock before the aligned final pair is accumulated.
end architecture;
