library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spidriver is
    generic(CLK_IDLE : std_logic := '0');
    port(clk, reset, start_transfer, register_address : in std_logic;
        data_in : in std_logic_vector(7 downto 0);
        data_out : out std_logic_vector(7 downto 0);
        miso : in std_logic;
        mosi, sck : out std_logic;
        cs_vector : out std_logic_vector(4 downto 0);
        finished : out std_logic;
        addr : in std_logic_vector(2 downto 0));
end spidriver;

architecture Behavioral of spidriver is

type state_type is (Standby, Transfer, BackToStandby);
signal curr_state : state_type := Standby;

constant CLOCK_FREQ : integer := 100000000;
constant SPI_FREQ : integer := 1000000; 
constant FREQ_RATIO : integer := CLOCK_FREQ / SPI_FREQ; 

constant BACK_COUNT : integer := 100;

signal back_to_standby_counter : integer range 1 to BACK_COUNT := 1;
signal freq_divider_counter : integer range 1 to FREQ_RATIO := 1;
signal spi_counter : integer range 0 to 8 := 0;
signal internal_buffer : std_logic_vector(7 downto 0) := x"00";
signal address_buffer : std_logic_vector(2 downto 0);

signal sync_1, sync_2 : std_logic := '0';

signal start_transfer_buffered : std_logic := '0';
signal start_transfer_rising : std_logic := '0';


begin


    process(clk, reset)

    begin
        if rising_edge(clk) then
            if reset = '1' then
                internal_buffer <= (others => '0');
                sck <= CLK_IDLE;
                curr_state <= Standby;
                spi_counter <= 0;
                freq_divider_counter <= 1;
                sync_1 <= '0';
                sync_2 <= '0';
                back_to_standby_counter <= 1;
                address_buffer <= (others => '0');
                start_transfer_buffered <= '0';
                start_transfer_rising <= '0';
                finished <= '0';
            else
                start_transfer_buffered <= start_transfer;
                if start_transfer_buffered = '0' and  start_transfer = '1' then
                    start_transfer_rising <= '1';
                else
                    start_transfer_rising <= '0';
                end if;

                if register_address = '1' then 
                        address_buffer <= addr;
                end if;

                sync_1 <= miso;
                sync_2 <= sync_1;

                if curr_state = Standby then
                    finished <= '0';
                    sck <= CLK_IDLE;
                    if  start_transfer_rising = '1' then
                        curr_state <= Transfer;
                        spi_counter <= 0;
                        internal_buffer <= data_in;
                        freq_divider_counter <= 1;
                        mosi <= data_in(7);
                    end if;
                end if;


                if curr_state = Transfer then
                    if freq_divider_counter = FREQ_RATIO / 4 then
                        sck <= CLK_IDLE;
                    elsif freq_divider_counter = FREQ_RATIO / 2 then
                        mosi <= internal_buffer(7);
                    elsif freq_divider_counter = 3 * FREQ_RATIO / 4 then
                        sck <= not CLK_IDLE;
                    elsif freq_divider_counter = FREQ_RATIO then
                        internal_buffer <= internal_buffer(6 downto 0) & sync_2;
                        freq_divider_counter <= 1;
                        spi_counter <= spi_counter + 1;
                    end if;
                    
                    if spi_counter = 8 then
                        curr_state <= BackToStandby;
                        data_out <= internal_buffer;
                        spi_counter <= 0;
                        freq_divider_counter <= 1;
                    end if;

                    if freq_divider_counter < FREQ_RATIO then
                        freq_divider_counter <= freq_divider_counter + 1;
                    end if;
                end if;
                
                if curr_state = BackToStandby then
                    sck <= CLK_IDLE;
                    mosi <= '0';
                    if back_to_standby_counter = BACK_COUNT then
                        finished <= '1';
                        back_to_standby_counter <= 1;
                        curr_state <= Standby;
                    else 
                        back_to_standby_counter <= back_to_standby_counter + 1;
                    end if;
                end if;



                -- CS Handling
                if curr_state = Transfer or curr_state = BackToStandby then
                    case address_buffer is
                        when "001" => cs_vector <= "11110";
                        when "010" => cs_vector <= "11101";
                        when "011" => cs_vector <= "11011";
                        when "100" => cs_vector <= "10111";
                        when "101" => cs_vector <= "01111";
                        when others => cs_vector <= "11111";
                    end case;
                else
                    cs_vector <= "11111";
                end if;

            end if;
        end if;
    end process;

end Behavioral;
