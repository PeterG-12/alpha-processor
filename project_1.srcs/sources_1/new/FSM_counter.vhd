-- A counter for going trough microoperations in the FSM

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FSM_counter is
    generic(COUNT_BIT_WIDTH : integer);
    port(clk, reset, end_of_cycle : in std_logic;
        output_count : out std_logic_vector(COUNT_BIT_WIDTH - 1 downto 0)
    );
end FSM_counter;



architecture Behavioral of FSM_counter is


signal internal_to_reset : std_logic := '0';

begin


process(clk, reset)

variable internal_count : integer range 0 to (2**COUNT_BIT_WIDTH - 1) := 0;

begin


    if reset = '1' then
        internal_count := 0;
        --internal_to_reset <= '0';
    elsif rising_edge(clk) then
        --internal_to_reset <= end_of_cycle;
        
        if end_of_cycle = '1' then
            internal_count := 0;
        else
            internal_count := internal_count + 1;
        end if;
    end if;

    output_count <= std_logic_vector(to_unsigned(internal_count, COUNT_BIT_WIDTH));

end process;

end Behavioral;
