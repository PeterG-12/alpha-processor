library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity custom_register is
    generic(BIT_WIDTH : integer);
    
    port(input : in std_logic_vector(BIT_WIDTH - 1 downto 0);
        write_enable, clk, reset : in std_logic;
        output : out std_logic_vector(BIT_WIDTH - 1 downto 0)
    );
        
end custom_register;

architecture Behavioral of custom_register is

signal internal_memory : std_logic_vector(BIT_WIDTH - 1 downto 0);

begin
    
    process(clk, reset)
    
    begin
    
        if reset = '1' then
            internal_memory <= (others => '0');
        elsif rising_edge(clk) then
            if write_enable = '1' then
                internal_memory <= input;
            else
                internal_memory <= internal_memory;
             end if;
        end if;
        
    end process;
    
    
    output <= internal_memory;

end Behavioral;
