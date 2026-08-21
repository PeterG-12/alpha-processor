library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_MMAP is
-- Testbench has no ports
end tb_MMAP;

architecture Behavioral of tb_MMAP is

    -- Component Declaration
    component MMAP is
        generic(
            BIT_WIDTH : integer;
            OPCODE_WIDTH : integer;
            ADDRESS_SIZE : integer;
            START_ADDRESS : integer
        );
        port(
            -- Note: In your latest code, mem_addr is BIT_WIDTH + 1 downto 0 (18 bits)
            mem_addr : in std_logic_vector(BIT_WIDTH + 1 downto 0);
            opcode : in std_logic_vector(OPCODE_WIDTH - 1 downto 0);
            irwe : in std_logic;
            sel_consider : out std_logic;
            sel_out : out std_logic_vector(ADDRESS_SIZE - 1 downto 0)
        );
    end component;

    -- Constants
    constant BIT_WIDTH : integer := 16;
    constant OPCODE_WIDTH : integer := 6;
    constant ADDRESS_SIZE : integer := 5; -- 32 Registers
    constant START_ADDRESS : integer := 65280; -- 0xFF00

    -- Inputs
    -- Width is 17 downto 0 (18 bits) based on your BIT_WIDTH + 1 definition
    signal mem_addr : std_logic_vector(17 downto 0) := (others => '0');
    signal opcode : std_logic_vector(5 downto 0) := (others => '0');
    signal irwe : std_logic := '0';

    -- Outputs
    signal sel_consider : std_logic;
    signal sel_out : std_logic_vector(4 downto 0);

    -- Helper Constants for Readability
    constant OP_LDW    : std_logic_vector(5 downto 0) := "001010";
    constant OP_STOREW : std_logic_vector(5 downto 0) := "001100";
    constant OP_ADD    : std_logic_vector(5 downto 0) := "001111";

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: MMAP
    generic map(
        BIT_WIDTH => BIT_WIDTH,
        OPCODE_WIDTH => OPCODE_WIDTH,
        ADDRESS_SIZE => ADDRESS_SIZE,
        START_ADDRESS => START_ADDRESS
    )
    port map(
        mem_addr => mem_addr,
        opcode => opcode,
        irwe => irwe,
        sel_consider => sel_consider,
        sel_out => sel_out
    );

    -- Stimulus process
    stim_proc: process
    begin
        wait for 10 ns;

        -- =========================================================
        -- TEST 1: BASE ADDRESS HIT (Index 0)
        -- =========================================================
        report "Test 1: Checking Base Address (0xFF00)...";
        
        -- Set valid address (padding the top 2 bits to match 18-bit input)
        mem_addr <= std_logic_vector(to_unsigned(START_ADDRESS, 18));
        opcode <= OP_LDW; -- Valid Opcode
        irwe <= '0';      -- Valid State (Not fetching)
        
        wait for 10 ns;
        
        assert sel_consider = '1' report "Test 1 Failed: Should consider base address" severity error;
        assert to_integer(unsigned(sel_out)) = 0 report "Test 1 Failed: Index should be 0" severity error;


        -- =========================================================
        -- TEST 2: OFFSET ADDRESS HIT (Index 5)
        -- =========================================================
        report "Test 2: Checking Offset Address (0xFF05)...";
        
        mem_addr <= std_logic_vector(to_unsigned(START_ADDRESS + 5, 18));
        
        wait for 10 ns;
        
        assert sel_consider = '1' report "Test 2 Failed: Should consider offset address" severity error;
        assert to_integer(unsigned(sel_out)) = 5 report "Test 2 Failed: Index should be 5" severity error;


        -- =========================================================
        -- TEST 3: MAX ADDRESS HIT (Index 31)
        -- =========================================================
        report "Test 3: Checking Max Address (0xFF1F)...";
        
        mem_addr <= std_logic_vector(to_unsigned(START_ADDRESS + 31, 18));
        
        wait for 10 ns;
        
        assert sel_consider = '1' report "Test 3 Failed: Should consider max address" severity error;
        assert to_integer(unsigned(sel_out)) = 31 report "Test 3 Failed: Index should be 31" severity error;


        -- =========================================================
        -- TEST 4: BOUNDARY CHECK - TOO HIGH (0xFF20)
        -- =========================================================
        report "Test 4: Checking Overflow Address (0xFF20)...";
        
        mem_addr <= std_logic_vector(to_unsigned(START_ADDRESS + 32, 18));
        
        wait for 10 ns;
        
        assert sel_consider = '0' report "Test 4 Failed: Should IGNORE address > Max" severity error;


        -- =========================================================
        -- TEST 5: BOUNDARY CHECK - TOO LOW (0xFEFF)
        -- =========================================================
        report "Test 5: Checking Underflow Address (0xFEFF)...";
        
        mem_addr <= std_logic_vector(to_unsigned(START_ADDRESS - 1, 18));
        
        wait for 10 ns;
        
        assert sel_consider = '0' report "Test 5 Failed: Should IGNORE address < Base" severity error;


        -- =========================================================
        -- TEST 6: INVALID OPCODE CHECK
        -- =========================================================
        report "Test 6: Checking Invalid Opcode (ADD)...";
        
        -- Restore valid address
        mem_addr <= std_logic_vector(to_unsigned(START_ADDRESS, 18));
        -- Set Opcode to ADD (Arithmetic operations shouldn't trigger IO)
        opcode <= OP_ADD;
        
        wait for 10 ns;
        
        assert sel_consider = '0' report "Test 6 Failed: ADD instruction triggered MMIO!" severity error;


        -- =========================================================
        -- TEST 7: INSTRUCTION FETCH CHECK (IRWE = '1')
        -- =========================================================
        report "Test 7: Checking Instruction Fetch (IRWE)...";
        
        opcode <= OP_LDW; -- Valid Opcode
        irwe <= '1';      -- BUT we are loading the Instruction Register (Fetch stage)
        
        wait for 10 ns;
        
        assert sel_consider = '0' report "Test 7 Failed: IRWE='1' triggered MMIO!" severity error;


        -- =========================================================
        -- TEST 8: STOREW CHECK (Valid)
        -- =========================================================
        report "Test 8: Checking STOREW Opcode...";
        
        irwe <= '0';
        opcode <= OP_STOREW;
        
        wait for 10 ns;
        
        assert sel_consider = '1' report "Test 8 Failed: STOREW should trigger MMIO" severity error;

        report "--------------------------------";
        report "MMAP TESTS COMPLETED SUCCESSFULLY";
        report "--------------------------------";
        wait;
    end process;

end Behavioral;