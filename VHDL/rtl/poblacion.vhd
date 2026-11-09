-- ============================================================================
-- Clean migrated GA source. Initial-population generator using three seeded LFSRs.
-- Suggested descriptive name (documentation only; NOT applied): initial_population_generator
-- Original identifiers are intentionally retained wherever verified.
-- ============================================================================
library ieee;
use ieee.std_logic_1164.all;

-- Migrated version of poblacion.
-- M - Migration only: the three Intel-generated lpm_constant_N wrappers
-- are replaced by the portable generic lpm_constant entity.
-- PRNG structure, seeds, bit mapping and timing are unchanged.
entity poblacion is
    generic (
        Nprng : integer := 16
    );
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        enable    : in  std_logic;
        individuo : out std_logic_vector(47 downto 0)
    );
end entity;

architecture rtl of poblacion is
    signal prng_reset : std_logic;
    signal seed_0 : std_logic_vector(15 downto 0);
    signal seed_1 : std_logic_vector(15 downto 0);
    signal seed_2 : std_logic_vector(15 downto 0);
    signal individuo_int : std_logic_vector(47 downto 0);
begin
    -- C7/M: external GA reset is active-low; prng_lfsr reset is active-high.
    prng_reset <= not rst;

    -- Original poblacion/lpm_constant_0: LPM_CVALUE=500, LPM_WIDTH=16
    u_seed_0 : entity work.lpm_constant
        generic map (
            LPM_CVALUE => 500,
            LPM_WIDTH  => 16
        )
        port map (result => seed_0);

    -- Original poblacion/lpm_constant_1: LPM_CVALUE=200, LPM_WIDTH=16
    u_seed_1 : entity work.lpm_constant
        generic map (
            LPM_CVALUE => 200,
            LPM_WIDTH  => 16
        )
        port map (result => seed_1);

    -- Original poblacion/lpm_constant_2: LPM_CVALUE=896, LPM_WIDTH=16
    u_seed_2 : entity work.lpm_constant
        generic map (
            LPM_CVALUE => 896,
            LPM_WIDTH  => 16
        )
        port map (result => seed_2);

    u_prng_0 : entity work.prng_lfsr
        generic map (Nprng => 16)
        port map (
            clk    => clk,
            reset  => prng_reset,
            enable => enable,
            seed   => seed_0,
            prng_o => individuo_int(47 downto 32)
        );

    u_prng_1 : entity work.prng_lfsr
        generic map (Nprng => 16)
        port map (
            clk    => clk,
            reset  => prng_reset,
            enable => enable,
            seed   => seed_1,
            prng_o => individuo_int(31 downto 16)
        );

    u_prng_2 : entity work.prng_lfsr
        generic map (Nprng => 16)
        port map (
            clk    => clk,
            reset  => prng_reset,
            enable => enable,
            seed   => seed_2,
            prng_o => individuo_int(15 downto 0)
        );

    individuo <= individuo_int;
end architecture;
