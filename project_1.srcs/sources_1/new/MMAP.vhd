library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MMAP is
    generic(BIT_WIDTH : integer;
            OPCODE_WIDTH : integer := 6;
            ADDRESS_SIZE : integer;
            START_ADDRESS : integer);
    port(mem_addr : in std_logic_vector(BIT_WIDTH -1 downto 0);
        opcode : in std_logic_vector(OPCODE_WIDTH - 1 downto 0);
        irwe : in std_logic;
        sel_consider : out std_logic;
        sel_out : out std_logic_vector(ADDRESS_SIZE - 1 downto 0));
end MMAP;

architecture Behavioral of MMAP is

signal is_mapped : std_logic;
signal normalized_address : unsigned(BIT_WIDTH - 1 downto 0);
signal normalized_address_vector : std_logic_vector(BIT_WIDTH - 1 downto 0);
constant start_address_unsigned : unsigned := to_unsigned(START_ADDRESS, BIT_WIDTH);

begin


process(opcode, irwe, is_mapped)
begin
    if is_mapped = '1' and irwe = '0' and (opcode = "001010" or opcode = "001100") then
        sel_consider <= '1';
    else
        sel_consider <= '0';
    end if;
end process;


normalized_address <= unsigned(mem_addr) - start_address_unsigned;

process(normalized_address)
begin
    if normalized_address < 2**ADDRESS_SIZE then
        is_mapped <= '1';
    else
        is_mapped <= '0';
    end if;
end process;

normalized_address_vector <= std_logic_vector(normalized_address);
sel_out <= normalized_address_vector(ADDRESS_SIZE - 1 downto 0);

end Behavioral;
