library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity FSM_ROM is
    generic(ADDRESS_SIZE : integer;
            DATA_WIDTH : integer);
    port(address : in std_logic_vector(ADDRESS_SIZE - 1 downto 0);
        data_output : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end FSM_ROM;

architecture Behavioral of FSM_ROM is

begin


end Behavioral;
