library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity interrupt_controller is
    port(reset, clk : in std_logic;
        pciwe : in std_logic; -- required as a control signal
        timer_int, peripheral_int, external_int : in std_logic;
        interrupt_address : out std_logic_vector(15 downto 0);
        control_unit_any_interrupt_signal : out std_logic
    );
end interrupt_controller;

architecture Behavioral of interrupt_controller is

type address_rom_type is array (0 to 7) of std_logic_vector(15 downto 0);

signal timer_int_buffer_clear : std_logic := '0';
signal timer_int_buffer_out : std_logic;

signal peripheral_int_buffer_clear : std_logic := '0';
signal peripheral_int_buffer_out : std_logic;


signal external_int_buffer_clear : std_logic := '0';
signal external_int_buffer_out : std_logic;

signal effective_interrupt_address : std_logic_vector(2 downto 0);


-- Signals for encoder
signal any_interrupt_signal : std_logic;
signal encoder_interrupt_address : std_logic_vector(2 downto 0);

constant address_rom : address_rom_type := (
    0 => x"0100",
    1 => x"0180",
    2 => x"0200",
    others => x"2000"
);

begin

    timer_int_buffer: entity work.internal_interrupt_buffer
     port map(
        clk => clk,
        interrupt => timer_int,
        reset => reset,
        clear => timer_int_buffer_clear,
        interrupt_buffer_out => timer_int_buffer_out
    );

    peripheral_int_buffer: entity work.internal_interrupt_buffer
     port map(
        clk => clk,
        interrupt => peripheral_int,
        reset => reset,
        clear => peripheral_int_buffer_clear,
        interrupt_buffer_out => peripheral_int_buffer_out
    );

    external_int_buffer: entity work.internal_interrupt_buffer
        port map(
        clk => clk,
        interrupt => external_int,
        reset => reset,
        clear => external_int_buffer_clear,
        interrupt_buffer_out => external_int_buffer_out
    );

    any_interrupt_signal <= timer_int_buffer_out or peripheral_int_buffer_out or external_int_buffer_out;
    -- Encoder process
    process(timer_int_buffer_out, peripheral_int_buffer_out, external_int_buffer_out)
    begin
        if peripheral_int_buffer_out = '1' then
            encoder_interrupt_address <= "000";
        elsif timer_int_buffer_out = '1' then
            encoder_interrupt_address <= "001";
        elsif external_int_buffer_out = '1' then
            encoder_interrupt_address <= "010";
        else
            encoder_interrupt_address <= "000";
        end if;
    end process;



effective_interrupt_address <= encoder_interrupt_address when any_interrupt_signal = '1' else "000";

peripheral_int_buffer_clear <= pciwe when effective_interrupt_address = "000" else '0';
timer_int_buffer_clear <= pciwe when effective_interrupt_address = "001" else '0';
external_int_buffer_clear <= pciwe when effective_interrupt_address = "010" else '0';

-- Outputs
interrupt_address <= address_rom(to_integer(unsigned(effective_interrupt_address)));
control_unit_any_interrupt_signal <= any_interrupt_signal;

end Behavioral;
