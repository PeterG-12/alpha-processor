library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity RAM is
    generic(ADDRESS_SIZE : integer;
            DATA_WIDTH : integer);
    port(address : in std_logic_vector(ADDRESS_SIZE - 1 downto 0);
        clk, write_enable, output_enable : in std_logic;
        data_input : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        data_output : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end RAM;

architecture Behavioral of RAM is

type ram_type is array (0 to 2 ** ADDRESS_SIZE - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
signal internal_memory : ram_type := (others=>(others => '0'));
signal internal_address : std_logic_vector(ADDRESS_SIZE - 1 downto 0);
begin

    process(clk)

    begin
        if rising_edge(clk) then
            if write_enable = '1' then
                internal_memory((to_integer(unsigned(address)))) <= data_input;
            end if;

            if output_enable = '1' then
                internal_address <= address;
            else
                internal_address <= internal_address;
            end if;
        end if;
    end process;

    data_output <= internal_memory((to_integer(unsigned(internal_address))));

end Behavioral;
