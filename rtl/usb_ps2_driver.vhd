library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity usb_ps2_driver is
    generic(DATA_WIDTH : integer);
    port(ps_clock, ps_data, clk, reset : in std_logic;
        data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0));
end usb_ps2_driver;

architecture Behavioral of usb_ps2_driver is

signal ps_clock_old : std_logic := '0';
signal ps_clock_new : std_logic := '1';
signal received_data : std_logic_vector(10 downto 0) := (others => '0');

signal flip_bit : std_logic := '0'; -- used to indicate whether data is new 

signal parity : std_logic;

signal bit_counter : integer range 0 to 10;

signal count_overflow : std_logic := '0';

begin
    process(clk, reset)
    begin
        if reset = '1' then
            ps_clock_old <= '0';
            ps_clock_new <= '1';
            received_data <= (others => '0');
            flip_bit <= '0';
            bit_counter <= 0;
            count_overflow <= '0';
        elsif rising_edge(clk) then
            ps_clock_old <= ps_clock_new;
            ps_clock_new <= ps_clock;
            count_overflow <= '0';

            if count_overflow = '1' then
                if received_data(0) = '0' and received_data(10) = '1' and (parity xor received_data(9)) = '1' then
                    --data_out(7 downto 0) <= received_data(8 downto 1);
                    --data_out(DATA_WIDTH - 1) <= not flip_bit;
                    --data_out(DATA_WIDTH - 2 downto 8) <= (others => '0');
                    flip_bit <= not flip_bit;
                else
                    --data_out(3 downto 0) <= (others => '1');
                    --data_out(DATA_WIDTH - 1 downto 4) <= (others => '0');
                    --data_out(DATA_WIDTH - 1) <= flip_bit;
                end if;
            end if;


            if ps_clock_new = '0' and ps_clock_old = '1' then
                received_data <= ps_data & received_data(10 downto 1);
                if bit_counter = 10 then
                    bit_counter <= 0;
                    count_overflow <= '1';
                else
                    bit_counter <= bit_counter + 1;
                end if;
            else
                received_data <= received_data;
            end if;
        end if;
    end process;

    parity <= received_data(1) xor received_data(2) xor received_data(3) xor received_data(4) xor 
              received_data(5) xor received_data(6) xor received_data(7) xor received_data(8);

    data_out(3 downto 0) <= (others => '1');
    data_out(DATA_WIDTH - 1 downto 4) <= (others => '0');
    data_out(DATA_WIDTH - 1) <= flip_bit;

end Behavioral;