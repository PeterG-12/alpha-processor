library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity to_simulate_main is
    port(
        clk_extrn, reset : in std_logic;
        -- Real I/O
        an : out std_logic_vector(3 downto 0);
        seg : out std_logic_vector(6 downto 0);
        out0 : out std_logic_vector(15 downto 0);
        out1 : out std_logic_vector(15 downto 0);
        in0 : in std_logic_vector(15 downto 0);
        in1 : in std_logic_vector(15 downto 0);
        interrupt : in std_logic;

        -- =========================================================================
        -- DEBUG PORTS (Exposing Internal State)
        -- =========================================================================
        dbg_reg_0_out                   : out std_logic_vector(15 downto 0);
        dbg_opcode                      : out std_logic_vector(5 downto 0);
        dbg_romcont                     : out std_logic_vector(31 downto 0);
        dbg_pcwe                        : out std_logic;
        dbg_adrsel                      : out std_logic_vector(1 downto 0);
        dbg_segsel                      : out std_logic;
        dbg_bssel                       : out std_logic;
        dbg_arwe                        : out std_logic;
        dbg_ramw                        : out std_logic;
        dbg_irwe                        : out std_logic;
        dbg_drwe                        : out std_logic;
        dbg_memssel                     : out std_logic_vector(1 downto 0);
        dbg_rwsel                       : out std_logic_vector(1 downto 0);
        dbg_rwe                         : out std_logic;
        dbg_xywe                        : out std_logic;
        dbg_xsel                        : out std_logic_vector(1 downto 0);
        dbg_ysel                        : out std_logic_vector(1 downto 0);
        dbg_alum                        : out std_logic_vector(3 downto 0);
        dbg_aluwe                       : out std_logic;
        dbg_pcsel                       : out std_logic_vector(1 downto 0);
        dbg_cswe                        : out std_logic;
        dbg_dswe                        : out std_logic;
        dbg_dsel                        : out std_logic;
        dbg_sign_f                      : out std_logic;
        dbg_carry_f                     : out std_logic;
        dbg_overflow_f                  : out std_logic;
        dbg_zero_f                      : out std_logic;
        dbg_bssel_vector                : out std_logic_vector(0 downto 0);
        dbg_dsel_vector                 : out std_logic_vector(0 downto 0);
        dbg_segment_in                  : out std_logic_vector(1 downto 0);
        dbg_cs_out                      : out std_logic_vector(1 downto 0);
        dbg_ds_out                      : out std_logic_vector(1 downto 0);
        dbg_cs_ds_concat                : out std_logic_vector(3 downto 0);
        dbg_seg_sel_vec                 : out std_logic_vector(0 downto 0);
        dbg_seg_mux                     : out std_logic_vector(1 downto 0);
        dbg_pcsel_in                    : out std_logic_vector(15 downto 0);
        dbg_pc_out                      : out std_logic_vector(15 downto 0);
        dbg_adr_mux                     : out std_logic_vector(15 downto 0);
        dbg_mem_addr                    : out std_logic_vector(17 downto 0);
        dbg_ram_mux_out                 : out std_logic_vector(31 downto 0);
        dbg_dr_out                      : out std_logic_vector(31 downto 0);
        dbg_dr_low                      : out std_logic_vector(15 downto 0);
        dbg_dr_high                     : out std_logic_vector(15 downto 0);
        dbg_seu_out                     : out std_logic_vector(15 downto 0);
        dbg_ses_out                     : out std_logic_vector(15 downto 0);
        dbg_alureg_low                  : out std_logic_vector(15 downto 0);
        dbg_alureg_high                 : out std_logic_vector(15 downto 0);
        dbg_alureg_out                  : out std_logic_vector(31 downto 0);
        dbg_alu_out                     : out std_logic_vector(31 downto 0);
        dbg_alu_out_low                 : out std_logic_vector(15 downto 0);
        dbg_ar_in                       : out std_logic_vector(15 downto 0);
        dbg_ar_out                      : out std_logic_vector(15 downto 0);
        dbg_ir_out                      : out std_logic_vector(31 downto 0);
        dbg_radrx                       : out std_logic_vector(4 downto 0);
        dbg_radry                       : out std_logic_vector(4 downto 0);
        dbg_radrdest                    : out std_logic_vector(4 downto 0);
        dbg_dest                        : out std_logic_vector(4 downto 0);
        dbg_x_alu_a                     : out std_logic_vector(15 downto 0);
        dbg_y_alu_b                     : out std_logic_vector(15 downto 0);
        dbg_alusby                      : out std_logic;
        dbg_xy_xout                     : out std_logic_vector(15 downto 0);
        dbg_xy_yout                     : out std_logic_vector(15 downto 0);
        dbg_xy_out                      : out std_logic_vector(31 downto 0);
        dbg_xy_in                       : out std_logic_vector(31 downto 0);
        dbg_bsmux                       : out std_logic_vector(15 downto 0);
        dbg_ram_data                    : out std_logic_vector(31 downto 0);
        dbg_ramw_neg                    : out std_logic;
        dbg_ram_out                     : out std_logic_vector(31 downto 0);
        dbg_holder_x                    : out std_logic_vector(15 downto 0);
        dbg_holder_y                    : out std_logic_vector(15 downto 0);
        dbg_memsel_out                  : out std_logic_vector(15 downto 0);
        dbg_write_mux_out               : out std_logic_vector(15 downto 0);
        dbg_mmap_consider               : out std_logic;
        dbg_pciwe                       : out std_logic;
        dbg_iretsel                     : out std_logic
    );
end to_simulate_main;

architecture Behavioral of to_simulate_main is
    -- Internal Signals
    signal clk : std_logic;
    signal reg_0_internal : std_logic_vector(15 downto 0);
    signal opcode : std_logic_vector(5 downto 0);
    signal romcont : std_logic_vector(31 downto 0);

    signal iretsel, pciwe, pcwe, segsel, bssel, arwe, ramw, irwe, drwe, rwe, xywe, aluwe, cswe, dswe, dsel : std_logic := '0';
    signal adrsel, memssel, rwsel, xsel, ysel, pcsel : std_logic_vector(1 downto 0) := "00";
    signal alum : std_logic_vector(3 downto 0) := "0000";

    signal sign_f, carry_f, overflow_f, zero_f : std_logic;
    signal bssel_vector, dsel_vector, seg_sel_vec : std_logic_vector(0 downto 0);
    signal segment_in, cs_out, ds_out, seg_mux : std_logic_vector(1 downto 0);
    signal cs_ds_concat : std_logic_vector(3 downto 0);
    signal pcsel_in, pc_out, adr_mux : std_logic_vector(15 downto 0);
    signal adr_mux_input_concatenated : std_logic_vector(63 downto 0);
    signal mem_addr : std_logic_vector(17 downto 0);
    signal ram_mux_out, dr_out, alureg_out, alu_out, ir_out, xy_out, xy_in, ram_data, ram_out : std_logic_vector(31 downto 0);
    signal dr_low, dr_high, alureg_low, alureg_high, alu_out_low, ar_in, ar_out, x_alu_a, y_alu_b, xy_xout, xy_yout, bsmux, memsel_out, write_mux_out, holder_x, holder_y : std_logic_vector(15 downto 0);
    signal dr_low_low, dr_low_high : std_logic_vector(7 downto 0);
    signal seu_out, ses_out : std_logic_vector(15 downto 0);
    signal pcsel_mux_sel_concetaned : std_logic_vector(2 downto 0);
    signal pcsel_mux_input_concatenated : std_logic_vector(127 downto 0);
    signal dest_mux_input_concatenated : std_logic_vector(9 downto 0);
    signal x_mux_input_concatenated, y_mux_input_concatenated, memsel_mux_input_concatenated, write_mux_input_concatenated, memory_ir_mux_input_concatenated : std_logic_vector(63 downto 0);
    signal bs_mux_input_concatenated : std_logic_vector(31 downto 0);
    signal memory_ir_mux_sel : std_logic_vector(0 downto 0);
    signal radrx, radry, radrdest, dest : std_logic_vector(4 downto 0);
    signal alusby, ramwe, ramw_neg, mmap_consider, interrupt_buffer_out : std_logic;
    signal out_peri_dmux_out_vector : std_logic_vector(31 downto 0);
    signal mmap_consider_vector : std_logic_vector(0 downto 0);
    signal mmap_sel : std_logic_vector(4 downto 0);
    signal from_input_peripheral_mux_input_concatenated : std_logic_vector(63 downto 0);
    signal input_peripheral_mux_ir : std_logic_vector(31 downto 0);
    signal bsel_mux_out_to_output_peripheral_in : std_logic_vector(31 downto 0);
    signal to_output_dmux_output_concatenated : std_logic_vector(63 downto 0);
    signal pr_datain, pr_dataout, pciout : std_logic_vector(15 downto 0);
    
    constant INTERRUPT_JUMP_ADDR : std_logic_vector(15 downto 0) := "0000000011000000"; -- Hex C0

begin
    -- 1. BYPASS CLOCK DIVIDER for Simulation
    clk <= clk_extrn;

    -- 2. ASSIGN DEBUG OUTPUTS
    dbg_reg_0_out <= reg_0_internal;
    dbg_opcode <= opcode;
    dbg_romcont <= romcont;
    dbg_pcwe <= pcwe; dbg_adrsel <= adrsel; dbg_segsel <= segsel; dbg_bssel <= bssel;
    dbg_arwe <= arwe; dbg_ramw <= ramw; dbg_irwe <= irwe; dbg_drwe <= drwe;
    dbg_memssel <= memssel; dbg_rwsel <= rwsel; dbg_rwe <= rwe; dbg_xywe <= xywe;
    dbg_xsel <= xsel; dbg_ysel <= ysel; dbg_alum <= alum; dbg_aluwe <= aluwe;
    dbg_pcsel <= pcsel; dbg_cswe <= cswe; dbg_dswe <= dswe; dbg_dsel <= dsel;
    dbg_sign_f <= sign_f; dbg_carry_f <= carry_f; dbg_overflow_f <= overflow_f; dbg_zero_f <= zero_f;
    dbg_bssel_vector <= bssel_vector; dbg_dsel_vector <= dsel_vector;
    dbg_segment_in <= segment_in; dbg_cs_out <= cs_out; dbg_ds_out <= ds_out;
    dbg_cs_ds_concat <= cs_ds_concat; dbg_seg_sel_vec <= seg_sel_vec; dbg_seg_mux <= seg_mux;
    dbg_pcsel_in <= pcsel_in; dbg_pc_out <= pc_out; dbg_adr_mux <= adr_mux;
    dbg_mem_addr <= mem_addr; dbg_ram_mux_out <= ram_mux_out; dbg_dr_out <= dr_out;
    dbg_dr_low <= dr_low; dbg_dr_high <= dr_high; dbg_seu_out <= seu_out; dbg_ses_out <= ses_out;
    dbg_alureg_low <= alureg_low; dbg_alureg_high <= alureg_high; dbg_alureg_out <= alureg_out;
    dbg_alu_out <= alu_out; dbg_alu_out_low <= alu_out_low; dbg_ar_in <= ar_in; dbg_ar_out <= ar_out;
    dbg_ir_out <= ir_out; dbg_radrx <= radrx; dbg_radry <= radry; dbg_radrdest <= radrdest; dbg_dest <= dest;
    dbg_x_alu_a <= x_alu_a; dbg_y_alu_b <= y_alu_b; dbg_alusby <= alusby;
    dbg_xy_xout <= xy_xout; dbg_xy_yout <= xy_yout; dbg_xy_out <= xy_out; dbg_xy_in <= xy_in;
    dbg_bsmux <= bsmux; dbg_ram_data <= ram_data; dbg_ramw_neg <= ramw_neg; dbg_ram_out <= ram_out;
    dbg_holder_x <= holder_x; dbg_holder_y <= holder_y; dbg_memsel_out <= memsel_out; dbg_write_mux_out <= write_mux_out;
    dbg_mmap_consider <= mmap_consider;
    dbg_pciwe <= pciwe; dbg_iretsel <= iretsel;


    ds_reg: entity work.custom_register generic map(BIT_WIDTH => 2)
    port map(input => segment_in, write_enable => dswe, clk => clk, reset => reset, output => ds_out);

    cs_reg: entity work.custom_register generic map(BIT_WIDTH => 2)
    port map(input => segment_in, write_enable => cswe, clk => clk, reset => reset, output => cs_out);

    segment_selector_mux: entity work.multiplexer generic map(SEL_NUMBER => 1, BIT_WIDTH => 2)
    port map(sel => seg_sel_vec, input => cs_ds_concat, output => seg_mux);
    cs_ds_concat <= cs_out & ds_out;
    seg_sel_vec <= (others => segsel);

    pc_reg: entity work.custom_register generic map(BIT_WIDTH => 16)
    port map(input => pcsel_in, write_enable => pcwe, clk => clk, reset => reset, output => pc_out);

    adr_sel_mux: entity work.multiplexer generic map(SEL_NUMBER => 2, BIT_WIDTH => 16)
    port map(sel => adrsel, input => adr_mux_input_concatenated, output => adr_mux);
    adr_mux_input_concatenated <= x"0000" & xy_yout & ar_out & pc_out;
    mem_addr <= seg_mux & adr_mux;

    -- FIX: Ensure DATA_WIDTH matches ROM (33)
    FSM_inst: entity work.FSM
     generic map(OPCODE_WIDTH => 6, COUNT_BIT_WIDTH => 3, JUMPTYPES_WIDTH => 3, DATA_WIDTH => 33, ADDRESS_SIZE => 9)
     port map(interrupt => interrupt_buffer_out, opcode => opcode, clk => clk, reset => reset,
        sign_f => sign_f, overflow_f => overflow_f, zero_f => zero_f, iretsel => iretsel,
        pciwe => pciwe, pcwe => pcwe, adrsel => adrsel, segsel => segsel, bssel => bssel, arwe => arwe,
        ramw => ramw, irwe => irwe, drwe => drwe, memssel => memssel, rwsel => rwsel, rwe => rwe,
        xywe => xywe, xsel => xsel, ysel => ysel, alum => alum, aluwe => aluwe, pcsel => pcsel,
        cswe => cswe, dswe => dswe, dsel => dsel, suspend => alusby);

    data_reg: entity work.custom_register generic map(BIT_WIDTH => 32)
    port map(input => input_peripheral_mux_ir, write_enable => drwe, clk => clk, reset => reset, output => dr_out);
    dr_low <= dr_out(15 downto 0); dr_high <= dr_out(31 downto 16);
    dr_low_low <= dr_low(7 downto 0); dr_low_high <= dr_low(15 downto 8);

    signextend_signed: entity work.signextend generic map(BIT_WIDTH_IN => 8, BIT_WIDTH_OUT => 16)
    port map(inputs => dr_low_low, outputs => ses_out);
    signextend_unsigned: entity work.zeroextend generic map(BIT_WIDTH_IN => 8, BIT_WIDTH_OUT => 16)
    port map(inputs => dr_low_low, outputs => seu_out);

    alu_reg: entity work.custom_register generic map(BIT_WIDTH => 32)
    port map(input => alu_out, write_enable => aluwe, clk => clk, reset => reset, output => alureg_out);
    alureg_low <= alureg_out(15 downto 0); alureg_high <= alureg_out(31 downto 16); alu_out_low <= alu_out(15 downto 0);

    address_reg: entity work.custom_register generic map(BIT_WIDTH => 16)
    port map(input => ar_in, write_enable => arwe, clk => clk, reset => reset, output => ar_out);

    -- FIX: SEL_NUMBER 3 to handle 3 selection bits
    pcsel_mux: entity work.multiplexer generic map(SEL_NUMBER => 3, BIT_WIDTH => 16)
    port map(sel => pcsel_mux_sel_concetaned, input => pcsel_mux_input_concatenated, output => pcsel_in);
    pcsel_mux_sel_concetaned <= iretsel & pcsel;
    pcsel_mux_input_concatenated <= x"0000" & x"0000" & pciout & INTERRUPT_JUMP_ADDR & ar_out & pc_out & alureg_low & alu_out_low;

    instr_reg: entity work.custom_register generic map(BIT_WIDTH => 32)
    port map(input => input_peripheral_mux_ir, write_enable => irwe, clk => clk, reset => reset, output => ir_out);
    opcode <= ir_out(31 downto 26); radrx <= ir_out(25 downto 21); radry <= ir_out(20 downto 16); radrdest <= ir_out(15 downto 11); ar_in <= ir_out(15 downto 0);

    destination_mux: entity work.multiplexer generic map(SEL_NUMBER => 1, BIT_WIDTH => 5)
    port map(sel => dsel_vector, input => dest_mux_input_concatenated, output => dest);
    dsel_vector <= (0 => dsel); dest_mux_input_concatenated <= radrdest & radrx;

    ALU_inst: entity work.ALU generic map(BIT_WIDTH_IN => 16)
    port map(clk => clk, reset => reset, alu_mode => alum, A => x_alu_a, B => y_alu_b, Y => alu_out,
        carry_f => carry_f, sign_f => sign_f, zero_f => zero_f, overflow_f => overflow_f, ALU_standby => alusby);

    x_mux: entity work.multiplexer generic map(SEL_NUMBER => 2, BIT_WIDTH => 16)
    port map(sel => xsel, input => x_mux_input_concatenated, output => x_alu_a);
    x_mux_input_concatenated <= x"0000" & x"0000" & pc_out & xy_xout;

    y_mux: entity work.multiplexer generic map(SEL_NUMBER => 2, BIT_WIDTH => 16)
    port map(sel => ysel, input => y_mux_input_concatenated, output => y_alu_b);
    y_mux_input_concatenated <= x"0000" & x"0001" & x"0000" & xy_yout;

    bs_mux: entity work.multiplexer generic map(SEL_NUMBER => 1, BIT_WIDTH => 16)
    port map(sel => bssel_vector, input => bs_mux_input_concatenated, output => bsmux);
    bssel_vector <= (0 => bssel); bs_mux_input_concatenated <= dr_low_high & alureg_low(7 downto 0) & alureg_low;
    bsel_mux_out_to_output_peripheral_in <= dr_high & bsmux;

    xy_reg: entity work.custom_register generic map(BIT_WIDTH => 32)
    port map(input => xy_in, write_enable => xywe, clk => clk, reset => reset, output => xy_out);
    xy_xout <= xy_out(15 downto 0); xy_yout <= xy_out(31 downto 16); xy_in <= holder_y & holder_x;

    memsel_mux: entity work.multiplexer generic map(SEL_NUMBER => 2, BIT_WIDTH => 16)
    port map(sel => memssel, input => memsel_mux_input_concatenated, output => memsel_out);
    memsel_mux_input_concatenated <= x"0000" & ses_out & seu_out & dr_low;

    regw_mux: entity work.multiplexer generic map(SEL_NUMBER => 2, BIT_WIDTH => 16)
    port map(sel => rwsel, input => write_mux_input_concatenated, output => write_mux_out);
    write_mux_input_concatenated <= ar_in &  alureg_high & alureg_low & memsel_out;

    register_holder_inst: entity work.register_holder generic map(BIT_WIDTH => 16, ADDRESS_SIZE => 5)
    port map(adress_x => radrx, address_y => radry, dest_address => dest, write_enable => rwe, clk => clk, reset => reset,
        input_w => write_mux_out, output_x => holder_x, output_y => holder_y, reg_0_out => reg_0_internal);

    process(segsel, cs_out) begin
        if cs_out = "00" then memory_ir_mux_sel <= (0 => not segsel);
        else memory_ir_mux_sel <= (0 => '0'); end if;
    end process;

    mem_ir_mux: entity work.multiplexer generic map(SEL_NUMBER => 1, BIT_WIDTH => 32)
    port map(sel => memory_ir_mux_sel, input => memory_ir_mux_input_concatenated, output => ram_mux_out);
    memory_ir_mux_input_concatenated <= romcont & ram_out;

    ROM_inst: entity work.ROM generic map(DATA_WIDTH => 32)
    port map(address => mem_addr, output => romcont);

    RAM_inst: entity work.RAM generic map(DATA_WIDTH => 32)
    port map(address => mem_addr, clk => clk, write_enable => ramwe, output_enable => ramw_neg, data_input => ram_data, data_output => ram_out);
    ramwe <= (not mmap_consider) and ramw; ramw_neg <= not ramw;

    MMAP_inst: entity work.MMAP generic map(BIT_WIDTH => 16, OPCODE_WIDTH => 6, ADDRESS_SIZE => 5, START_ADDRESS => 255)
    port map(mem_addr => mem_addr, opcode => opcode, irwe => irwe, sel_consider => mmap_consider, sel_out => mmap_sel);
    mmap_consider_vector <= (0 => mmap_consider);

    from_input_peripheral_mux: entity work.multiplexer generic map(SEL_NUMBER => 1, BIT_WIDTH => 32)
    port map(sel => mmap_consider_vector, input => from_input_peripheral_mux_input_concatenated, output => input_peripheral_mux_ir);
    from_input_peripheral_mux_input_concatenated <= x"0000" & pr_dataout & ram_mux_out;

    to_output_demultiplexer: entity work.demultiplexer generic map(SEL_NUMBER => 1, BIT_WIDTH => 32)
    port map(sel => mmap_consider_vector, input => bsel_mux_out_to_output_peripheral_in, output => to_output_dmux_output_concatenated);
    pr_datain <= to_output_dmux_output_concatenated(47 downto 32); ram_data <= to_output_dmux_output_concatenated(31 downto 0);

    peripherals_regs_inst: entity work.peripherals_regs generic map(BIT_WIDTH => 16, ADDRESS_SIZE => 5)
    port map(clk => clk, reset => reset, ramwe => ramw, mmap_consider => mmap_consider, out0 => out0, out1 => out1,
        pdatout => pr_dataout, in0 => in0, in1 => in1, pdatin => pr_datain, mmap_sel => mmap_sel);

    interrupt_buffer_inst: entity work.interrupt_buffer
    port map(clk => clk, interrupt => interrupt, reset => reset, pciwe => pciwe, intbuf_out => interrupt_buffer_out);

    interrupt_program_counter_store: entity work.custom_register generic map(BIT_WIDTH => 16)
    port map(input => pc_out, write_enable => pciwe, clk => clk, reset => reset, output => pciout);
    
    segment_in <= alureg_low(1 downto 0);
end Behavioral;