library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity comparator is
    generic(BIT_WIDTH : integer;
            SIGNED_MODE : boolean 
    );
    port(
        input_a, input_b : in std_logic_vector(BIT_WIDTH - 1 downto 0);
        greater_than, equal, less_than : out std_logic
    );
end comparator;

architecture Behavioral of comparator is

begin

    process(input_a, input_b)
    
    variable a, b : integer;

    begin
        
        if SIGNED_MODE = TRUE then
            a := to_integer(signed(input_a));
            b := to_integer(signed(input_b));
        else
            a := to_integer(unsigned(input_a));
            b := to_integer(unsigned(input_b));
        end if;

        if a > b then
            greater_than <= '1';
            equal <= '0';
            less_than <= '0';
        elsif a = b then
            greater_than <= '0';
            equal <= '1';
            less_than <= '0';
        else
            greater_than <= '0';
            equal <= '0';
            less_than <= '1';
        end if;
    
    end process;

end Behavioral;
