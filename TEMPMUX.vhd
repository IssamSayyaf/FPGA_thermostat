library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TEMPMUX is
    port (
        -- system
        clk           : in  bit;
        rst_n         : in  bit;
        -- Inputs (ashynchronous)
        current_temp   : in  unsigned(6 downto 0);
        desired_temp   : in  unsigned(6 downto 0);
        display_select : in  bit;
        cool           : in  bit;
        heat           : in  bit;
        -- Outputs
        temp_display   : out unsigned(6 downto 0);
        furance_on     : out bit;
        ac_on          : out bit
    );
end TEMPMUX;

architecture RTL of TEMPMUX is
    signal r_cur,  r_des : unsigned(6 downto 0);
    signal r_sel         : bit;
    signal r_cool, r_heat: bit;
    signal r_disp        : unsigned(6 downto 0);
    signal r_ac,  r_fur  : bit;
begin
    process (clk, rst_n)
    begin
        -- synchronous reset
        if rst_n = '0' then
            r_cur  <= (others => '0');
            r_des  <= (others => '0');
            r_sel  <= '0';
            r_cool <= '0';
            r_heat <= '0';
            r_disp <= (others => '0');
            r_ac   <= '0';
            r_fur  <= '0';
        elsif rising_edge(clk) then
            ------------------------------------------------------
            -- ❶ PIPELINE STAGE: sample raw pins
            ------------------------------------------------------
            r_cur  <= current_temp;
            r_des  <= desired_temp;
            r_sel  <= display_select;
            r_cool <= cool;
            r_heat <= heat;

            ------------------------------------------------------
            -- ❷ LOGIC on the registered inputs
            ------------------------------------------------------
            if r_sel = '1' then
                r_disp <= r_cur;
            else
                r_disp <= r_des;
            end if;

            if (r_cool = '1') and (r_heat = '0') and (r_cur >  r_des) then
                r_ac  <= '1';
                r_fur <= '0';
            elsif (r_cool = '0') and (r_heat = '1') and (r_cur < r_des) then
                r_ac  <= '0';
                r_fur <= '1';
            else
                r_ac  <= '0';
                r_fur <= '0';
            end if;

            -- drive ports
            temp_display <= r_disp;
            ac_on        <= r_ac;
            furance_on   <= r_fur;
        end if;
    end process;

end RTL;


-- architecture RTL of TEMPMUX is
--     -- registered inputs
--     signal r_cur,  r_des : unsigned(6 downto 0);
--     signal r_sel         : std_logic;
--     signal r_cool, r_heat: std_logic;

--     -- pure-combinational outputs
--     signal c_disp        : unsigned(6 downto 0);
--     signal c_ac,  c_fur  : std_logic;

--     -- registered outputs
--     signal r_disp        : unsigned(6 downto 0);
--     signal r_ac,  r_fur  : std_logic;
-- begin
--     ----------------------------------------------------------------
--     -- 1) SAMPLE RAW INPUTS
--     ----------------------------------------------------------------
--     input_reg : process (clk)
--     begin
--         if rising_edge(clk) then
--             if rst_n = '0' then
--                 r_cur  <= (others => '0');
--                 r_des  <= (others => '0');
--                 r_sel  <= '0';
--                 r_cool <= '0';
--                 r_heat <= '0';
--             else
--                 r_cur  <= current_temp;
--                 r_des  <= desired_temp;
--                 r_sel  <= display_select;
--                 r_cool <= cool;
--                 r_heat <= heat;
--             end if;
--         end if;
--     end process;

--     ----------------------------------------------------------------
--     -- 2) PURE COMBINATIONAL LOGIC
--     ----------------------------------------------------------------
--     comb : process (r_cur, r_des, r_sel, r_cool, r_heat)
--     begin
--         -- multiplexer
--         if r_sel = '1' then
--             c_disp <= r_cur;
--         else
--             c_disp <= r_des;
--         end if;

--         -- HVAC
--         if (r_cool = '1') and (r_heat = '0') and (r_cur >  r_des) then
--             c_ac  <= '1';
--             c_fur <= '0';
--         elsif (r_cool = '0') and (r_heat = '1') and (r_cur < r_des) then
--             c_ac  <= '0';
--             c_fur <= '1';
--         else
--             c_ac  <= '0';
--             c_fur <= '0';
--         end if;
--     end process;

--     ----------------------------------------------------------------
--     -- 3) REGISTER THE OUTPUTS
--     ----------------------------------------------------------------
--     output_reg : process (clk)
--     begin
--         if rising_edge(clk) then
--             if rst_n = '0' then
--                 r_disp <= (others => '0');
--                 r_ac   <= '0';
--                 r_fur  <= '0';
--             else
--                 r_disp <= c_disp;
--                 r_ac   <= c_ac;
--                 r_fur  <= c_fur;
--             end if;
--         end if;
--     end process;

--     -- drive entity ports
--     temp_display <= r_disp;
--     ac_on        <= r_ac;
--     furance_on   <= r_fur;
-- end RTL;
