library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity demultiplexer is
    generic(SEL_NUMBER : integer;
            BIT_WIDTH : integer);
    port(sel : in std_logic_vector(SEL_NUMBER - 1 downto 0);
        input : in std_logic_vector(BIT_WIDTH - 1 downto 0);
        output : out std_logic_vector((2**SEL_NUMBER * BIT_WIDTH) - 1 downto 0)
        );
        
end demultiplexer;

architecture Behavioral of demultiplexer is

    
begin

    process(sel, input)
        variable sel_int : integer range 0 to (2**SEL_NUMBER - 1);
        variable output_variable : std_logic_vector((2**SEL_NUMBER * BIT_WIDTH) - 1 downto 0);
    begin

        sel_int := to_integer(unsigned(sel));
        output_variable := (others => '0');

        output_variable(sel_int * BIT_WIDTH - 1 downto (sel_int - 1) * BIT_WIDTH) := input;

        output <= output_variable;
    end process;

end Behavioral;
