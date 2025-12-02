library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DIV is
    generic(BIT_WIDTH : integer);
    port(
        clk, reset, dividing : in std_logic;
        ALU_standby : out std_logic;
        divisor, dividend : in std_logic_vector(BIT_WIDTH - 1 downto 0);
        quotient, remainder : out std_logic_vector(BIT_WIDTH - 1 downto 0));
end DIV;

architecture Behavioral of DIV is

    signal holder_register : std_logic_vector(2*BIT_WIDTH - 1 downto 0);
    signal dividing_delay : std_logic;
    signal is_count_zero : std_logic;
    signal internal_count  : integer range 0 to BIT_WIDTH;

begin

    -- Counter
   process (reset, clk)
    begin
        if reset = '1' then
            internal_count <= 0;
        elsif rising_edge(clk) then
            if dividing = '1' and dividing_delay = '0' then
                internal_count <= BIT_WIDTH; 
            elsif internal_count > 0 then
                internal_count <= internal_count - 1;
            end if;
        end if;
    end process;

    is_count_zero <= '1' when internal_count = 0 else '0';

    -- Holder register
    process(reset, clk)

    variable shifted_holder : std_logic_vector(2*BIT_WIDTH - 1 downto 0);

    begin
        if reset = '1' then
            shifted_holder := (others => '0');
        elsif rising_edge(clk) then
            shifted_holder := holder_register;
            if dividing_delay = '1' then

                shifted_holder := shifted_holder(2*BIT_WIDTH - 2 downto 0) & '0';

                if unsigned(shifted_holder(2*BIT_WIDTH - 1 downto BIT_WIDTH)) >= unsigned(divisor) then
                    shifted_holder(2*BIT_WIDTH - 1 downto BIT_WIDTH) := std_logic_vector(unsigned(shifted_holder(2*BIT_WIDTH - 1 downto BIT_WIDTH)) - unsigned(divisor));
                    shifted_holder(0) := '1';
                else
                    shifted_holder := shifted_holder;
                end if;
            else
                shifted_holder := (others => '0'); 
                shifted_holder(BIT_WIDTH - 1 downto 0) := dividend;
            end if;
        end if;
        holder_register <= shifted_holder;
    end process;

    -- Delay register
    process(reset, clk)
    begin
        if reset = '1' then
            dividing_delay <= '0';
        elsif rising_edge(clk) then
            dividing_delay <= dividing;
        end if;
    end process;

    quotient <= holder_register(BIT_WIDTH -1 downto 0);
    remainder <= holder_register(2*BIT_WIDTH -1 downto BIT_WIDTH);

    ALU_standby <= (not is_count_zero) or ((not dividing_delay) and dividing);

end Behavioral;
