library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ps2sim is
-- Empty entity
end ps2sim;

architecture Behavioral of ps2sim is

    component usb_ps2_driver is
        generic(DATA_WIDTH : integer);
        port(
            ps_clock : in std_logic;
            ps_data  : in std_logic;
            clk      : in std_logic;
            reset    : in std_logic;
            data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0)
        );
    end component;

    constant DATA_WIDTH : integer := 16;
    signal ps_clock     : std_logic := '1';
    signal ps_data      : std_logic := '1';
    signal clk          : std_logic := '0';
    signal reset        : std_logic := '0';
    signal data_out     : std_logic_vector(DATA_WIDTH - 1 downto 0);

    -- 1. HYPER-FAST SETTINGS
    -- System Clock: 10ns (100 MHz)
    constant CLK_PERIOD : time := 10 ns; 
    -- PS/2 Clock: 100ns (10 MHz) - Unrealistic but great for viewing
    constant PS2_PERIOD : time := 100 ns;  

begin

    uut: usb_ps2_driver
        generic map (DATA_WIDTH => DATA_WIDTH)
        port map (
            ps_clock => ps_clock, ps_data => ps_data,
            clk => clk, reset => reset, data_out => data_out
        );

    -- System Clock
    process
    begin
        clk <= '0'; wait for CLK_PERIOD/2;
        clk <= '1'; wait for CLK_PERIOD/2;
    end process;

    -- Stimulus
    process
        procedure send_key(code : std_logic_vector(7 downto 0)) is
            variable frame : std_logic_vector(10 downto 0);
            variable parity : std_logic;
        begin
            -- Parity Logic
            if (code(0) xor code(1) xor code(2) xor code(3) xor 
                code(4) xor code(5) xor code(6) xor code(7)) = '0' then
                parity := '1';
            else
                parity := '0';
            end if;

            -- Build Frame: [Stop, Parity, Data, Start]
            frame := '1' & parity & code & '0';

            -- Bit-Bang Loop
            for i in 0 to 10 loop
                -- 1. Set Data
                ps_data <= frame(i);
                wait for PS2_PERIOD / 4; 
                -- 2. Drop Clock
                ps_clock <= '0';
                wait for PS2_PERIOD / 2;
                -- 3. Raise Clock
                ps_clock <= '1';
                wait for PS2_PERIOD / 4;
            end loop;
            
            -- Idle
            ps_data <= '1';
            wait for PS2_PERIOD * 2; 
        end procedure;

    begin
        -- 1. Quick Reset
        reset <= '1';
        wait for 20 ns; -- Short reset
        reset <= '0';
        wait for 20 ns;

        -- 2. Send 'A' (0x1C) immediately
        send_key(x"1C");

        -- 3. Stop
        wait;
    end process;

end Behavioral;