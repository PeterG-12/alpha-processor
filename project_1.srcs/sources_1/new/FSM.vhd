-- Finitie state machine enabling multi-cycle workflow

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FSM is
    generic(OPCODE_WIDTH : integer := 6;
        COUNT_BIT_WIDTH : integer := 3;
        JUMPTYPES_WIDTH : integer := 3;
        DATA_WIDTH : integer := 30;
        ADDRESS_SIZE : integer := 9);
    port(opcode : in std_logic_vector(OPCODE_WIDTH - 1 downto 0);
        clk, reset, suspend : in std_logic;
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
end FSM;

architecture Structural of FSM is

    component FSM_counter is
    generic(COUNT_BIT_WIDTH : integer);
    port(clk, reset, end_of_cycle, suspend : in std_logic;
        output_count : out std_logic_vector(COUNT_BIT_WIDTH - 1 downto 0)
    );
    end component;



    component jumpconsider_module is
    generic(OPCODE_WIDTH : integer;
            UPPER_BOUND : integer;
            LOWER_BOUND : integer
    );
    port(
        opcode : in std_logic_vector(OPCODE_WIDTH - 1 downto 0);
        is_jump : out std_logic
    );
    end component;


    component flagjump_module is
    -- Defines the maximum number of jump types
    generic(JUMPTYPES_WIDTH : integer);
    port(jump_type_bits : in std_logic_vector(JUMPTYPES_WIDTH - 1 downto 0);
        -- flags
        sign_f, overflow_f, zero_f : in std_logic;
        output_jump : out std_logic
    );
    end component;

    component FSM_ROM is
        generic(ADDRESS_SIZE : integer := 9;
                DATA_WIDTH : integer := 30);
        port(address : in std_logic_vector(ADDRESS_SIZE - 1 downto 0);
            data_output : out std_logic_vector(DATA_WIDTH - 1 downto 0)
        );
    end component;

    component multiplexer is
        generic(SEL_NUMBER : integer;
                BIT_WIDTH : integer);
        port(sel : in std_logic_vector(SEL_NUMBER - 1 downto 0);
            input : in std_logic_vector((2**SEL_NUMBER * BIT_WIDTH) - 1 downto 0);
            output : out std_logic_vector(BIT_WIDTH - 1 downto 0)
            );
    end component;

    signal end_of_cycle_signal : std_logic;
    signal ROM_address : std_logic_vector(ADDRESS_SIZE - 1 downto 0);

    signal is_jump : std_logic;
    signal consider_jump : std_logic;
    signal jump_type_result : std_logic;
    signal jump_address_select : std_logic_vector(1 downto 0);
    signal ROM_data : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal output_count : std_logic_vector(COUNT_BIT_WIDTH -1 downto 0);

    -- Multiplexer helpers

    signal jump_type_result_vector : std_logic_vector(0 downto 0);
    signal consider_jump_vector : std_logic_vector(0 downto 0);
    signal jump_consider_mux_input_concatenated : std_logic_vector(3 downto 0);

begin

    counter : FSM_counter
    generic map(COUNT_BIT_WIDTH => COUNT_BIT_WIDTH)
    port map(
        clk => clk, 
        reset => reset, 
        suspend => suspend,
        end_of_cycle => end_of_cycle_signal,
        output_count => output_count
    );

    jumpconsider_module_0 : jumpconsider_module
    generic map(OPCODE_WIDTH => OPCODE_WIDTH,
            UPPER_BOUND => 7,
            LOWER_BOUND => 0
    )
    port map(
        opcode => opcode,
        is_jump => is_jump
    );

    flagjump_module_0 : flagjump_module
    generic map(JUMPTYPES_WIDTH => JUMPTYPES_WIDTH)
    -- first 3 bits of opcode indicate the type of the jump
    port map(jump_type_bits => opcode(JUMPTYPES_WIDTH - 1 downto 0),
        -- flags
        sign_f => sign_f, 
        overflow_f => overflow_f, 
        zero_f => zero_f,
        output_jump => jump_type_result
    );

    rom : FSM_ROM
    generic map(
        DATA_WIDTH => DATA_WIDTH,
        ADDRESS_SIZE => ADDRESS_SIZE
    )
    port map(address => ROM_address,
        data_output => ROM_data
    );



    jump_result_multiplexer : multiplexer
    generic map(
        SEL_NUMBER => 1,
        BIT_WIDTH => 2
    )
    port map(
        sel => jump_type_result_vector,
        input => "1110",
        output => jump_address_select
    );

    jump_type_result_vector <= (0 => jump_type_result);


    jump_consider_multiplexer : multiplexer
    generic map(
        SEL_NUMBER => 1,
        BIT_WIDTH => 2
    )
    port map(
        sel => consider_jump_vector,
        input => jump_consider_mux_input_concatenated,
        output => pcsel
    );

    -- ROM_data(DATA_WIDTH - 9); same as irwe
    consider_jump <= is_jump and not(ROM_data(DATA_WIDTH - 9));
    consider_jump_vector <= (0 => consider_jump);
    jump_consider_mux_input_concatenated <= jump_address_select & ROM_data(DATA_WIDTH - 26 downto DATA_WIDTH - 27);

    end_of_cycle_signal  <= ROM_data(DATA_WIDTH - 1); --ireset
    pcwe    <= ROM_data(DATA_WIDTH - 2);
    adrsel  <= ROM_data(DATA_WIDTH - 3 downto DATA_WIDTH - 4);
    segsel  <= ROM_data(DATA_WIDTH - 5);
    bssel   <= ROM_data(DATA_WIDTH - 6);
    arwe    <= ROM_data(DATA_WIDTH - 7);
    ramw    <= ROM_data(DATA_WIDTH - 8);
    irwe    <= ROM_data(DATA_WIDTH - 9);
    drwe    <= ROM_data(DATA_WIDTH - 10);
    memssel <= ROM_data(DATA_WIDTH - 11 downto DATA_WIDTH - 12);
    rwsel   <= ROM_data(DATA_WIDTH - 13 downto DATA_WIDTH - 14);
    rwe     <= ROM_data(DATA_WIDTH - 15);
    xywe    <= ROM_data(DATA_WIDTH - 16);
    xsel    <= ROM_data(DATA_WIDTH - 17 downto DATA_WIDTH - 18);
    ysel    <= ROM_data(DATA_WIDTH - 19 downto DATA_WIDTH - 20);
    alum    <= ROM_data(DATA_WIDTH - 21 downto DATA_WIDTH - 24);
    aluwe   <= ROM_data(DATA_WIDTH - 25);
    
    cswe    <= ROM_data(DATA_WIDTH - 28);
    dswe    <= ROM_data(DATA_WIDTH - 29);
    dsel    <= ROM_data(DATA_WIDTH - 30);


    ROM_address <= opcode & output_count;

end Structural;
