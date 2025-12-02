library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity main is
    port(clk, reset : in std_logic);
end main;

architecture Behavioral of main is

    signal opcode : std_logic_vector(5 downto 0);

    -- ROM address and content (address has 8 bits here)
    signal romaddr : std_logic_vector(7 downto 0);
    signal romcont : std_logic_vector(32 downto 0);

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
    signal pcsel_mux_input_concatenated : std_logic_vector(63 downto 0);

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
    signal ramadr : std_logic_vector(31 downto 0);

    -- Regholder
    signal holder_x : std_logic_vector(15 downto 0);
    signal holder_y : std_logic_vector(15 downto 0);

    -- Memsel multiplexer
    signal memsel_mux_input_concatenated : std_logic_vector(63 downto 0);
    signal memsel_out : std_logic_vector(15 downto 0);

    -- Register-write multiplexer
    signal write_mux_input_concatenated : std_logic_vector(63 downto 0);
    signal write_mux_out : std_logic_vector(15 downto 0);

    
begin

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
    segment_selector_mux : entity work.multiplexer
    generic map(
        SEL_NUMBER => 1,
        BIT_WIDTH => 2
    )
     port map(
        sel => seg_sel_vec,
        input => cs_ds_concat,
        output => seg_mux
    );

    cs_ds_concat <= cs_out & ds_out;
    seg_sel_vec <= (others => segsel);

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

    -- Address selector multiplexer
    adr_sel_mux: entity work.multiplexer
     generic map(
        SEL_NUMBER => 2,
        BIT_WIDTH => 16
    )
     port map(
        sel => adrsel,
        input => adr_mux_input_concatenated,
        output => adr_mux
    );

    adr_mux_input_concatenated <= "0000000000000000" & xy_yout & ar_out & pc_out;

    -- Memory addres junction
    mem_addr <= seg_mux & adr_mux;

    -- FSM
    FSM_inst: entity work.FSM
     generic map(
        OPCODE_WIDTH => 6,
        COUNT_BIT_WIDTH => 3,
        JUMPTYPES_WIDTH => 3,
        DATA_WIDTH => 30,
        ADDRESS_SIZE => 9
    )
     port map(
        opcode => opcode,
        clk => clk,
        reset => reset,
        sign_f => sign_f,
        overflow_f => overflow_f,
        zero_f => zero_f,
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
        dsel => dsel
    );


    -- Data register
    data_reg: entity work.custom_register
     generic map(
        BIT_WIDTH => 32
    )
     port map(
        input => ram_mux_out,
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
    pcsel_mux: entity work.multiplexer
     generic map(
        SEL_NUMBER => 2,
        BIT_WIDTH => 16
    )
    port map(
        sel => pcsel,
        input => pcsel_mux_input_concatenated,
        output => pcsel_in
    );
    pcsel_mux_input_concatenated <= ar_out & pc_out & alureg_low & alu_out_low;

    -- Instruction register
    instr_reg: entity work.custom_register
     generic map(
        BIT_WIDTH => 32
    )
     port map(
        input => ram_mux_out,
        write_enable => irwe,
        clk => clk,
        reset => reset,
        output => ir_out
    );

    opcode <= ir_out(31 downto 26);
    radrx <= ir_out(25 downto 21);
    radry <= ir_out(20 downto 16);
    radrdest <= ir_out(15 downto 11);

    --Destionation multiplexer
    destination_mux: entity work.multiplexer
    generic map(
        SEL_NUMBER => 1,
        BIT_WIDTH => 5
    )
    port map(
        sel => dsel,
        input => dest_mux_input_concatenated,
        output => dest
    );

    dest_mux_input_concatenated <= radrdest & radrx;

    -- ALU
    ALU_inst: entity work.ALU
     generic map(
        BIT_WIDTH_IN => 16
    )
     port map(
        clk => clk,
        reset => reset,
        alu_mode => alu_mode,
        A => x_alu_a,
        B => y_alu_b,
        Y => alu_out,
        carry_f => carry_f,
        sign_f => sign_f,
        zero_f => zero_f,
        overflow_f => overflow_f,
        ALU_standby => alusby
    );

    -- X multiplexer
    x_mux: entity work.multiplexer
     generic map(
        SEL_NUMBER => 2,
        BIT_WIDTH => 16
    )
     port map(
        sel => xsel,
        input => x_mux_input_concatenated,
        output => x_alu_a
    );

    x_mux_input_concatenated <= "0000000000000000" & "0000000000000000" & pc_out & xy_xout;

    -- Y multiplexer
    y_mux: entity work.multiplexer
     generic map(
        SEL_NUMBER => 2,
        BIT_WIDTH => 16
    )
     port map(
        sel => ysel,
        input => y_mux_input_concatenated,
        output => y_alu_b
    );
    
    y_mux_input_concatenated <= "0000000000000000" & "0000000000000001" & "0000000000000000" & xy_yout;


    -- B select multiplexer
    bs_mux: entity work.multiplexer
     generic map(
        SEL_NUMBER => 1,
        BIT_WIDTH => 16
    )
     port map(
        sel => bssel,
        input => bs_mux_input_concatenated,
        output => bsmux
    );

    bs_mux_input_concatenated <= dr_low_high & alureg_low(7 downto 0) & alureg_low;

    ramadr <= dr_high & bsmux;


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
    memsel_mux: entity work.multiplexer
     generic map(
        SEL_NUMBER => 2,
        BIT_WIDTH => 16
    )
     port map(
        sel => memssel,
        input => memsel_mux_input_concatenated,
        output => memsel_out
    );
    memsel_mux_input_concatenated <= "000000000000" & ses_out & seu_out & dr_low;

    -- Register-write multiplexer
    regw_mux: entity work.multiplexer
     generic map(
        SEL_NUMBER => 2,
        BIT_WIDTH => 16
    )
     port map(
        sel => rwsel,
        input => write_mux_input_concatenated,
        output => write_mux_out
    );
    write_mux_input_concatenated <= ar_in &  alureg_high & alureg_low & memsel_out;

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
        output_y => holder_y
    );

    -- ROM
    
    

end Behavioral;
