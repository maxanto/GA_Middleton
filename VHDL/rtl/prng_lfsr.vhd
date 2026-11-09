library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity prng_lfsr is
    generic (
        Nprng : integer := 8
    );
    port (
        clk    : in  std_logic;
        reset  : in  std_logic;
        enable : in  std_logic := '1';
        seed   : in  std_logic_vector(Nprng-1 downto 0);
        prng_o : out std_logic_vector(Nprng-1 downto 0)
    );
end entity;

architecture rtl of prng_lfsr is

    signal lfsr_reg : std_logic_vector(Nprng-1 downto 0);

    function feedback_maximal(val : std_logic_vector) return std_logic is
        variable fb : std_logic := '0';
        constant W  : integer := val'length;
    begin
        case W is
            when 2  => fb := val(1) xor val(0);
            when 3  => fb := val(2) xor val(1);
            when 4  => fb := val(3) xor val(2);
            when 5  => fb := val(4) xor val(2);
            when 6  => fb := val(5) xor val(4);
            when 7  => fb := val(6) xor val(5);
            when 8  => fb := val(7) xor val(5) xor val(4) xor val(3);
            when 9  => fb := val(8) xor val(4);
            when 10 => fb := val(9) xor val(6);
            when 11 => fb := val(10) xor val(8);
            when 12 => fb := val(11) xor val(10) xor val(9) xor val(3);
            when 13 => fb := val(12) xor val(11) xor val(10) xor val(7);
            when 14 => fb := val(13) xor val(12) xor val(11) xor val(1);
            when 15 => fb := val(14) xor val(13);
            when 16 => fb := val(15) xor val(14) xor val(12) xor val(3);
            when 17 => fb := val(16) xor val(13);
            when 18 => fb := val(17) xor val(10);
            when 19 => fb := val(18) xor val(17) xor val(16) xor val(13);
            when 20 => fb := val(19) xor val(16);
            when 21 => fb := val(20) xor val(18);
            when 22 => fb := val(21) xor val(20);
            when 23 => fb := val(22) xor val(17);
            when 24 => fb := val(23) xor val(22) xor val(21) xor val(16);
            when 25 => fb := val(24) xor val(21);
            when 26 => fb := val(25) xor val(5) xor val(1) xor val(0);
            when 27 => fb := val(26) xor val(4) xor val(1) xor val(0);
            when 28 => fb := val(27) xor val(24);
            when 29 => fb := val(28) xor val(26);
            when 30 => fb := val(29) xor val(5) xor val(3) xor val(0);
            when 31 => fb := val(30) xor val(27);
            when 32 => fb := val(31) xor val(21) xor val(1) xor val(0);
            when others =>
                fb := val(W-1) xor val(W-2);
        end case;
        return fb;
    end function;

    function lfsr_next(val : std_logic_vector) return std_logic_vector is
        variable tmp : std_logic_vector(val'range);
        variable fb  : std_logic;
        constant W   : integer := val'length;
    begin
        fb := feedback_maximal(val);
        tmp := val(W-2 downto 0) & fb;
        return tmp;
    end function;

begin

    process(clk, reset, seed)
    begin
        if reset = '1' then
            if unsigned(seed) /= 0 then
                lfsr_reg <= seed;
            else
                lfsr_reg <= (others => '1');
            end if;

        elsif rising_edge(clk) then
            if enable = '1' then
                lfsr_reg <= lfsr_next(lfsr_reg);
            end if;
        end if;
    end process;

    prng_o <= lfsr_reg;

end architecture;