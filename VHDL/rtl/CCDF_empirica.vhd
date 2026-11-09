-- ============================================================================
-- Clean migrated GA source. Portable empirical cumulative-distribution/histogram reader.
-- Suggested descriptive name (documentation only; NOT applied): empirical_distribution
-- Original identifiers are intentionally retained wherever verified.
-- ============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CCDF_empirica is
    generic(
        DATA_WIDTH   : integer := 32;
        DATA_entero  : integer := 24;
        Width_bins   : integer := 9;
        Adress_Width : integer := 9;
        N_BINS       : integer := 512;
        Rango        : integer := 128;
        Rango_width  : integer := 7;
        Min          : integer := -90
    );
    port(
        clk     : in  std_logic;
        rst     : in  std_logic;
        enable  : in  std_logic;
        flag_bin : in std_logic;
        flag_reenvio : in std_logic;
        data_bloque_siguiente : out unsigned(Width_bins downto 0);
        flag_sdone : out std_logic;
        fin_hist   : out std_logic
    );
end entity;

architecture rtl of CCDF_empirica is
    constant min_u : signed(DATA_WIDTH-1 downto 0) :=
        to_signed(Min*2**DATA_entero, DATA_WIDTH);
    constant max_u : signed(DATA_WIDTH-1 downto 0) :=
        to_signed((Min+Rango)*2**DATA_entero, DATA_WIDTH);
    -- C17.2: the bin index corresponds to Width_bins bits of the
    -- difference (data_u - min_u), starting at BIN_SHIFT. Since it is a
    -- constant shift, expressing it as a slice explicitly documents which
    -- bits form the index and avoids integer conversions
    -- on wider vectors than necessary.
    constant BIN_SHIFT : integer := DATA_entero + Rango_width - Width_bins;

    type state_type is (IDLE, S_READ, S_FLUSH, S_CDF_ACC, S_DONE);
    signal state : state_type;

    type hist_array is array (0 to N_BINS-1) of unsigned(Width_bins-1 downto 0);
    signal hist : hist_array;

    signal cdf : unsigned(Width_bins downto 0);
    signal acc : unsigned(Width_bins downto 0);
    signal idx : integer range 0 to N_BINS-1;

    signal rom_addr : unsigned(Adress_Width-1 downto 0);
    signal rom_en   : std_logic;
    signal rom_data : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal data_u   : signed(DATA_WIDTH-1 downto 0);

    -- Validity pipeline:
     -- rom_en (solicitud) -> rom_valid (dato ROM válido) ->
    -- bin_valid (bin registrado válido) -> histogram write.
    signal rom_valid : std_logic;
    signal bin_valid : std_logic;
    signal bin_register : integer range 0 to N_BINS-1;

    signal ult_dato_rom : std_logic;
begin
    assert DATA_WIDTH = 32
        report "ccdf_rom_sync actual usa palabras de 32 bits" severity failure;
    assert Adress_Width = 9 and N_BINS = 512
        report "La ROM actual contiene 512 muestras; revisar generics" severity failure;
    assert BIN_SHIFT >= 0 and (BIN_SHIFT + Width_bins) <= DATA_WIDTH
        report "Configuracion de bins incompatible con DATA_WIDTH" severity failure;
    assert N_BINS = 2**Width_bins
        report "N_BINS debe coincidir con 2**Width_bins" severity failure;

    u_mem : entity work.ccdf_rom_sync
        port map(
            clk  => clk,
            en   => rom_en,
            addr => rom_addr,
            data => rom_data
        );

    data_u <= signed(rom_data);
    data_bloque_siguiente <= cdf;
    fin_hist <= ult_dato_rom;

    process(clk, rst)
        variable bin_calc  : integer;
        variable bin_delta : unsigned(DATA_WIDTH-1 downto 0);
    begin
        if rst='0' then
            state <= IDLE;
            rom_addr <= (others=>'0');
            rom_en <= '0';
            rom_valid <= '0';
            bin_valid <= '0';
            bin_register <= 0;
            hist <= (others=>(others=>'0'));
            acc <= to_unsigned(512, acc'length);
            cdf <= to_unsigned(512, cdf'length);
            idx <= 0;
            ult_dato_rom <= '0';
            flag_sdone <= '0';

        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    rom_en <= '0';
                    rom_valid <= '0';
                    bin_valid <= '0';

                    if enable='1' then
                        hist <= (others=>(others=>'0'));
                        acc <= to_unsigned(512, acc'length);
                        cdf <= to_unsigned(512, cdf'length);
                        idx <= 0;
                        ult_dato_rom <= '0';
                        flag_sdone <= '0';

                       -- Prepare the first request. The RO
                        rom_addr <= (others=>'0');
                        rom_en <= '1';
                        state <= S_READ;
                    end if;

                when S_READ =>
                    -- 1) Write the bin calculated in the previous cycle.
                    if bin_valid='1' then
                        hist(bin_register) <= hist(bin_register) + 1;
                    end if;

                    -- 2) Consume the ROM request data from the previous cycle 
                    -- exactly once.
                    if rom_valid='1' then
                        if data_u >= min_u and data_u < max_u then
                           -- The range checked above ensures that
                            -- data_u - min_u is non-negative and that these
                            -- Width_bins bits encode exactly 0..N_BINS-1.
                            bin_delta := unsigned(data_u - min_u);
                            bin_calc := to_integer(
                                bin_delta(BIN_SHIFT + Width_bins - 1 downto BIN_SHIFT));
                            bin_register <= bin_calc;
                            bin_valid <= '1';
                        else
                            bin_valid <= '0';
                        end if;
                    else
                        bin_valid <= '0';
                    end if;

                    -- rom_valid accompanies the request made on this edge.
                    rom_valid <= rom_en;

                    -- Issue requests 0..511 only once.
                    if rom_en='1' then
                        if rom_addr = to_unsigned(N_BINS-1, Adress_Width) then
                            -- The last request is made on this edge.
                            rom_en <= '0';
                            state <= S_FLUSH;
                        else
                            rom_addr <= rom_addr + 1;
                        end if;
                    end if;

                when S_FLUSH =>
                   -- Flush the two remaining pipeline stages.
                    if bin_valid='1' then
                        hist(bin_register) <= hist(bin_register) + 1;
                    end if;

                    if rom_valid='1' then
                        if data_u >= min_u and data_u < max_u then
                            bin_delta := unsigned(data_u - min_u);
                            bin_calc := to_integer(
                                bin_delta(BIN_SHIFT + Width_bins - 1 downto BIN_SHIFT));
                            bin_register <= bin_calc;
                            bin_valid <= '1';
                        else
                            bin_valid <= '0';
                        end if;
                    else
                        bin_valid <= '0';
                    end if;

                    rom_valid <= '0';

                    -- If the last bin was written on this edge and there is no
                    -- longer a ROM datum to convert, the histogram is complete.
                    if rom_valid='0' and bin_valid='1' then
                        ult_dato_rom <= '1';
                        idx <= 0;
                        acc <= to_unsigned(512, acc'length);
                        cdf <= to_unsigned(512, cdf'length);
                        state <= S_CDF_ACC;
                    end if;

                when S_CDF_ACC =>
                    if flag_bin='1' then
                        acc <= acc - hist(idx);
                        cdf <= acc - hist(idx);

                        -- C4: prevent idx <= -1.
                        if idx=N_BINS-1 then
                            state <= S_DONE;
                        else
                            idx <= idx + 1;
                        end if;
                    end if;

                when S_DONE =>
                    flag_sdone <= '1';

                    if flag_reenvio='1' then
                        state <= S_CDF_ACC;
                        idx <= 0;
                        acc <= to_unsigned(512, acc'length);
                        cdf <= to_unsigned(512, cdf'length);
                        flag_sdone <= '0';
                    elsif enable='0' then
                        state <= IDLE;
                    end if;
            end case;
        end if;
    end process;
end architecture;

