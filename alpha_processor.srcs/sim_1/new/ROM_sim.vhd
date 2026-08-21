library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Testbench entity (no ports)
entity FSM_ROM_tb is
end FSM_ROM_tb;

architecture Behavioral of FSM_ROM_tb is

    -- Define generics for the DUT (Device Under Test)
    constant C_ADDRESS_SIZE : integer := 8;
    constant C_DATA_WIDTH   : integer := 32;

    -- Declare signals to connect to the DUT's ports
    signal s_address      : std_logic_vector(C_ADDRESS_SIZE - 1 downto 0) := (others => '0');
    signal s_data_output  : std_logic_vector(C_DATA_WIDTH - 1 downto 0);

    -- Instantiate the component to be tested
    component FSM_ROM
        generic(ADDRESS_SIZE : integer;
                DATA_WIDTH : integer);
        port(address     : in std_logic_vector(ADDRESS_SIZE - 1 downto 0);
            data_output  : out std_logic_vector(DATA_WIDTH - 1 downto 0)
        );
    end component;

begin

    -- Instantiate the Device Under Test (DUT)
    DUT: FSM_ROM
        generic map (
            ADDRESS_SIZE => C_ADDRESS_SIZE,
            DATA_WIDTH   => C_DATA_WIDTH
        )
        port map (
            address     => s_address,
            data_output => s_data_output
        );

    -- Stimulus process to drive the inputs and verify the outputs
    stimulus_process: process
    begin
        -- Start with a clean slate
        s_address <= (others => '0');
        wait for 10 ns;

        -- Loop through all possible addresses and check the output
        for i in 0 to 2**C_ADDRESS_SIZE - 1 loop
            s_address <= std_logic_vector(to_unsigned(i, C_ADDRESS_SIZE));
            wait for 10 ns;
        end loop;

        -- Wait forever to end the simulation
        wait;
    end process;

end Behavioral;
