library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity clockdivider is
    port(clk_in, reset : in std_logic;
        clk_out : out std_logic);
end clockdivider;

architecture Behavioral of clockdivider is

constant FREQ : integer := 100_000_000;
signal internal_count : integer range 0 to FREQ := 0; -- for 100Mhz clock

begin
process(clk_in, reset)
begin
    if reset = '1' then
        internal_count <= 0;
        clk_out <= '0';
    elsif rising_edge(clk_in) then
        
        if internal_count = FREQ then
            clk_out <= '1';
            internal_count <= 0;
        else
            clk_out <= '0';
            internal_count <= internal_count + 1;
        end if;
        
    end if;
end process;


end Behavioral;
