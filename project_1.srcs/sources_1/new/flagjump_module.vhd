-- Module that produces the correct result for different
-- types of jumps based on flags received from the ALU
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity flagjump_module is
    -- Defines the maximum number of jump types
    generic(JUMPSELECT_WIDTH : integer := 3);
    port(jump_select : in std_logic_vector(JUMPSELECT_WIDTH - 1 downto 0);
        -- flags
        sign_f, overflow_f, zero_f : in std_logic;
        output_jump : out std_logic
    );
end flagjump_module;

architecture Behavioral of flagjump_module is

signal sign_xor_overflow : std_logic;
signal sign_xnor_overflow : std_logic;
signal zero_negated : std_logic;

-- zero_negated and sign_xnor_overflow
signal zero_negated_and_xnor : std_logic;

-- zero or sign_xor_overflow
signal zero_or_xor : std_logic; 

begin
    sign_xor_overflow <= sign_f xor overflow_f;
    sign_xnor_overflow <= sign_f xnor overflow_f;
    zero_negated <= not zero_f;

    zero_negated_and_xnor <= zero_negated and sign_xnor_overflow;
    zero_or_xor <= zero_f and sign_xor_overflow;

    process
    begin
        -- if JUMPSELECT_WIDTH is not 3 this part needs to be manually edited to fit new number of jump types
        case jump_select is
            when "001" => output_jump <= zero_f;
            when "010" => output_jump <= zero_negated;
            when "011" => output_jump <= sign_xor_overflow;
            when "100" => output_jump <= zero_negated_and_xnor;
            when "101" => output_jump <= sign_xnor_overflow;
            when "110" => output_jump <= zero_or_xor;
            when others => output_jump <= '0';
        end case;
    end process;

end Behavioral;
