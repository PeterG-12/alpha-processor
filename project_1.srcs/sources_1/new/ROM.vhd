library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ROM is
    generic(DATA_WIDTH : integer);
    port(address : in std_logic_vector(17 downto 0);
        output : out std_logic_vector(DATA_WIDTH - 1 downto 0));
end ROM;

architecture Behavioral of ROM is

type rom_type is array (0 to 2 ** 14 - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
signal internal_memory : rom_type := (
        0 => x"2c20600d",
        1 => x"30200002",
        2 => x"28000002",
        others => (others => '0')
    );

signal cut_address : std_logic_vector(13 downto 0);

begin
    
    cut_address <= address(13 downto 0);
    output <= internal_memory((to_integer(unsigned(cut_address))));

end Behavioral;
