library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dhtreceiver is
    port(
        clk          : in    std_logic; 
        reset        : in    std_logic;
        start_signal : in    std_logic;
        output_data  : out   std_logic_vector(15 downto 0);
        dht_pin      : inout std_logic
    );
end dhtreceiver;

architecture Behavioral of dhtreceiver is

    type state_type is (Standby, Wait1, Start, Wait2, Wait3, Ready, Read1, Read2, ReadDecide, One, Zero);
    signal curr_state : state_type := Standby;

    constant TICKS_PER_US : integer := 100;

    signal counter : unsigned(31 downto 0) := (others => '0');
    signal bit_count : integer range 0 to 40 := 0;
    signal internal_buffer : std_logic_vector(39 downto 0) := (others => '0');
    signal dht_drive : std_logic := '1'; -- '1' = High-Z, '0' = Drive Low


begin
    
    dht_pin <= '0' when dht_drive = '0' else 'Z';

    process(clk)
        variable hum_h, hum_l, temp_h, temp_l, check_sum : unsigned(7 downto 0);
        variable calculated_sum : unsigned(7 downto 0);
        variable checksum_ok : std_logic := '0';
    begin

        -- Reset state
        if reset = '1' then
            curr_state <= Standby;
            dht_drive <= '1';
            counter <= (others => '0');
            bit_count <= 0;
            internal_buffer <= (others => '0');
        elsif rising_edge(clk) then
            
            -- Based on flowchart
            case curr_state is
                when Standby =>
                    dht_drive <= '1';
                    bit_count <= 0;
                    -- Start the waiting period
                    if start_signal = '1' then
                        counter <= to_unsigned(2000000 * TICKS_PER_US, 32);
                        curr_state <= Wait1;
                    end if;

                when Wait1 =>
                    if counter /= 0 then
                        counter <= counter - 1;
                    else
                        curr_state <= Start;
                    end if;

                when Start =>
                    dht_drive <= '0';
                    counter <= to_unsigned(20000 * TICKS_PER_US, 32);
                    curr_state <= Wait2;

                when Wait2 =>
                    dht_drive <= '1';
                    if counter /= 0 then
                        counter <= counter - 1;
                    else
                        if dht_pin = '0' then
                            counter <= to_unsigned(160 * TICKS_PER_US, 32); 
                            curr_state <= Wait3;
                        end if;
                    end if;

                when Wait3 =>
                    if dht_pin = '1' then
                        curr_state <= Ready;
                    end if;
                    if counter /= 0 then
                        counter <= counter - 1;
                    else
                        curr_state <= Ready;
                    end if;

                when Ready =>
                    if dht_pin = '0' then
                        curr_state <= Read1;
                    end if;

                when Read1 =>
                    if bit_count = 40 then
                        curr_state <= Standby;

                        hum_h  := unsigned(internal_buffer(39 downto 32));
                        hum_l  :=  unsigned(internal_buffer(31 downto 24));
                        temp_h :=  unsigned(internal_buffer(23 downto 16));
                        temp_l :=  unsigned(internal_buffer(15 downto 8));
                        check_sum :=  unsigned(internal_buffer(7 downto 0));

                        calculated_sum := hum_h + hum_l + temp_h + temp_l;

                        if calculated_sum = check_sum then
                            output_data <= internal_buffer(39 downto 24);
                        else
                            output_data <= ((others => '1') );
                        end if;
                    elsif dht_pin = '1' then
                        counter <= to_unsigned(45 * TICKS_PER_US, 32);
                        curr_state <= Read2;
                    end if;

                when Read2 =>
                    if counter /= 0 then
                        counter <= counter - 1;
                        if dht_pin = '0' then
                            curr_state <= ReadDecide;
                        end if;
                    else
                        curr_state <= ReadDecide;
                    end if;

                when ReadDecide =>
                    bit_count <= bit_count + 1;
                    if counter = 0 then
                        curr_state <= One; 
                    else
                        curr_state <= Zero;
                    end if;

                when One =>
                    if dht_pin = '0' then
                        internal_buffer <= internal_buffer(38 downto 0) & '1';
                        curr_state <= Read1;
                    end if;

                when Zero =>
                    internal_buffer <= internal_buffer(38 downto 0) & '0';
                    curr_state <= Read1;

                when others =>
                    curr_state <= Standby;
            end case;
        end if;
    end process;

end Behavioral;