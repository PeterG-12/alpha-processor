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
end entity demultiplexer;

architecture Behavioral of demultiplexer is

begin

    process(sel, input)
        variable sel_int_var : integer range 0 to (2**SEL_NUMBER - 1);
        variable output_var : std_logic_vector((2**SEL_NUMBER * BIT_WIDTH) - 1 downto 0);
    begin
        output_var := (others => '0');
        sel_int_var := to_integer(unsigned(sel));

        output_var(sel_int_var * BIT_WIDTH + BIT_WIDTH - 1 downto sel_int_var * BIT_WIDTH) := input;

        output <= output_var;
    end process;

end architecture Behavioral;