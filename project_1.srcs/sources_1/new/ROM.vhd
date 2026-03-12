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

    0 => x"2fc00000",
1 => x"2d400000",
2 => x"2d600000",
3 => x"2d600003",
4 => x"2c201000",
5 => x"302000ff",
6 => x"2fc00000",
7 => x"2c200820",
8 => x"302000ff",
9 => x"2c200000",
10 => x"302000ff",
11 => x"097e000b",
12 => x"2fc00000",
13 => x"2c20080c",
14 => x"302000ff",
15 => x"2c200000",
16 => x"302000ff",
17 => x"097e0011",
18 => x"2fc00000",
19 => x"2c200810",
20 => x"302000ff",
21 => x"2c200000",
22 => x"302000ff",
23 => x"097e0017",
24 => x"2fc00000",
25 => x"2c200840",
26 => x"302000ff",
27 => x"2c200000",
28 => x"302000ff",
29 => x"097e001d",
30 => x"2c400000",
31 => x"085e0026",
32 => x"2d200008",
33 => x"59490000",
34 => x"2d20ff00",
35 => x"45690000",
36 => x"3d4b0000",
37 => x"1c0a0000",
38 => x"2ce0001e",
39 => x"38e00000",





256 => x"2d000008",
257 => x"07c80112",
258 => x"2d000001",
259 => x"07c80108",
260 => x"2d000002",
261 => x"07c8010f",
262 => x"2fc00003",
263 => x"9c000000",
264 => x"294000ff",
265 => x"2fc00002",
266 => x"2c200800",
267 => x"302000ff",
268 => x"2c200000",
269 => x"302000ff",
270 => x"9c000000",
271 => x"296000ff",
272 => x"2fc00000",
273 => x"9c000000",
274 => x"2fc00001",
275 => x"2c200800",
276 => x"302000ff",
277 => x"2c200000",
278 => x"302000ff",
279 => x"9c000000",




    512 => x"2c200838",
    513 => x"302000ff",
    514 => x"2c200000",
    515 => x"302000ff",
    516 => x"2fc00008",
    517 => x"9c000000",




    others => (others => '0')
    );

signal cut_address : std_logic_vector(13 downto 0);

begin
    
    cut_address <= address(13 downto 0);
    output <= internal_memory((to_integer(unsigned(cut_address))));

end Behavioral;
