library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity Switchtossd is
    port(inputvec : in std_logic_vector(15 downto 0);
    clk, reset : in std_logic;
    an : out std_logic_vector(3 downto 0);
    seg : out std_logic_vector(6 downto 0)
);

end Switchtossd;

architecture Behavioral of Switchtossd is
    constant CLOCKFREQ : integer := 100_000_000;
    constant REFRESHFREQ : integer := 1_000;
    constant CLK_CYCLES_PER_DIGIT : integer := CLOCKFREQ/REFRESHFREQ/4;
    signal cdigit_int : integer range 0 to 15 := 0;
    signal mux_counter : integer range 0 to CLK_CYCLES_PER_DIGIT-1 := 0;
    signal digit_select : std_logic_vector(1 downto 0) := "00";
    signal current_digit_hex : std_logic_vector(3 downto 0);
    signal segment_pattern : std_logic_vector(6 downto 0);
begin
        process(clk, reset)
        begin
            if reset = '1' then
                mux_counter <= 0;
                digit_select <= "00";
            elsif clk'event and clk = '1' then
                if mux_counter = CLK_CYCLES_PER_DIGIT - 1 then
                mux_counter <= 0;
                digit_select <= std_logic_vector(unsigned (digit_select) + 1);
                else
                mux_counter <= mux_counter + 1;
                end if;
            end if;
            end process;
            process(inputvec, digit_select)
            begin
                case digit_select is
                    when "00" => current_digit_hex <= inputvec(3 downto 0);
                    when "01" => current_digit_hex <= inputvec(7 downto 4);
                    when "10" => current_digit_hex <= inputvec(11 downto 8);
                    when "11" => current_digit_hex <= inputvec(15 downto 12);
                    when others => current_digit_hex <= (others => '1');
                end case;
            end process;
            process(digit_select)
            begin
                case digit_select is
                    when "00" => an <= "1110";
                    when "01" => an <= "1101";
                    when "10" => an <= "1011";
                    when "11" => an <= "0111";
                    when others => an <= (others => '1');
                end case;
            end process;
            cdigit_int <= to_integer(unsigned(current_digit_hex));
            process(cdigit_int)
            begin
            case cdigit_int is
            when 0 => segment_pattern <= "1000000"; -- 0
            when 1 => segment_pattern <= "1111001"; -- 1
            when 2 => segment_pattern <= "0100100"; -- 2
            when 3 => segment_pattern <= "0110000"; -- 3
            when 4 => segment_pattern <= "0011001"; -- 4
            when 5 => segment_pattern <= "0010010"; -- 5
            when 6 => segment_pattern <= "0000010"; -- 6
            when 7 => segment_pattern <= "1111000"; -- 7
            when 8 => segment_pattern <= "0000000"; -- 8
            when 9 => segment_pattern <= "0010000"; -- 9
            when 10 => segment_pattern <= "0001000"; -- A
            when 11 => segment_pattern <= "0000011"; -- b
            when 12 => segment_pattern <= "1000110"; -- C
            when 13 => segment_pattern <= "0100001"; -- d
            when 14 => segment_pattern <= "0000110"; -- E
            when 15 => segment_pattern <= "0001110"; -- F
            when others => segment_pattern <= "1111111"; -- Blank
            end case;
    end process;
    seg <= segment_pattern;
end Behavioral;