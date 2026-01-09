library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity gpio_pindriver is
    port(gpio_interface : inout std_logic;
        gpio_read_data : out std_logic;
        clk, reset, gpio_write_data, gpio_output_mode : in std_logic);
end gpio_pindriver;

architecture Behavioral of gpio_pindriver is

signal debouncer_1, debouncer_2 : std_logic := '0';

begin
    

    gpio_interface <= 'Z' when gpio_output_mode = '0' else gpio_write_data;

    process(clk, reset)
    begin
        if reset ='1' then
            debouncer_1 <= gpio_interface;
            debouncer_2 <= '0';
        elsif rising_edge(clk) then

            debouncer_1 <= gpio_interface;
            debouncer_2 <= debouncer_1;
            gpio_read_data <= debouncer_2;

            
        end if;
    end process;

end Behavioral;
