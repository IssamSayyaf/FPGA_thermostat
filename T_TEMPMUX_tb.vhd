--###############################################################
--  Test bench: 8-case truth table for pipelined TEMPMUX
--###############################################################
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity T_TEMPMUX_tb is
end entity;

architecture BENCH of T_TEMPMUX_tb is
    ----------------------------------------------------------------
    --  DUT declaration (matches your latest source verbatim)
    ----------------------------------------------------------------
    component TEMPMUX
        port (
            clk            : in  bit;
            rst_n          : in  bit;
            current_temp   : in  unsigned(6 downto 0);
            desired_temp   : in  unsigned(6 downto 0);
            display_select : in  bit;
            cool           : in  bit;
            heat           : in  bit;
            temp_display   : out unsigned(6 downto 0);
            furance_on     : out bit;
            ac_on          : out bit
        );
    end component;

    ----------------------------------------------------------------
    --  Bench signals
    ----------------------------------------------------------------
    signal clk, rst_n          : bit := '0';
    signal current_temp,
           desired_temp        : unsigned(6 downto 0) := (others => '0');
    signal display_select      : bit := '0';   -- held low in this test
    signal cool, heat          : bit := '0';
    signal temp_display        : unsigned(6 downto 0);
    signal furance_on, ac_on   : bit;
begin
    ----------------------------------------------------------------
    --  Clock: 100 MHz (10 ns period)
    ----------------------------------------------------------------
    clk <= not clk after 5 ns;

    ----------------------------------------------------------------
    --  Reset: low for 25 ns, then high for remainder
    ----------------------------------------------------------------
    rst_proc : process
    begin
        rst_n <= '0';
        wait for 25 ns;
        rst_n <= '1';
        wait;
    end process;

    ----------------------------------------------------------------
    --  Instantiate DUT
    ----------------------------------------------------------------
    UUT : TEMPMUX
        port map (
            clk            => clk,
            rst_n          => rst_n,
            current_temp   => current_temp,
            desired_temp   => desired_temp,
            display_select => display_select,
            cool           => cool,
            heat           => heat,
            temp_display   => temp_display,
            furance_on     => furance_on,
            ac_on          => ac_on
        );

    ----------------------------------------------------------------
    --  Eight 20-ns slots (two clocks each) – no functions, no loops
    ----------------------------------------------------------------
    stim : process
    begin
        -- wait for reset to de-assert and align to a rising edge
        wait until rst_n = '1' and rising_edge(clk);

        -------------------------------------- 000
        current_temp <= to_unsigned(2,7);   -- comparator = FALSE
        desired_temp <= to_unsigned(8,7);
        cool <= '0';   heat <= '0';
        wait for 20 ns;

        -------------------------------------- 001
        heat <= '1';                        -- furnace path
        wait for 20 ns;

        -------------------------------------- 010
        cool <= '1';   heat <= '0';         -- both off
        wait for 20 ns;

        -------------------------------------- 011
        heat <= '1';                        -- both off
        wait for 20 ns;

        -------------------------------------- 100
        current_temp <= to_unsigned(8,7);   -- comparator = TRUE
        desired_temp <= to_unsigned(2,7);
        cool <= '0';   heat <= '0';
        wait for 20 ns;

        -------------------------------------- 101
        heat <= '1';                        -- both off
        wait for 20 ns;

        -------------------------------------- 110
        cool <= '1';   heat <= '0';         -- AC path
        wait for 20 ns;

        -------------------------------------- 111
        heat <= '1';                        -- both off
        wait for 20 ns;

        wait;  -- end simulation
    end process;
end BENCH;
