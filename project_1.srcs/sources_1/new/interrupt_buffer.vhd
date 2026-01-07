library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity interrupt_buffer is
    port(clk, interrupt, reset, pciwe : in std_logic;
        intbuf_out : out std_logic);
end interrupt_buffer;

architecture Behavioral of interrupt_buffer is
type state_type is (Empty, Full);
signal current_state, next_state : state_type := Empty;

begin
    process(interrupt, pciwe, current_state)
    begin
        next_state <= current_state;
        case current_state is
            when Empty => intbuf_out <= '0';
                        if interrupt = '1' then
                            next_state <= Full;
                        else
                            next_state <= Empty;
                        end if;
            when Full => intbuf_out <= '1';
                        if interrupt ='0' and pciwe = '1' then
                            next_state <= Empty;
                        else
                            next_state <= Full;
                        end if;
        end case;
    end process;
    
    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= Empty;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;
    
    
    
end Behavioral;
