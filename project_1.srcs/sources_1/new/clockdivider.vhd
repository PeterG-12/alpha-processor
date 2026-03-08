library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity cpu_timer is
    generic(FREQ : integer);
    port(clk_in, reset : in std_logic;
        pulse_out : out std_logic);
end cpu_timer;

architecture Behavioral of cpu_timer is

signal internal_count : integer range 0 to FREQ := 0; -- for 100Mhz clock

begin
process(clk_in, reset)
begin
    if reset = '1' then
        internal_count <= 0;
        pulse_out <= '0';
    elsif rising_edge(clk_in) then
        
        if internal_count = FREQ then
            pulse_out <= '1';
            internal_count <= 0;
        else
            pulse_out <= '0';
            internal_count <= internal_count + 1;
        end if;
        
    end if;
end process;


end Behavioral;
