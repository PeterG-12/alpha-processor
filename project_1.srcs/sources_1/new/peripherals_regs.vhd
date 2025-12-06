library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity peripherals_regs is
    generic(BIT_WIDTH : integer;
            ADDRESS_SIZE : integer);
    port(clk, reset, ramwe, mmap_consider : in std_logic;
        out0, out1, pdatout : out std_logic_vector(BIT_WIDTH - 1 downto 0);
        in0, in1, pdatin : in std_logic_vector(BIT_WIDTH - 1 downto 0);
        mmap_sel : in std_logic_vector(ADDRESS_SIZE - 1 downto 0)
        );
end peripherals_regs;

architecture Behavioral of peripherals_regs is

    signal perout_we : std_logic_vector(0 downto 0);
    signal pin_register_inputs_concatenated : std_logic_vector((2**ADDRESS_SIZE * BIT_WIDTH) - 1 downto 0);
    signal pin_register_outputs_concatenated : std_logic_vector((2**ADDRESS_SIZE * BIT_WIDTH) - 1 downto 0);
    signal pout_register_inputs_concatenated : std_logic_vector((2**ADDRESS_SIZE * BIT_WIDTH) - 1 downto 0);
    signal pout_register_outputs_concatenated : std_logic_vector((2**ADDRESS_SIZE * BIT_WIDTH) - 1 downto 0);
    signal pout_register_write_enable_concatenated : std_logic_vector((2**ADDRESS_SIZE) - 1 downto 0);


begin
    perout_we(0) <= mmap_consider and ramwe;


    pin_mux: entity work.multiplexer
    generic map(
        SEL_NUMBER => ADDRESS_SIZE,
        BIT_WIDTH => BIT_WIDTH
    )
     port map(
        sel => mmap_sel,
        input => pin_register_outputs_concatenated,
        output => pdatout
    );

    pin_register_inputs_concatenated(2 * BIT_WIDTH - 1 downto 0) <= in1 & in0;
    pin_register_inputs_concatenated((2**ADDRESS_SIZE * BIT_WIDTH) - 1 downto 2 * BIT_WIDTH) <= (others => '0');

    peri_in_registers : for i in 0 to 2**ADDRESS_SIZE - 1 generate
        peri_in_register_i : entity work.custom_register
        generic map(
            BIT_WIDTH=>BIT_WIDTH
        )
        port map(
            clk => clk,
            reset => reset,
            write_enable => '1',
            input => pin_register_inputs_concatenated((i + 1) * BIT_WIDTH - 1 downto i * BIT_WIDTH),
            output => pin_register_outputs_concatenated((i + 1) * BIT_WIDTH - 1 downto i * BIT_WIDTH)
        );
            
    end generate peri_in_registers;

    we_dmux: entity work.demultiplexer
    generic map(
        SEL_NUMBER => ADDRESS_SIZE,
        BIT_WIDTH => 1
    )
     port map(
        sel => mmap_sel,
        input => perout_we,
        output => pout_register_write_enable_concatenated
    );

    peri_out_registers : for i in 0 to 2**ADDRESS_SIZE - 1 generate
        peri_in_register_i : entity work.custom_register
        generic map(
            BIT_WIDTH=>BIT_WIDTH
        )
        port map(
            clk => clk,
            reset => reset,
            write_enable => pout_register_write_enable_concatenated(i),
            input => pdatin,
            output => pout_register_outputs_concatenated((i + 1) * BIT_WIDTH - 1 downto i * BIT_WIDTH)
        );
            
    end generate peri_out_registers;

    out0 <= pout_register_outputs_concatenated(BIT_WIDTH - 1 downto 0);
    out1 <= pout_register_outputs_concatenated(2 * BIT_WIDTH - 1 downto BIT_WIDTH);



end Behavioral;
