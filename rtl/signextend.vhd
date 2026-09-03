library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity signextend is
    generic(
        BIT_WIDTH_IN : integer;
        BIT_WIDTH_OUT : integer
    );
    port(inputs : in std_logic_vector(BIT_WIDTH_IN - 1 downto 0);
        outputs : out std_logic_vector(BIT_WIDTH_OUT - 1 downto 0)    
    );
end signextend;

architecture Behavioral of signextend is

begin

    assert (BIT_WIDTH_OUT >= BIT_WIDTH_IN)
        report "Output width must be greater than or equal to input width."
        severity ERROR;

    outputs(BIT_WIDTH_OUT - 1 downto BIT_WIDTH_IN) <= (others => inputs(BIT_WIDTH_IN - 1));
    outputs(BIT_WIDTH_IN - 1 downto 0) <= inputs;

end Behavioral;
