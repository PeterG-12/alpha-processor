library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity multiplexer is
    generic(SEL_NUMBER : integer;
            BIT_WIDTH : integer);
    port(sel : in std_logic_vector(SEL_NUMBER - 1 downto 0);
        input : in std_logic_vector((2**SEL_NUMBER * BIT_WIDTH) - 1 downto 0);
        output : out std_logic_vector(BIT_WIDTH - 1 downto 0)
        );
        
end multiplexer;

architecture Behavioral of multiplexer is

    signal sel_int : integer range 0 to (2**SEL_NUMBER - 1);

begin

    sel_int <= to_integer(unsigned(sel));
    
    output <= input((sel_int * BIT_WIDTH) + BIT_WIDTH - 1 downto sel_int * BIT_WIDTH);
end Behavioral;
