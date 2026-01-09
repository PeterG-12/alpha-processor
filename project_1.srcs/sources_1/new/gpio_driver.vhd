library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity gpio_driver is
    generic(PORTS : integer := 8);
    port(clk, reset : in std_logic;
        gpio_ports : inout std_logic_vector(PORTS - 1 downto 0);
        gpio_output_mode, gpio_write_data : in std_logic_vector(PORTS - 1 downto 0);
        gpio_read_data : out std_logic_vector(PORTS - 1 downto 0));
end gpio_driver;

architecture Structural of gpio_driver is

begin

    pindrivers : for i in 0 to PORTS - 1 generate
        gpio_pindriver_inst: entity work.gpio_pindriver
         port map(
            gpio_interface => gpio_ports(i),
            gpio_read_data => gpio_read_data(i),
            clk => clk,
            reset => reset,
            gpio_write_data => gpio_write_data(i),
            gpio_output_mode => gpio_output_mode(i)
        );
    end generate;

end Structural;
