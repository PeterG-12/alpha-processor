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
0 => x"2c800700",
1 => x"29400100",
2 => x"30800100",
3 => x"2c800700",
4 => x"2d200008",
5 => x"29400100",
6 => x"45490000",
7 => x"2cc00001",
8 => x"55460000",
9 => x"55460000",
10 => x"55460000",
11 => x"488a0000",
12 => x"2d200010",
13 => x"29400100",
14 => x"45490000",
15 => x"2cc00001",
16 => x"55460000",
17 => x"55460000",
18 => x"55460000",
19 => x"488a0000",
20 => x"2d200020",
21 => x"29400100",
22 => x"45490000",
23 => x"2cc00001",
24 => x"55460000",
25 => x"55460000",
26 => x"55460000",
27 => x"488a0000",
28 => x"29400100",
29 => x"1c0a0000",
30 => x"2ce00002",
31 => x"38e00000",



192 => x"2c200001",
193 => x"3c410000",
194 => x"9c000000",


    others => (others => '0')
    );

signal cut_address : std_logic_vector(13 downto 0);

begin
    
    cut_address <= address(13 downto 0);
    output <= internal_memory((to_integer(unsigned(cut_address))));

end Behavioral;
