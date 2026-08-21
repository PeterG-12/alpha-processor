library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_ALU is
-- Testbench has no ports
end tb_ALU;

architecture Behavioral of tb_ALU is

    -- Component Declaration
    component ALU
    generic(BIT_WIDTH_IN : integer);
    port(
        clk, reset : in std_logic;
        alu_mode : in std_logic_vector(3 downto 0);
        A, B : in std_logic_vector(BIT_WIDTH_IN - 1 downto 0);
        Y : out std_logic_vector(2 * BIT_WIDTH_IN - 1 downto 0);
        carry_f, sign_f, zero_f, overflow_f, ALU_standby : out std_logic
    );
    end component;

    -- Constants
    constant BIT_WIDTH : integer := 16;
    constant CLK_PERIOD : time := 10 ns;

    -- Signals
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal alu_mode : std_logic_vector(3 downto 0) := (others => '0');
    signal A : std_logic_vector(BIT_WIDTH - 1 downto 0) := (others => '0');
    signal B : std_logic_vector(BIT_WIDTH - 1 downto 0) := (others => '0');
    
    -- Outputs
    signal Y : std_logic_vector(2 * BIT_WIDTH - 1 downto 0);
    signal carry_f, sign_f, zero_f, overflow_f, ALU_standby : std_logic;

    -- Helper Signals for Verification
    signal quotient_result : std_logic_vector(BIT_WIDTH - 1 downto 0);
    signal remainder_result : std_logic_vector(BIT_WIDTH - 1 downto 0);

begin

    -- Instantiate the UUT
    uut: ALU
    generic map (
        BIT_WIDTH_IN => BIT_WIDTH
    )
    port map (
        clk => clk,
        reset => reset,
        alu_mode => alu_mode,
        A => A,
        B => B,
        Y => Y,
        carry_f => carry_f,
        sign_f => sign_f,
        zero_f => zero_f,
        overflow_f => overflow_f,
        ALU_standby => ALU_standby
    );

    -- Map Output parts for easier reading
    -- Assuming Y(15..0) is Quotient and Y(31..16) is Remainder
    quotient_result  <= Y(BIT_WIDTH - 1 downto 0);
    remainder_result <= Y(2 * BIT_WIDTH - 1 downto BIT_WIDTH);

    -- Clock Process
    clk_process :process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus Process
    stim_proc: process
    begin
        -- Hold reset state
        reset <= '1';
        alu_mode <= "0000"; -- Idle/Default
        wait for 40 ns;
        reset <= '0';
        wait for CLK_PERIOD;

        -- =========================================================
        -- TEST 4: DIVISION (Mode 1101 - Verify this matches your ALU code)
        -- =========================================================
        report "Starting DIVISION Tests...";
        wait for CLK_PERIOD/2;
        alu_mode <= "1101"; -- Set to DIV opcode
        wait for CLK_PERIOD/4;
        alu_mode <= "1111";
        wait for CLK_PERIOD/4;
        alu_mode <= "1101";

        -- Case 4a: Perfect Division (20 / 4 = 5, Rem 0)
        report "Test 4a: 20 / 4";
        A <= std_logic_vector(to_unsigned(20, BIT_WIDTH));
        B <= std_logic_vector(to_unsigned(4, BIT_WIDTH));
        
        -- Wait for operation to start
        wait for CLK_PERIOD; 
        
        -- HANDSHAKE WAIT: Wait while ALU is busy (standby = '1')
        while ALU_standby = '1' loop
            wait for CLK_PERIOD;
        end loop;

        -- Verify
        assert to_integer(unsigned(quotient_result)) = 5 report "DIV Fail: Quotient 20/4 != 5" severity error;
        assert to_integer(unsigned(remainder_result)) = 0 report "DIV Fail: Remainder 20/4 != 0" severity error;

        wait for CLK_PERIOD;

        -- Case 4b: Remainder Division (22 / 4 = 5, Rem 2)
        report "Test 4b: 22 / 4";
        A <= std_logic_vector(to_unsigned(22, BIT_WIDTH));
        B <= std_logic_vector(to_unsigned(4, BIT_WIDTH));
        
        wait for CLK_PERIOD; -- Allow ALU to assert standby
        
        -- HANDSHAKE WAIT
        while ALU_standby = '1' loop
            wait for CLK_PERIOD;
        end loop;

        -- Verify
        assert to_integer(unsigned(quotient_result)) = 5 report "DIV Fail: Quotient 22/4 != 5" severity error;
        assert to_integer(unsigned(remainder_result)) = 2 report "DIV Fail: Remainder 22/4 != 2" severity error;
        
        wait for CLK_PERIOD;

        -- Case 4c: Dividend < Divisor (3 / 10 = 0, Rem 3)
        report "Test 4c: 3 / 10";
        A <= std_logic_vector(to_unsigned(3, BIT_WIDTH));
        B <= std_logic_vector(to_unsigned(10, BIT_WIDTH));
        
        wait for CLK_PERIOD;
        while ALU_standby = '1' loop wait for CLK_PERIOD; end loop;

        assert to_integer(unsigned(quotient_result)) = 0 report "DIV Fail: Quotient 3/10 != 0" severity error;
        assert to_integer(unsigned(remainder_result)) = 3 report "DIV Fail: Remainder 3/10 != 3" severity error;

        wait for CLK_PERIOD;

        -- Case 4d: Division by Zero (Optional - depends on your implementation)
        -- The Dummy model returns (others => '1')
        report "Test 4d: Division by Zero";
        A <= std_logic_vector(to_unsigned(50, BIT_WIDTH));
        B <= (others => '0');

        wait for CLK_PERIOD;
        while ALU_standby = '1' loop wait for CLK_PERIOD; end loop;

        -- Check for generic error value (FFFF)
        assert quotient_result = x"FFFF" report "DIV Fail: DivByZero not handled as expected" severity note;

        
        report "Tests Completed.";
        wait;
    end process;

end Behavioral;