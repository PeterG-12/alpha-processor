library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity FSMsim is
--  Port ( );
end FSMsim;

architecture Behavioral of FSMsim is


component FSM is
    generic(OPCODE_WIDTH : integer;
        COUNT_BIT_WIDTH : integer;
        JUMPTYPES_WIDTH : integer;
        DATA_WIDTH : integer := 30;
        ADDRESS_SIZE : integer := 9);
    port(opcode : in std_logic_vector(OPCODE_WIDTH - 1 downto 0);
        clk, reset : in std_logic;
        -- flags from ALU
        sign_f, overflow_f, zero_f : in std_logic;
    -- Full list of control, select and write-enable signals controlling
    -- the entire CPU flow logic
        pcwe    : out std_logic;
        adrsel  : out std_logic_vector(1 downto 0);
        segsel  : out std_logic;
        bssel   : out std_logic;
        arwe    : out std_logic;
        ramw    : out std_logic;
        irwe    : out std_logic;
        drwe    : out std_logic;
        memssel : out std_logic_vector(1 downto 0);
        rwsel   : out std_logic_vector(1 downto 0);
        rwe     : out std_logic;
        xywe    : out std_logic;
        xsel    : out std_logic_vector(1 downto 0);
        ysel    : out std_logic_vector(1 downto 0);
        alum    : out std_logic_vector(3 downto 0);
        aluwe   : out std_logic;
        pcsel   : out std_logic_vector(1 downto 0);
        cswe    : out std_logic;
        dswe    : out std_logic;
        dsel    : out std_logic
    );
end component;

-- Constants for generics (adjust as needed for your FSM)
    constant OPCODE_W : integer := 6;
    constant COUNT_BW : integer := 3;
    constant JUMPTYPES_WIDTH : integer := 3;

    -- Inputs
    signal tb_opcode : std_logic_vector(OPCODE_W - 1 downto 0) := (others => '0');
    signal tb_clk    : std_logic := '0';
    signal tb_reset  : std_logic := '1'; -- Initialize reset as active
    signal tb_sign_f, tb_overflow_f, tb_zero_f : std_logic := '0';

    -- Outputs (as signals)
    signal tb_pcwe    : std_logic;
    signal tb_adrsel  : std_logic_vector(1 downto 0);
    signal tb_segsel  : std_logic;
    signal tb_bssel   : std_logic;
    signal tb_arwe    : std_logic;
    signal tb_ramw    : std_logic;
    signal tb_irwe    : std_logic;
    signal tb_drwe    : std_logic;
    signal tb_memssel : std_logic_vector(1 downto 0);
    signal tb_rwsel   : std_logic_vector(1 downto 0);
    signal tb_rwe     : std_logic;
    signal tb_xywe    : std_logic;
    signal tb_xsel    : std_logic_vector(1 downto 0);
    signal tb_ysel    : std_logic_vector(1 downto 0);
    signal tb_alum    : std_logic_vector(3 downto 0);
    signal tb_aluwe   : std_logic;
    signal tb_pcsel   : std_logic_vector(1 downto 0);
    signal tb_cswe    : std_logic;
    signal tb_dswe    : std_logic;
    signal tb_dsel    : std_logic;

    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut_fsm : FSM
    generic map(
        OPCODE_WIDTH => OPCODE_W,
        COUNT_BIT_WIDTH => COUNT_BW,
        JUMPTYPES_WIDTH => JUMPTYPES_WIDTH
    )
    port map(
        opcode      => tb_opcode,
        clk         => tb_clk,
        reset       => tb_reset,
        sign_f      => tb_sign_f,
        overflow_f  => tb_overflow_f,
        zero_f      => tb_zero_f,
        pcwe        => tb_pcwe,
        adrsel      => tb_adrsel,
        segsel      => tb_segsel,
        bssel       => tb_bssel,
        arwe        => tb_arwe,
        ramw        => tb_ramw,
        irwe        => tb_irwe,
        drwe        => tb_drwe,
        memssel     => tb_memssel,
        rwsel       => tb_rwsel,
        rwe         => tb_rwe,
        xywe        => tb_xywe,
        xsel        => tb_xsel,
        ysel        => tb_ysel,
        alum        => tb_alum,
        aluwe       => tb_aluwe,
        pcsel       => tb_pcsel,
        cswe        => tb_cswe,
        dswe        => tb_dswe,
        dsel        => tb_dsel
    );

    -- Clock generation process
    clk_process : process
    begin
        tb_clk <= '0';
        wait for CLK_PERIOD / 2;
        tb_clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Stimulus process (This is where you will add your test cases)
    stim_process : process
    begin
        -- Hold reset for a few clock cycles
        tb_reset <= '1';
        wait for 2 * CLK_PERIOD;
        tb_reset <= '0';
        wait for CLK_PERIOD;
        tb_opcode <= "000111";
        wait for 4 * CLK_PERIOD;


        wait; -- This will stop the simulation after the stimulus is complete
    end process;

end Behavioral;
