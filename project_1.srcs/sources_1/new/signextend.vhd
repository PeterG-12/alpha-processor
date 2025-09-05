library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity signextend is
    generic(
        BIT_WIDTH_IN : integer;
        BIT_WIDTH_OUT : integer
    );
    port(input : std_logic_vector(BIT_WIDTH_IN - 1 downto 0);
        output : std_logic_vector(BIT_WIDTH_OUT - 1 downto 0)    
    );
end signextend;

architecture Behavioral of signextend is

begin

    assert (BIT_WIDTH_OUT >= BIT_WIDTH_IN)
        report "Output width must be greater than or equal to input width."
        severity ERROR;

    output <= (others => input(BIT_WIDTH_IN - 1));
    output(BIT_WIDTH_IN - 1 downto 0) <= input;

end Behavioral;
