library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity interrupt_flag_module is
    port(ireset, interrupt, ifwe, reset, clk : in std_logic;
        opcode : std_logic_vector(5 downto 0);
        intsel: out std_logic);
end interrupt_flag_module;

architecture Behavioral of interrupt_flag_module is

type state_type is (Unset, Set);
signal current_state: state_type := Unset;
signal next_state : state_type;

signal is_set_i_flag : std_logic;
signal ireset_delayed : std_logic;


begin

-- Helpers
process(clk, reset)
begin
    if reset = '1' then
        ireset_delayed <= '0';
        current_state <= Unset;
    elsif rising_edge(clk) then
        ireset_delayed <= ireset;
        current_state <= next_state;
    end if;
end process;


is_set_i_flag <= '1' when opcode = "100101" else '0';


-- Next state logic
process (current_state, ifwe, is_set_i_flag, interrupt, ireset_delayed)
begin
    if (ifwe = '1') then
        if (is_set_i_flag ='1' or (ireset_delayed = '1' and interrupt = '1')) then
            next_state <= Set;
        else
            next_state <= Unset;
        end if;
    else
        next_state <= current_state;
    end if;
end process;

intsel <= (ireset_delayed and interrupt) when current_state = Unset else '0';


end Behavioral;
