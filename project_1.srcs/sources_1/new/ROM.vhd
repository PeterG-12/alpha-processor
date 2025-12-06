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
    0 => x"2c200014",
    1 => x"2c400004",
    2 => x"70221800",
    3 => x"2c800005",
    4 => x"0824000a",
    5 => x"2c800000",
    6 => x"0864000a",
    7 => x"2c00600d",
    8 => x"2ce00007",
    9 => x"38e00000",
    10 => x"2c00dead",
    11 => x"2ce0000a",
    12 => x"38e00000",

    others => (others => '0')
    );

signal cut_address : std_logic_vector(13 downto 0);

begin
    
    cut_address <= address(13 downto 0);
    output <= internal_memory((to_integer(unsigned(cut_address))));

end Behavioral;
