-- Module for FSM that decides whether the OPCODE is a type of jump
-- And whether the result of flagjump module needs to be considered

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity jumpconsider_module is
    generic(OPCODE_WIDTH : integer;
            UPPER_BOUND : integer;
            LOWER_BOUND : integer
    );
    port(
        opcode : in std_logic_vector(OPCODE_WIDTH - 1 downto 0);
        is_jump : out std_logic
    );
end jumpconsider_module;

architecture Behavioral of jumpconsider_module is

signal upper_bound_signal : std_logic_vector(OPCODE_WIDTH - 1 downto 0) := std_logic_vector(to_unsigned(UPPER_BOUND, OPCODE_WIDTH));
signal lower_bound_signal : std_logic_vector(OPCODE_WIDTH - 1 downto 0) := std_logic_vector(to_unsigned(LOWER_BOUND, OPCODE_WIDTH));

signal upper_less_than : std_logic;

signal lower_equal : std_logic;
signal lower_equal_negated : std_logic;

component comparator is
    generic(BIT_WIDTH : integer;
            SIGNED_MODE : boolean 
    );
    port(
        input_a, input_b : in std_logic_vector(BIT_WIDTH - 1 downto 0);
        greater_than, equal, less_than : out std_logic
    );
end component;

begin

    upper_comparator : comparator
    generic map(
        BIT_WIDTH => OPCODE_WIDTH,
        SIGNED_MODE => FALSE
    )
    port map(
        input_a => opcode,
        input_b => upper_bound_signal,
        less_than => upper_less_than,
        equal => open,
        greater_than => open
    );

    lower_comparator : comparator
    generic map(
        BIT_WIDTH => OPCODE_WIDTH,
        SIGNED_MODE => FALSE
    )
    port map(
        input_a => opcode,
        input_b => lower_bound_signal,
        less_than => open,
        equal => lower_equal,
        greater_than => open
    );

    lower_equal_negated <= not lower_equal;

    is_jump <= upper_less_than and lower_equal_negated;
end Behavioral;
