library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity gpio_pindriver is
    port(gpio_interface : inout std_logic;
        gpio_read_data : out std_logic;
        clk, reset, gpio_write_data, gpio_output_mode : in std_logic);
end gpio_pindriver;

architecture Behavioral of gpio_pindriver is

signal sync_1, sync_2 : std_logic := '0';

begin
    

    gpio_interface <= 'Z' when gpio_output_mode = '0' else gpio_write_data;

    process(clk, reset)
    begin
        
        if rising_edge(clk) then
            if reset ='1' then
                sync_1 <= '0';
                sync_2 <= '0';
                gpio_read_data <= '0';
            else
                sync_1 <= gpio_interface;
                sync_2 <= sync_1;
                gpio_read_data <= sync_2;
            end if;
            
        end if;
    end process;

end Behavioral;
