library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity reg32bit is
    generic(N : integer);
    
    port(input : in std_logic_vector(N - 1 downto 0);
        write_enable, clk, reset : in std_logic;
        output : out std_logic_vector(N - 1 downto 0)
    );
        
end reg32bit;

architecture Behavioral of reg32bit is

signal internal_memory : std_logic_vector(N downto 0);

begin
    
    process(clk, reset)
    
    begin
    
        if reset = '1' then
            internal_memory <= (others => '0');
        elsif rising_edge(clk) then
            internal_memory <= input;
        end if;
        
        output <= internal_memory;
        
    end process;

end Behavioral;
