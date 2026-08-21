library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mux2to1 is
    generic(BIT_WIDTH : integer := 1);
    port(
        sel : in std_logic;
        in0 : in std_logic_vector(BIT_WIDTH - 1 downto 0);
        in1 : in std_logic_vector(BIT_WIDTH - 1 downto 0);
        mux_out : out std_logic_vector(BIT_WIDTH - 1 downto 0)
        );
        
end mux2to1;

architecture Behavioral of mux2to1 is


begin
    process(in0, in1, sel)
    begin
        case sel is
            when '0' => mux_out <= in0;
            when others => mux_out <= in1;
        end case;
    end process;
    
end Behavioral;
