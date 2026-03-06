library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


-- Project: Custom 16-bit RISC Processor
-- Author: Péter Gál
-- Description: Features 6-bit Opcode, MMIO, and Segmented Memory, Interrupt timer
-- Target: Xilinx Artix-7 (Basys 3 / Nexys A7)




entity main is
    port(clk_extrn, reset : in std_logic;
        -- SSD outputs
        an : out std_logic_vector(3 downto 0);
        seg : out std_logic_vector(6 downto 0);
        --out1 : out std_logic_vector(15 downto 0);
        --out0 : out std_logic_vector(15 downto 0);
        JB : inout std_logic_vector(7 downto 0);
        --in0 : in std_logic_vector(15 downto 0);
        --in1 : in std_logic_vector(15 downto 0)
        interrupt : in std_logic;
        --dht_pin : inout std_logic;
        --dht_start_signal : in std_logic;
        miso : in std_logic;
        mosi, sck : out std_logic;
        cs_vector : out std_logic_vector(4 downto 0)
        );
end main;

architecture Behavioral of main is
    signal clk_out : std_logic;
    signal out1 : std_logic_vector(15 downto 0);
    signal in0 : std_logic_vector(15 downto 0);

    signal in1 : std_logic_vector(15 downto 0);

    -- Internal clock
    signal clk : std_logic;

    signal reg_0_internal : std_logic_vector(15 downto 0);

    signal opcode : std_logic_vector(5 downto 0);

    -- ROM address and content (address has 8 bits here)
    signal romcont : std_logic_vector(31 downto 0);

    signal iretsel : std_logic := '0';
    signal pciwe   : std_logic := '0';
    signal pcwe    : std_logic := '0';
    signal adrsel  : std_logic_vector(1 downto 0) := "00";
    signal segsel  : std_logic := '0';
    signal bssel   : std_logic := '0';
    signal arwe    : std_logic := '0';
    signal ramw    : std_logic := '0';
    signal irwe    : std_logic := '0';
    signal drwe    : std_logic := '0';
    signal memssel : std_logic_vector(1 downto 0) := "00";
    signal rwsel   : std_logic_vector(1 downto 0) := "00";
    signal rwe     : std_logic := '0';
    signal xywe    : std_logic := '0';
    signal xsel    : std_logic_vector(1 downto 0) := "00";
    signal ysel    : std_logic_vector(1 downto 0) := "00";
    signal alum    : std_logic_vector(3 downto 0) := "0000";
    signal aluwe   : std_logic := '0';
    signal pcsel   : std_logic_vector(1 downto 0) := "00";
    signal cswe    : std_logic := '0';
    signal dswe    : std_logic := '0';
    signal dsel    : std_logic := '0';

    signal sign_f : std_logic;
    signal carry_f : std_logic;
    signal overflow_f : std_logic;
    signal zero_f : std_logic;

    -- Dsel and bsel vector
    signal bssel_vector : std_logic_vector(0 downto 0);

    signal dsel_vector : std_logic_vector(0 downto 0);

    -- Segment signals
    signal segment_in : std_logic_vector(1 downto 0);

    signal cs_out : std_logic_vector(1 downto 0);
    signal ds_out : std_logic_vector(1 downto 0);

    -- Segment MUX helpers
    signal cs_ds_concat : std_logic_vector(3 downto 0);
    signal seg_sel_vec : std_logic_vector(0 downto 0);

    signal seg_mux : std_logic_vector(1 downto 0);


    -- Program counter signals
    signal pcsel_in :  std_logic_vector(15 downto 0);
    signal pc_out :  std_logic_vector(15 downto 0);

    -- RAM address selector MUX signal
    signal adr_mux :  std_logic_vector(15 downto 0);
    signal adr_mux_input_concatenated : std_logic_vector(63 downto 0);

    -- Memory addres junction signal
    signal mem_addr  :  std_logic_vector(17 downto 0);


    -- Data register signals
    signal ram_mux_out : std_logic_vector(31 downto 0);

    signal dr_out :  std_logic_vector(31 downto 0);

    signal dr_low :  std_logic_vector(15 downto 0);
    signal dr_high :  std_logic_vector(15 downto 0);

    signal dr_low_low : std_logic_vector(7 downto 0);
    signal dr_low_high : std_logic_vector(7 downto 0);


    -- Sign extension signals
    signal seu_out : std_logic_vector(15 downto 0);
    signal ses_out : std_logic_vector(15 downto 0);

    -- ALU helpers

    signal alureg_low : std_logic_vector(15 downto 0);
    signal alureg_high : std_logic_vector(15 downto 0);
    signal alureg_out : std_logic_vector(31 downto 0);
    signal alu_out : std_logic_vector(31 downto 0);
    signal alu_out_low : std_logic_vector(15 downto 0);

    -- Address register signals
    signal ar_in : std_logic_vector(15 downto 0);
    signal ar_out : std_logic_vector(15 downto 0);


    -- PCSEL multiplexer helper
    signal pcsel_mux_sel_concetaned : std_logic_vector(2 downto 0); -- combining pcsel and iretsel
    signal pcsel_mux_input_concatenated : std_logic_vector(127 downto 0);

    -- Instruction register
    signal ir_out : std_logic_vector(31 downto 0);

    signal radrx : std_logic_vector(4 downto 0);
    signal radry : std_logic_vector(4 downto 0);
    signal radrdest : std_logic_vector(4 downto 0);

    signal dest : std_logic_vector(4 downto 0);

    -- Destination mux helper
    signal dest_mux_input_concatenated : std_logic_vector(9 downto 0);

    -- ALU
    signal x_alu_a : std_logic_vector(15 downto 0);
    signal y_alu_b : std_logic_vector(15 downto 0);
    signal alusby : std_logic;

    -- Pre ALU MUX helpers
    signal x_mux_input_concatenated : std_logic_vector(63 downto 0);
    signal y_mux_input_concatenated : std_logic_vector(63 downto 0);


    -- XY reg
    signal xy_xout : std_logic_vector(15 downto 0);
    signal xy_yout : std_logic_vector(15 downto 0);
    signal xy_out : std_logic_vector(31 downto 0);
    signal xy_in : std_logic_vector(31 downto 0);

    -- B select multiplexer
    signal bsmux : std_logic_vector(15 downto 0);
    signal bs_mux_input_concatenated : std_logic_vector(31 downto 0);

    -- RAM
    signal ramwe : std_logic;
    signal ram_data : std_logic_vector(31 downto 0);
    signal ramw_neg : std_logic;
    signal ram_out : std_logic_vector(31 downto 0);

    -- Regholder
    signal holder_x : std_logic_vector(15 downto 0);
    signal holder_y : std_logic_vector(15 downto 0);

    -- Memsel multiplexer
    signal memsel_mux_input_concatenated : std_logic_vector(63 downto 0);
    signal memsel_out : std_logic_vector(15 downto 0);

    -- Register-write multiplexer
    signal write_mux_input_concatenated : std_logic_vector(63 downto 0);
    signal write_mux_out : std_logic_vector(15 downto 0);


    -- Memory RAM/ROM IR multiplexer
    signal memory_ir_mux_input_concatenated : std_logic_vector(63 downto 0);
    signal memory_ir_mux_sel : std_logic_vector(0 downto 0);

    -- Peripheral output dmux outputs held in a single vector
    signal out_peri_dmux_out_vector : std_logic_vector(31 downto 0);
    signal mmap_consider_vector : std_logic_vector(0 downto 0);
    signal mmap_sel : std_logic_vector(4 downto 0);
    signal mmap_consider : std_logic;

    -- From input peripheral multiplexer helpers
    signal from_input_peripheral_mux_input_concatenated : std_logic_vector(63 downto 0);
    signal input_peripheral_mux_ir : std_logic_vector(31 downto 0);

    -- To output peripheral demultiplexer helpers
    signal bsel_mux_out_to_output_peripheral_in : std_logic_vector(31 downto 0);
    signal to_output_dmux_output_concatenated : std_logic_vector(63 downto 0);

    -- Peripheral register holder
    signal pr_datain : std_logic_vector(15 downto 0);
    signal pr_dataout : std_logic_vector(15 downto 0);


    -- Interrupt buffer
    signal interrupt_buffer_out : std_logic;

    -- Interrupt store PCI
    signal pciout : std_logic_vector(15 downto 0);
    signal interrupt_address : std_logic_vector(15 downto 0) := "0000000011000000";
    signal nullbuf : std_logic_vector(15 downto 0);


    -- GPIO signals
    signal gpio_driver_signal : std_logic_vector(15 downto 0);
    signal gpio_driver_signal_mode : std_logic_vector(7 downto 0);
    signal gpio_driver_signal_data : std_logic_vector(7 downto 0);

    signal gpio_driver_signal_read_data_1 : std_logic_vector(7 downto 0);
    signal gpio_driver_signal_read_data_2 : std_logic_vector(7 downto 0);
    signal gpio_driver_signal_read_data_aggregated : std_logic_vector(15 downto 0);

    -- SPI driver signals
    signal start_transfer : std_logic := '0';
    signal register_address : std_logic := '0';
    signal spi_address : std_logic_vector(2 downto 0) := "000";
    signal spi_data : std_logic_vector(7 downto 0) := "00000000";

    signal out0 : std_logic_vector(15 downto 0) := "0000000000000000";

begin

    -- Timer
    timer_instance: entity work.clockdivider
     port map(
        clk_in => clk,
        reset => reset,
        clk_out => clk_out
    );

    -- SSD module
    ssd_driver: entity work.Switchtossd
     port map(
        inputvec => reg_0_internal,
        clk => clk_extrn, -- This does not need clock divider
        reset => reset,
        an => an,
        seg => seg
    );

    clk <= clk_extrn;

    segment_in <= alureg_low(1 downto 0);

    -- Data segment register
    ds_reg: entity work.custom_register
    generic map(
        BIT_WIDTH => 2
    )
    port map(
        input => segment_in,
        write_enable => dswe,
        clk => clk,
        reset => reset,
        output => ds_out
    );

    -- Code segment register
    cs_reg : entity work.custom_register
     generic map(
        BIT_WIDTH => 2
    )
    port map(
        input => segment_in,
        write_enable => cswe,
        clk => clk,
        reset => reset,
        output => cs_out
    );

    -- Segment selector multiplexer
    segment_selector_generic_mux : entity work.generic_mux
    port map(
        mux_sel => std_logic_vector'(0 => segsel),
        mux_input => (
            1 => cs_out,
            0 => ds_out
        ),
        mux_output => seg_mux -- routes the segment bits to the RAM address
    );


    -- Program counter register
    pc_reg : entity work.custom_register
     generic map(
        BIT_WIDTH => 16
    )
     port map(
        input => pcsel_in,
        write_enable => pcwe,
        clk => clk,
        reset => reset,
        output => pc_out
    );

    -- Memory address selec tor multiplexer
    adr_sel_generic_mux : entity work.generic_mux
    port map(
        mux_sel => adrsel,
        mux_input => (
            3 => x"0000",
            2 => xy_yout, -- Data fetch based on general register value
            1 => ar_out, -- Data fetch based on address register
            0 => pc_out -- For fetching next op based on pc
        ),
        mux_output => adr_mux
    );

    -- Memory addres junction
    mem_addr <= seg_mux & adr_mux;

    -- FSM
    FSM_inst: entity work.FSM
     generic map(
        OPCODE_WIDTH => 6,
        COUNT_BIT_WIDTH => 3,
        JUMPTYPES_WIDTH => 3,
        DATA_WIDTH => 33,
        ADDRESS_SIZE => 9
    )
     port map(
        interrupt => interrupt_buffer_out,
        opcode => opcode,
        clk => clk,
        reset => reset,
        sign_f => sign_f,
        overflow_f => overflow_f,
        zero_f => zero_f,
        iretsel => iretsel,
        pciwe => pciwe,
        pcwe => pcwe,
        adrsel => adrsel,
        segsel => segsel,
        bssel => bssel,
        arwe => arwe,
        ramw => ramw,
        irwe => irwe,
        drwe => drwe,
        memssel => memssel,
        rwsel => rwsel,
        rwe => rwe,
        xywe => xywe,
        xsel => xsel,
        ysel => ysel,
        alum => alum,
        aluwe => aluwe,
        pcsel => pcsel,
        cswe => cswe,
        dswe => dswe,
        dsel => dsel,
        suspend => alusby
    );


    -- Data register
    data_reg: entity work.custom_register
     generic map(
        BIT_WIDTH => 32
    )
     port map(
        input => input_peripheral_mux_ir,
        write_enable => drwe,
        clk => clk,
        reset => reset,
        output => dr_out
    );

    dr_low <= dr_out(15 downto 0);
    dr_high <= dr_out(31 downto 16);
    dr_low_low <= dr_low(7 downto 0);
    dr_low_high <= dr_low(15 downto 8);

    -- Signed extend
    signextend_signed: entity work.signextend
     generic map(
        BIT_WIDTH_IN => 8,
        BIT_WIDTH_OUT => 16
    )
     port map(
        inputs => dr_low_low,
        outputs => ses_out
    );

    -- Unsigned (zero) extend
    signextend_unsigned: entity work.zeroextend
     generic map(
        BIT_WIDTH_IN => 8,
        BIT_WIDTH_OUT => 16
    )
     port map(
        inputs => dr_low_low,
        outputs => seu_out
    );


    -- ALU reg
    alu_reg: entity work.custom_register
     generic map(
        BIT_WIDTH => 32
    )
     port map(
        input => alu_out,
        write_enable => aluwe,
        clk => clk,
        reset => reset,
        output => alureg_out
    );

    alureg_low <= alureg_out(15 downto 0);
    alureg_high <= alureg_out(31 downto 16);
    alu_out_low <= alu_out(15 downto 0);

    -- Address register
    address_reg: entity work.custom_register
     generic map(
        BIT_WIDTH => 16
    )
     port map(
        input => ar_in,
        write_enable => arwe,
        clk => clk,
        reset => reset,
        output => ar_out
    );


    -- Program counter multiplexer
    pc_sel_generic_mux : entity work.generic_mux
    port map(
        mux_sel => iretsel & pcsel,
        mux_input => (
            7 => x"0000",
            6 => INTERRUPT_JUMP_ADDR,
            5 => pciout,
            4 => INTERRUPT_JUMP_ADDR,
            3 => ar_out,
            2 => pc_out,
            1 => alureg_low,
            0 => alu_out_low
        ),
        mux_output => pcsel_in
    );

    -- Instruction register
    instr_reg: entity work.custom_register
     generic map(
        BIT_WIDTH => 32
    )
     port map(
        input => input_peripheral_mux_ir,
        write_enable => irwe,
        clk => clk,
        reset => reset,
        output => ir_out
    );

    opcode <= ir_out(31 downto 26);
    radrx <= ir_out(25 downto 21);
    radry <= ir_out(20 downto 16);
    radrdest <= ir_out(15 downto 11);
    ar_in <= ir_out(15 downto 0);

    -- Destination generic multiplexer
    -- Handles multiregister results, selects the address of destination register
    -- Example used for DIV to store Remainder and Quotent in two distinct registers
    destination_generic_mux: entity work.generic_mux
    port map(
        mux_sel => (0 => dsel),
        mux_input => (
            1 => radrdest,
            0 => radrx
        ),
        mux_output => dest
    );


    -- ALU
    ALU_inst: entity work.ALU
     generic map(
        BIT_WIDTH_IN => 16
    )
     port map(
        clk => clk,
        reset => reset,
        alu_mode => alum,
        A => x_alu_a,
        B => y_alu_b,
        Y => alu_out,
        carry_f => carry_f,
        sign_f => sign_f,
        zero_f => zero_f,
        overflow_f => overflow_f,
        ALU_standby => alusby
    );


    -- X generic multiplexer multiplexer - Selection of operand #1 for ALU
    x_generic_mux: entity work.generic_mux
    port map(
        mux_sel => xsel,
        mux_input => (
            3 => x"0000",
            2 => x"0000",
            1 => pc_out,
            0 => xy_xout -- decoded register values
        ),
        mux_output => x_alu_a
    );

    -- Y generic multiplexer multiplexer - Selection of operand #2 for ALU
    y_generic_mux: entity work.generic_mux
    port map(
        mux_sel => ysel,
        mux_input => (
            3 => x"0000",
            2 => x"0001",
            1 => x"0000",
            0 => xy_yout -- decoded register values
        ),
        mux_output => y_alu_b
    );




    -- B select generic multiplexer
    -- Selects the data to be written to memory
    bs_generic_mux: entity work.generic_mux
    port map(
        mux_sel => (0 => bssel),
        mux_input => (
            1 => dr_low_high & alureg_low(7 downto 0), -- writing a byte and keeping the high part
            0 => alureg_low -- writing a 16 bit word
        ),
        mux_output => bsmux
    );

    bsel_mux_out_to_output_peripheral_in <= dr_high & bsmux;

    -- XY register
    xy_reg: entity work.custom_register
     generic map(
        BIT_WIDTH => 32
    )
     port map(
        input => xy_in,
        write_enable => xywe,
        clk => clk,
        reset => reset,
        output => xy_out
    );
    xy_xout <= xy_out(15 downto 0);
    xy_yout <= xy_out(31 downto 16);
    xy_in <= holder_y & holder_x;





    -- Memory read multiplexer
    -- Handles the different modes of memory reading:
    memsel_generic_mux: entity work.generic_mux
    port map(
        mux_sel => memssel,
        mux_input => (
            3 => x"0000",
            2 => ses_out, -- Reading 8 bit word + 8 bit signed extend
            1 => seu_out, -- Reading 8 bit word + 8 bit unsigned (zero) extend
            0 => dr_low -- Reading 16 bit word
        ),
        mux_output => memsel_out
    );

    -- Register-write multiplexer
    -- Controls from which source the new content of the destination register is read from
    regw_generic_mux: entity work.generic_mux
    port map(
        mux_sel => rwsel,
        mux_input => (
            3 => ar_in, -- Address from instruction coming from low bytes of Instr Reg
            2 => alureg_high, -- high byte of ALU result
            1 => alureg_low, -- low byte of ALU result
            0 => memsel_out -- from memory
        ),
        mux_output => write_mux_out
    );







    -- Register holder
    register_holder_inst: entity work.register_holder
     generic map(
        BIT_WIDTH => 16,
        ADDRESS_SIZE => 5
    )
     port map(
        adress_x => radrx,
        address_y => radry,
        dest_address => dest,
        write_enable => rwe,
        clk => clk,
        reset => reset,
        input_w => write_mux_out,
        output_x => holder_x,
        output_y => holder_y,
        reg_0_out => reg_0_internal
    );


    -- Deciding between RAM and ROM reading
    process(segsel, cs_out)
    begin
        if cs_out = "00" then
            memory_ir_mux_sel <= (0 => not segsel);
        else
            memory_ir_mux_sel <= (0 => '0');
        end if;
    end process;


    -- Memory RAM/ROM IR multiplexer
    mem_ir_generic_mux: entity work.generic_mux
    port map(
        mux_sel => memory_ir_mux_sel,
        mux_input => (
            1 => romcont,
            0 => ram_out
        ),
        mux_output => ram_mux_out
    );


    -- ROM
    ROM_inst: entity work.ROM
     generic map(
        DATA_WIDTH => 32
    )
     port map(
        address => mem_addr,
        output => romcont
    );

    -- RAM
    RAM_inst: entity work.RAM
     generic map(
        DATA_WIDTH => 32
    )
     port map(
        address => mem_addr,
        clk => clk,
        write_enable => ramwe,
        output_enable => ramw_neg,
        data_input => ram_data,
        data_output => ram_out
    );
    -- Only write if not currently performin memory mapping
    ramwe <= (not mmap_consider) and ramw;
    ramw_neg <= not ramw;

    -- Memory mapping module
    MMAP_inst: entity work.MMAP
     generic map(
        BIT_WIDTH => 16,
        OPCODE_WIDTH => 6,
        ADDRESS_SIZE => 5,
        START_ADDRESS => 255
    )
     port map(
        mem_addr => mem_addr,
        opcode => opcode,
        irwe => irwe,
        sel_consider => mmap_consider,
        sel_out => mmap_sel
    );

    mmap_consider_vector <= (0 => mmap_consider);


    from_input_peripheral_generic_mux: entity work.generic_mux
    port map(
        mux_sel => mmap_consider_vector,
        mux_input => (
            1 => x"0000" & pr_dataout,   -- peripherals sned 16 bit words but RAM needs 32
            0 => ram_mux_out
        ),
        mux_output => input_peripheral_mux_ir
    );


    to_output_demultiplexer: entity work.demultiplexer
     generic map(
        SEL_NUMBER => 1,
        BIT_WIDTH => 32
    )
     port map(
        sel => mmap_consider_vector,
        input => bsel_mux_out_to_output_peripheral_in,
        output => to_output_dmux_output_concatenated
    );

    -- Only the low 16 bit word is needed
    pr_datain <= to_output_dmux_output_concatenated(47 downto 32);
    ram_data <= to_output_dmux_output_concatenated(31 downto 0);


    peripherals_regs_inst: entity work.peripherals_regs
     generic map(
        BIT_WIDTH => 16,
        ADDRESS_SIZE => 5
    )
     port map(
        clk => clk,
        reset => reset,
        ramwe => ramw,
        mmap_consider => mmap_consider,
        out0 => out0,
        out1 => gpio_driver_signal,
        pdatout => pr_dataout,
        in0 => in0,
        in1 => in1,
        pdatin => pr_datain,
        mmap_sel => mmap_sel
    );



    interrupt_controller_inst : entity work.interrupt_controller
    port map(
        reset => reset,
        clk => clk,
        pciwe => pciwe, -- This signal indicates that the current top priority interrupt has been processed by the CPU
        timer_int => '0',
        peripheral_int => '0',
        interrupt_address => interrupt_address,
        control_unit_any_interrupt_signal => interrupt_buffer_out
    );



    interrupt_program_counter_store: entity work.custom_register
     generic map(
        BIT_WIDTH => 16
    )
     port map(
        input => pc_out,
        write_enable => pciwe,
        clk => clk,
        reset => reset,
        output => pciout
    );


    -- GPIO
    gpio_driver_signal_mode <= gpio_driver_signal(15 downto 8);
    gpio_driver_signal_data <= gpio_driver_signal(7 downto 0);


    --gpio_driver_signal_read_data_2 <= ((others => '1') ); -- temporary could be used for a second gpio set
    gpio_driver_signal_read_data_aggregated <= gpio_driver_signal_read_data_2 & gpio_driver_signal_read_data_1;

    in1 <= gpio_driver_signal_read_data_aggregated;

    gpio_driver_inst: entity work.gpio_driver
     generic map(
        PORTS => 8
    )
     port map(
        clk => clk,
        reset => reset,
        gpio_ports => JB,
        gpio_output_mode => gpio_driver_signal_mode,
        gpio_write_data => gpio_driver_signal_data,
        gpio_read_data => gpio_driver_signal_read_data_1
    );


    register_address <= out0(12);
    start_transfer <= out0(11);
    spi_address <= out0(10 downto 8);
    spi_data <= out0(7 downto 0);

    spidriver_inst: entity work.spidriver
     generic map(
        CLK_IDLE => '0'
    )
     port map(
        clk => clk,
        reset => reset,
        start_transfer => start_transfer,
        register_address => register_address,
        data_in => spi_data,
        data_out => gpio_driver_signal_read_data_2,
        miso => miso,
        mosi => mosi,
        sck => sck,
        cs_vector => cs_vector,
        addr => spi_address
    );

end Behavioral;
