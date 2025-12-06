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
0 => x"2c60f731",
1 => x"306000ff",
2 => x"284000ff",
3 => x"2c200002",
4 => x"0422000a",
5 => x"2ca00007",
6 => x"38a00000",
7 => x"2c000bad",
8 => x"2ce00000",
9 => x"38e00000",
10 => x"2c00600d",
11 => x"2ce00000",
12 => x"38e00000",




    others => (others => '0')
    );

signal cut_address : std_logic_vector(13 downto 0);

begin
    
    cut_address <= address(13 downto 0);
    output <= internal_memory((to_integer(unsigned(cut_address))));

end Behavioral;
