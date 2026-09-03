library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mux8to1 is
    generic(BIT_WIDTH : integer := 1);
    port(
        sel : in std_logic_vector(2 downto 0);
        in0 : in std_logic_vector(BIT_WIDTH - 1 downto 0);
        in1 : in std_logic_vector(BIT_WIDTH - 1 downto 0);
        in2 : in std_logic_vector(BIT_WIDTH - 1 downto 0);
        in3 : in std_logic_vector(BIT_WIDTH - 1 downto 0);
        in4 : in std_logic_vector(BIT_WIDTH - 1 downto 0);
        in5 : in std_logic_vector(BIT_WIDTH - 1 downto 0);
        in6 : in std_logic_vector(BIT_WIDTH - 1 downto 0);
        in7 : in std_logic_vector(BIT_WIDTH - 1 downto 0);
        mux_out : out std_logic_vector(BIT_WIDTH - 1 downto 0)
        );
        
end mux8to1;

architecture Behavioral of mux8to1 is


begin
    process(in0, in1, in2, in3, in4, in5, in6, in7, sel)
    begin
        case sel is
            when "000" => mux_out <= in0;
            when "001" => mux_out <= in1;
            when "010" => mux_out <= in2;
            when "011" => mux_out <= in3;
            when "100" => mux_out <= in4;
            when "101" => mux_out <= in5;
            when "110" => mux_out <= in6;
            when others => mux_out <= in7;
        end case;
    end process;
    
end Behavioral;
