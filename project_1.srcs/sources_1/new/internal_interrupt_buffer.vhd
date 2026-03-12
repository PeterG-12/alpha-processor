library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity internal_interrupt_buffer is
    port(clk, reset : in std_logic;
        clear, interrupt : in std_logic;
        interrupt_buffer_out : out std_logic);
end internal_interrupt_buffer;

architecture Behavioral of internal_interrupt_buffer is

type state_type is (Empty, Full);
signal curr_state : state_type := Empty;

signal interrupt_delayed : std_logic := '0';
signal interrupt_rising_edge : std_logic := '0';

begin

    process(reset, clk)
    begin
        if reset = '1' then
            curr_state <= Empty;
            interrupt_buffer_out <= '0';
        elsif rising_edge(clk) then
            interrupt_delayed <= interrupt;

            case curr_state is
                when Empty =>
                    interrupt_buffer_out <= '0';
                    if interrupt_rising_edge = '1' then
                        curr_state <= Full;
                    end if;
                when Full =>
                    interrupt_buffer_out <= '1';
                    if (not clear or interrupt_rising_edge) = '0' then
                        curr_state <= Empty;
                    end if;

            end case;
        end if;
    end process;

    interrupt_rising_edge <= '1' when (interrupt_delayed = '0' and interrupt = '1') else '0';
end Behavioral;
