-- ==============================================================================
-- TEMPMUX: Digital Thermostat Controller
-- ==============================================================================
-- Description: A complete digital thermostat system that controls heating and 
--              cooling systems based on temperature readings and user inputs.
--              The system uses a finite state machine to manage transitions
--              between different operational modes.
-- ==============================================================================

library ieee;
use ieee.std_logic_1164.all;  -- Standard logic types and functions
use ieee.numeric_std.all;     -- Numeric operations and conversions

entity TEMPMUX is
    port (
        -- =========================
        -- System Control Signals
        -- =========================
        clk           : in  std_ulogic;  -- System clock for synchronous operation
        rst_n         : in  std_ulogic;  -- Active-low asynchronous reset
        
        -- =========================
        -- Temperature & Control Inputs (Asynchronous from sensors/user interface)
        -- =========================
        current_temp   : in  std_logic_vector(6 downto 0);  -- Current temperature reading (0-127°F)
        desired_temp   : in  std_logic_vector(6 downto 0);  -- User-set target temperature (0-127°F)
        display_select : in  std_ulogic;                     -- Display mode selector (current/desired temp)
        cool           : in  std_ulogic;                     -- Cooling mode enable from user interface
        heat           : in  std_ulogic;                     -- Heating mode enable from user interface
        furance_hot    : in  std_ulogic;                     -- Furnace hot status feedback sensor
        ac_ready       : in  std_ulogic;                     -- AC ready status feedback sensor
        
        -- =========================
        -- System Control Outputs
        -- =========================
        fan_on         : out std_ulogic;                     -- Fan control signal
        temp_display   : out std_logic_vector(6 downto 0);   -- Temperature display output
        furance_on     : out std_ulogic;                     -- Furnace control signal
        ac_on          : out std_ulogic                      -- Air conditioning control signal
    );
end TEMPMUX;

architecture RTL of TEMPMUX is
    -- =========================
    -- State Machine Definition
    -- =========================
    -- Thermostat operates in seven distinct states:
    -- IDLE:         System idle, monitoring temperature but no active heating/cooling
    -- HEATON:       Heating mode activated, furnace starting up
    -- FURNACENOWHOT: Furnace is hot and actively heating, fan circulating warm air
    -- FURNACECOOL:  Furnace cooling down after heating cycle
    -- COOLON:       Cooling mode activated, AC starting up  
    -- ACNOWREADY:   AC is ready and actively cooling, fan circulating cool air
    -- ACDONE:       AC cooling down after cooling cycle
    type STATE_THERMOSTATE is (IDLE, HEATON, FURNACENOWHOT, FURNACECOOL, COOLON, ACNOWREADY, ACDONE);
    signal CURRENT_STATE, NEXT_STATE : STATE_THERMOSTATE;
    
    -- =========================
    -- Registered Input Signals (Pipeline Stage 1)
    -- =========================
    -- All inputs are registered to improve timing and eliminate metastability
    signal r_cur         : std_logic_vector(6 downto 0);  -- Registered current temperature
    signal r_des         : std_logic_vector(6 downto 0);  -- Registered desired temperature  
    signal r_sel         : std_ulogic;                    -- Registered display select
    signal r_cool        : std_ulogic;                    -- Registered cool mode enable
    signal r_heat        : std_ulogic;                    -- Registered heat mode enable
    signal r_furance_hot : std_ulogic;                    -- Registered furnace hot status
    signal r_ac_ready    : std_ulogic;                    -- Registered AC ready status
    
    -- =========================
    -- Internal Control Signals
    -- =========================
    signal r_disp        : std_logic_vector(6 downto 0);  -- Internal display register
    signal r_ac          : std_ulogic;                    -- Internal AC control signal
    signal r_fur_on      : std_ulogic;                    -- Internal furnace control signal  
    signal r_fan_on      : std_ulogic;                    -- Internal fan control signal


    -- combinational “next” controls from FSM
    signal next_ac            : std_ulogic := '0';
    signal next_fur_on        : std_ulogic := '0';
    signal next_fan_on        : std_ulogic := '0';
begin
    -- =========================
    -- Input Registration Process
    -- =========================
    -- Purpose: Registers all asynchronous inputs on clock edge to:
    --         1. Improve timing closure
    --         2. Eliminate metastability from async inputs
    --         3. Create a stable pipeline stage for state machine
    input_reg : process (clk)
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                -- Reset all registered inputs to safe default values
                r_cur         <= (others => '0');  -- Temperature starts at 0
                r_des         <= (others => '0');  -- Desired temp starts at 0
                r_sel         <= '0';              -- Display select to current temp
                r_cool        <= '0';              -- Cooling mode disabled
                r_heat        <= '0';              -- Heating mode disabled
                r_furance_hot <= '0';              -- Furnace not hot
                r_ac_ready    <= '0';              -- AC not ready
                CURRENT_STATE <= IDLE;             -- Start in IDLE state
            else
                -- Register all inputs on each clock cycle
                r_cur         <= current_temp;     -- Capture current temperature
                r_des         <= desired_temp;     -- Capture desired temperature
                r_sel         <= display_select;   -- Capture display selection
                r_cool        <= cool;             -- Capture cooling enable
                r_heat        <= heat;             -- Capture heating enable
                r_furance_hot <= furance_hot;      -- Capture furnace status
                r_ac_ready    <= ac_ready;         -- Capture AC ready status
                CURRENT_STATE <= NEXT_STATE;       -- Update state machine
            end if;
        end if;
    end process;

    -- =========================
    -- Finite State Machine Process
    -- =========================
    -- Purpose: Implements the main thermostat control logic as a Moore state machine
    --         Determines next state and output values based on current state and inputs
    --         Uses registered inputs to ensure stable operation
    state_machine : process (CURRENT_STATE, r_cur, r_des, r_cool, r_heat, r_furance_hot, r_ac_ready)
        -- Internal signals for output assignment (declared here to avoid synthesis issues)
        variable v_ac_on   : std_ulogic;
        variable v_fur_on  : std_ulogic;
        variable v_fan_on  : std_ulogic;
    begin
        -- Default output values (prevent latches in synthesis)
        v_ac_on  := '0';
        v_fur_on := '0';
        v_fan_on := '0';
        NEXT_STATE <= CURRENT_STATE;  -- Default: stay in current state
        
        case CURRENT_STATE is
            when IDLE =>
                -- System monitoring state - check if heating or cooling is needed
                if r_cool = '1' and r_heat = '0' and unsigned(r_cur) > unsigned(r_des) then
                    -- Cooling requested and current temp > desired temp
                    NEXT_STATE <= COOLON;
                elsif r_cool = '0' and r_heat = '1' and unsigned(r_cur) < unsigned(r_des) then
                    -- Heating requested and current temp < desired temp
                    NEXT_STATE <= HEATON;
                else
                    -- No action needed, stay idle
                    NEXT_STATE <= IDLE;
                end if;
                -- All systems off in idle state
                v_ac_on  := '0';
                v_fur_on := '0';
                v_fan_on := '0';

            when HEATON =>
                -- Heating startup state - turn on furnace and wait for it to heat up
                if r_furance_hot = '1' then
                    -- Furnace is now hot, move to active heating
                    NEXT_STATE <= FURNACENOWHOT;
                else
                    -- Furnace still heating up, stay in this state
                    NEXT_STATE <= HEATON;
                end if;
                -- Turn on furnace, keep AC off, fan off during startup
                v_fur_on := '1';
                v_ac_on  := '0';
                v_fan_on := '0';

            when FURNACENOWHOT =>
                -- Active heating state - furnace hot, fan circulating warm air
                if not (unsigned(r_cur) < unsigned(r_des) and r_heat = '1') then
                    -- Either reached target temp or heating disabled
                    NEXT_STATE <= FURNACECOOL;
                else
                    -- Continue heating
                    NEXT_STATE <= FURNACENOWHOT;
                end if;
                -- Furnace on, fan on to circulate warm air, AC off
                v_fur_on := '1';
                v_ac_on  := '0';
                v_fan_on := '1';

            when FURNACECOOL =>
                -- Furnace cooldown state - let furnace cool while fan continues
                if r_furance_hot = '0' then
                    -- Furnace cooled down, return to idle
                    NEXT_STATE <= IDLE;
                else
                    -- Furnace still cooling, stay in this state
                    NEXT_STATE <= FURNACECOOL;
                end if;
                -- Turn off furnace, keep fan on for cooldown, AC off
                v_fur_on := '0';
                v_ac_on  := '0';
                v_fan_on := '1';

            when COOLON =>
                -- Cooling startup state - turn on AC and wait for it to be ready
                if r_ac_ready = '1' then
                    -- AC is ready, move to active cooling
                    NEXT_STATE <= ACNOWREADY;
                else
                    -- AC still starting up, stay in this state
                    NEXT_STATE <= COOLON;
                end if;
                -- Turn on AC, keep furnace off, fan off during startup
                v_ac_on  := '1';
                v_fur_on := '0';
                v_fan_on := '0';

            when ACNOWREADY =>
                -- Active cooling state - AC ready, fan circulating cool air
                if not (unsigned(r_cur) > unsigned(r_des) and r_cool = '1') then
                    -- Either reached target temp or cooling disabled
                    NEXT_STATE <= ACDONE;
                else
                    -- Continue cooling
                    NEXT_STATE <= ACNOWREADY;
                end if;
                -- AC on, fan on to circulate cool air, furnace off
                v_ac_on  := '1';
                v_fur_on := '0';
                v_fan_on := '1';

            when ACDONE =>
                -- AC cooldown state - let AC cool while fan continues
                if r_ac_ready = '0' then
                    -- AC cooled down, return to idle
                    NEXT_STATE <= IDLE;
                else
                    -- AC still cooling, stay in this state
                    NEXT_STATE <= ACDONE;
                end if;
                -- Turn off AC, keep fan on for cooldown, furnace off
                v_fur_on := '0';
                v_ac_on  := '0';
                v_fan_on := '1';

            when others =>
                -- Safety state - should never reach here
                NEXT_STATE <= IDLE;
                v_ac_on  := '0';
                v_fur_on := '0';
                v_fan_on := '0';
        end case;
        
        -- Assign internal control signals from variables
        next_ac  <= v_ac_on;
        next_fur_on <= v_fur_on;
        next_fan_on <= v_fan_on;
    end process;

    -- =========================
    -- Output Registration Process
    -- =========================
    -- Purpose: Registers all outputs to ensure synchronous operation and prevent glitches
    --         Creates a clean pipeline stage between state machine and external signals
    output_reg : process (clk)
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                -- Reset all outputs to safe default values
                r_disp   <= (others => '0');  -- Display shows 0 temperature
                r_ac     <= '0';              -- AC off
                r_fur_on <= '0';              -- Furnace off
                r_fan_on <= '0';              -- Fan off
            else
                -- Register outputs from state machine
                if r_sel = '0' then
                    r_disp <= r_cur;          -- Display current temperature when select = 0
                else
                    r_disp <= r_des;          -- Display desired temperature when select = 1
                end if;
                r_ac     <= next_ac;             -- Register AC control signal
                r_fur_on <= next_fur_on;         -- Register furnace control signal
                r_fan_on <= next_fan_on;         -- Register fan control signal
            end if;
        end if;
    end process;

    -- =========================
    -- Output Assignment
    -- =========================
    -- Purpose: Connect internal registered signals to entity outputs
    --         Provides clean, glitch-free outputs to external systems
    temp_display <= r_disp;      -- Temperature display (current or desired based on r_sel)
    ac_on        <= r_ac;        -- Air conditioning control output
    furance_on   <= r_fur_on;    -- Furnace control output  
    fan_on       <= r_fan_on;    -- Fan control output
end RTL;

