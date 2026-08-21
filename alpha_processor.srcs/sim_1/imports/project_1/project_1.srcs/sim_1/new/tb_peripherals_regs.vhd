library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_peripherals_regs is
-- Testbench has no ports
end tb_peripherals_regs;

architecture Behavioral of tb_peripherals_regs is

    -- Component Declaration
    component peripherals_regs is
        generic(
            BIT_WIDTH : integer;
            ADDRESS_SIZE : integer
        );
        port(
            clk, reset, ramwe, mmap_consider : in std_logic;
            out0, out1, pdatout : out std_logic_vector(BIT_WIDTH - 1 downto 0);
            in0, in1, pdatin : in std_logic_vector(BIT_WIDTH - 1 downto 0);
            mmap_sel : in std_logic_vector(ADDRESS_SIZE - 1 downto 0)
        );
    end component;

    -- Constants
    constant BIT_WIDTH : integer := 16;
    constant ADDRESS_SIZE : integer := 2; -- Test with 2-bit address (0 to 3)
    constant CLK_PERIOD : time := 10 ns;

    -- Inputs
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal ramwe : std_logic := '0';
    signal mmap_consider : std_logic := '0';
    signal in0 : std_logic_vector(BIT_WIDTH - 1 downto 0) := (others => '0');
    signal in1 : std_logic_vector(BIT_WIDTH - 1 downto 0) := (others => '0');
    signal pdatin : std_logic_vector(BIT_WIDTH - 1 downto 0) := (others => '0');
    signal mmap_sel : std_logic_vector(ADDRESS_SIZE - 1 downto 0) := (others => '0');

    -- Outputs
    signal out0 : std_logic_vector(BIT_WIDTH - 1 downto 0);
    signal out1 : std_logic_vector(BIT_WIDTH - 1 downto 0);
    signal pdatout : std_logic_vector(BIT_WIDTH - 1 downto 0);

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: peripherals_regs
    generic map(
        BIT_WIDTH => BIT_WIDTH,
        ADDRESS_SIZE => ADDRESS_SIZE
    )
    port map(
        clk => clk,
        reset => reset,
        ramwe => ramwe,
        mmap_consider => mmap_consider,
        out0 => out0,
        out1 => out1,
        pdatout => pdatout,
        in0 => in0,
        in1 => in1,
        pdatin => pdatin,
        mmap_sel => mmap_sel
    );

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
        -- 1. RESET SEQUENCE
        report "Starting Reset...";
        reset <= '1';
        wait for CLK_PERIOD * 2;
        reset <= '0';
        wait for CLK_PERIOD;

        -- ===============================================================
        -- TEST 1: WRITING TO PERIPHERALS (OUTPUTS)
        -- ===============================================================
        
        -- A. Write 0xAAAA to OUT0 (Address 0)
        report "Test 1A: Write to OUT0 (Address 0)";
        mmap_sel <= std_logic_vector(to_unsigned(0, ADDRESS_SIZE));
        pdatin <= x"AAAA";
        mmap_consider <= '1'; -- We are addressing MMIO
        ramwe <= '1';         -- We are writing
        
        wait for CLK_PERIOD; -- Wait for clock edge
        
        -- Clear controls
        ramwe <= '0';
        mmap_consider <= '0';
        
        wait for CLK_PERIOD; -- Wait for data to propagate
        
        assert out0 = x"AAAA" report "Fail: OUT0 did not latch 0xAAAA" severity error;
        assert out1 = x"0000" report "Fail: OUT1 changed when writing to OUT0!" severity error;

        -- B. Write 0xBBBB to OUT1 (Address 1)
        report "Test 1B: Write to OUT1 (Address 1)";
        mmap_sel <= std_logic_vector(to_unsigned(1, ADDRESS_SIZE));
        pdatin <= x"BBBB";
        mmap_consider <= '1';
        ramwe <= '1';
        
        wait for CLK_PERIOD;
        
        ramwe <= '0';
        mmap_consider <= '0';
        
        wait for CLK_PERIOD;
        
        assert out1 = x"BBBB" report "Fail: OUT1 did not latch 0xBBBB" severity error;
        assert out0 = x"AAAA" report "Fail: OUT0 changed when writing to OUT1!" severity error;


        -- ===============================================================
        -- TEST 2: CONTROL SIGNAL ISOLATION (Safety Check)
        -- ===============================================================
        report "Test 2: Control Signal Isolation";
        
        -- Try to write 0xDEAD to OUT0, but mmap_consider is '0'
        -- This simulates writing to regular RAM (address matches, but MMAP said NO)
        mmap_sel <= std_logic_vector(to_unsigned(0, ADDRESS_SIZE));
        pdatin <= x"DEAD";
        ramwe <= '1';
        mmap_consider <= '0'; -- DISABLED
        
        wait for CLK_PERIOD;
        ramwe <= '0';
        
        assert out0 = x"AAAA" report "Fail: OUT0 updated when mmap_consider was 0!" severity error;

        -- Try to write 0xBEEF to OUT0, but ramwe is '0'
        -- This simulates a READ operation (LDW)
        mmap_consider <= '1';
        ramwe <= '0'; -- DISABLED
        pdatin <= x"BEEF";
        
        wait for CLK_PERIOD;
        
        assert out0 = x"AAAA" report "Fail: OUT0 updated when ramwe was 0!" severity error;


        -- ===============================================================
        -- TEST 3: READING FROM PERIPHERALS (INPUTS)
        -- ===============================================================
        report "Test 3: Reading IN0 and IN1";
        
        -- Set physical inputs
        in0 <= x"1234";
        in1 <= x"5678";
        
        -- A. Read Address 0 (Should get in0)
        mmap_sel <= std_logic_vector(to_unsigned(0, ADDRESS_SIZE));
        
        -- IMPORTANT: Your design has input synchronization registers.
        -- Data takes 1 clock cycle to move from 'in0' to internal reg, then to 'pdatout'.
        wait for CLK_PERIOD * 2; 
        
        assert pdatout = x"1234" report "Fail: Read Addr 0, expected 0x1234 (IN0)" severity error;
        
        -- B. Read Address 1 (Should get in1)
        mmap_sel <= std_logic_vector(to_unsigned(1, ADDRESS_SIZE));
        wait for CLK_PERIOD * 2;
        
        assert pdatout = x"5678" report "Fail: Read Addr 1, expected 0x5678 (IN1)" severity error;


        -- ===============================================================
        -- TEST 4: SPLIT I/O BEHAVIOR
        -- ===============================================================
        report "Test 4: Verify Split I/O (Address 0 In != Address 0 Out)";
        
        -- OUT0 currently holds 0xAAAA (from Test 1A)
        -- IN0 currently holds 0x1234 (from Test 3A)
        
        -- Select Address 0 for reading
        mmap_sel <= std_logic_vector(to_unsigned(0, ADDRESS_SIZE));
        wait for CLK_PERIOD;
        
        -- The DATA BUS (pdatout) should show the INPUT value (Switches)
        assert pdatout = x"1234" report "Fail: Bus should show IN0 value" severity error;
        
        -- The PHYSICAL OUTPUT pin (out0) should still hold the OUTPUT value (LEDs)
        assert out0 = x"AAAA" report "Fail: Output pin changed during read!" severity error;


        -- ===============================================================
        -- TEST 5: UNUSED ADDRESSES
        -- ===============================================================
        report "Test 5: Unused Address 2";
        
        mmap_sel <= std_logic_vector(to_unsigned(2, ADDRESS_SIZE));
        wait for CLK_PERIOD;
        
        -- Your code hardcodes unused input concatenation to '0'
        assert pdatout = x"0000" report "Fail: Unused address should read 0" severity error;

        report "-----------------------------------";
        report "PERIPHERAL REGS TESTS COMPLETE";
        report "-----------------------------------";
        wait;
    end process;

end Behavioral;