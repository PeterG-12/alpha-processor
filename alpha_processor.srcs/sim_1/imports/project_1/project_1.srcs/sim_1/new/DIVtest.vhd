library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DIVtest is
-- Testbench has no ports
end DIVtest;

architecture Behavioral of DIVtest is

    -- 1. Component Declaration
    -- Must match the entity port list of your current DIV design
    component DIV is
        generic(BIT_WIDTH : integer);
        port(
            clk, reset, dividing : in std_logic;
            ALU_standby          : out std_logic;
            divisor, dividend    : in std_logic_vector(BIT_WIDTH - 1 downto 0);
            quotient, remainder  : out std_logic_vector(BIT_WIDTH - 1 downto 0)
        );
    end component;

    -- 2. Configuration Constants
    constant BIT_WIDTH_TB : integer := 16;
    constant CLK_PERIOD   : time := 10 ns;

    -- 3. Signal Declarations
    signal clk         : std_logic := '0';
    signal reset       : std_logic := '0';
    signal start       : std_logic := '0'; -- Maps to 'dividing'
    signal ALU_standby : std_logic;
    
    signal divisor     : std_logic_vector(BIT_WIDTH_TB - 1 downto 0) := (others => '0');
    signal dividend    : std_logic_vector(BIT_WIDTH_TB - 1 downto 0) := (others => '0');
    signal quotient    : std_logic_vector(BIT_WIDTH_TB - 1 downto 0);
    signal remainder   : std_logic_vector(BIT_WIDTH_TB - 1 downto 0);

begin

    -- 4. Instantiate the Unit Under Test (UUT)
    uut: DIV
        generic map (
            BIT_WIDTH => BIT_WIDTH_TB
        )
        port map (
            clk         => clk,
            reset       => reset,
            dividing    => start, -- User prompt calls it 'start', port is 'dividing'
            ALU_standby => ALU_standby,
            divisor     => divisor,
            dividend    => dividend,
            quotient    => quotient,
            remainder   => remainder
        );

    -- 5. Clock Generation Process
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- 6. Stimulus Process
    stim_proc: process
    begin
        -- INITIAL STATE
        -- "start DIVISOR and Dividened are all 0"
        -- "START and RESET are '0'"
        reset    <= '0';
        start    <= '0';
        divisor  <= (others => '0');
        dividend <= (others => '0');

        -- "After 1 clock cycle edge rising"
        wait until rising_edge(clk);
        
        -- APPLY INPUTS
        -- "divisor becomes 100" (Decimal 4)
        divisor  <= std_logic_vector(to_unsigned(4, BIT_WIDTH_TB));
        -- "Dividened 1101" (Decimal 13)
        dividend <= std_logic_vector(to_unsigned(13, BIT_WIDTH_TB));
        -- "And start also becomes '1'"
        start    <= '1';

        -- "17 more rising edses all the same inputs remain"
        for i in 1 to 17 loop
            wait until rising_edge(clk);
        end loop;

        -- "On the next rising edge start becomes '0'"
        -- "and stays that way for the rest of the sim"
        start <= '0';

        -- Wait indefinitely to observe result stability
        wait;
    end process;

end Behavioral;