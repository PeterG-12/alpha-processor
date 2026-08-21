library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mainsim is
    -- Testbench has no ports
end mainsim;

architecture Behavioral of mainsim is

    -- 1. Component Declaration (Matching to_simulate_main exactly)
    component to_simulate_main
        port(
            clk_extrn, reset : in std_logic;
            an : out std_logic_vector(3 downto 0);
            seg : out std_logic_vector(6 downto 0);
            out0 : out std_logic_vector(15 downto 0);
            out1 : out std_logic_vector(15 downto 0);
            in0 : in std_logic_vector(15 downto 0);
            in1 : in std_logic_vector(15 downto 0);
            interrupt : in std_logic;

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
    end component;

    -- 2. Signal Declarations
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal interrupt : std_logic := '0';
    signal in0 : std_logic_vector(15 downto 0) := (others => '0');
    signal in1 : std_logic_vector(15 downto 0) := (others => '0');
    
    signal an : std_logic_vector(3 downto 0);
    signal seg : std_logic_vector(6 downto 0);
    signal out0, out1 : std_logic_vector(15 downto 0);

    -- Full list of Debug Signals
    signal dbg_reg_0_out       : std_logic_vector(15 downto 0);
    signal dbg_opcode          : std_logic_vector(5 downto 0);
    signal dbg_romcont         : std_logic_vector(31 downto 0);
    signal dbg_pcwe            : std_logic;
    signal dbg_adrsel          : std_logic_vector(1 downto 0);
    signal dbg_segsel          : std_logic;
    signal dbg_bssel           : std_logic;
    signal dbg_arwe            : std_logic;
    signal dbg_ramw            : std_logic;
    signal dbg_irwe            : std_logic;
    signal dbg_drwe            : std_logic;
    signal dbg_memssel         : std_logic_vector(1 downto 0);
    signal dbg_rwsel           : std_logic_vector(1 downto 0);
    signal dbg_rwe             : std_logic;
    signal dbg_xywe            : std_logic;
    signal dbg_xsel            : std_logic_vector(1 downto 0);
    signal dbg_ysel            : std_logic_vector(1 downto 0);
    signal dbg_alum            : std_logic_vector(3 downto 0);
    signal dbg_aluwe           : std_logic;
    signal dbg_pcsel           : std_logic_vector(1 downto 0);
    signal dbg_cswe            : std_logic;
    signal dbg_dswe            : std_logic;
    signal dbg_dsel            : std_logic;
    signal dbg_sign_f          : std_logic;
    signal dbg_carry_f         : std_logic;
    signal dbg_overflow_f      : std_logic;
    signal dbg_zero_f          : std_logic;
    signal dbg_bssel_vector    : std_logic_vector(0 downto 0);
    signal dbg_dsel_vector     : std_logic_vector(0 downto 0);
    signal dbg_segment_in      : std_logic_vector(1 downto 0);
    signal dbg_cs_out          : std_logic_vector(1 downto 0);
    signal dbg_ds_out          : std_logic_vector(1 downto 0);
    signal dbg_cs_ds_concat    : std_logic_vector(3 downto 0);
    signal dbg_seg_sel_vec     : std_logic_vector(0 downto 0);
    signal dbg_seg_mux         : std_logic_vector(1 downto 0);
    signal dbg_pcsel_in        : std_logic_vector(15 downto 0);
    signal dbg_pc_out          : std_logic_vector(15 downto 0);
    signal dbg_adr_mux         : std_logic_vector(15 downto 0);
    signal dbg_mem_addr        : std_logic_vector(17 downto 0);
    signal dbg_ram_mux_out     : std_logic_vector(31 downto 0);
    signal dbg_dr_out          : std_logic_vector(31 downto 0);
    signal dbg_dr_low          : std_logic_vector(15 downto 0);
    signal dbg_dr_high         : std_logic_vector(15 downto 0);
    signal dbg_seu_out         : std_logic_vector(15 downto 0);
    signal dbg_ses_out         : std_logic_vector(15 downto 0);
    signal dbg_alureg_low      : std_logic_vector(15 downto 0);
    signal dbg_alureg_high     : std_logic_vector(15 downto 0);
    signal dbg_alureg_out      : std_logic_vector(31 downto 0);
    signal dbg_alu_out         : std_logic_vector(31 downto 0);
    signal dbg_alu_out_low     : std_logic_vector(15 downto 0);
    signal dbg_ar_in           : std_logic_vector(15 downto 0);
    signal dbg_ar_out          : std_logic_vector(15 downto 0);
    signal dbg_ir_out          : std_logic_vector(31 downto 0);
    signal dbg_radrx           : std_logic_vector(4 downto 0);
    signal dbg_radry           : std_logic_vector(4 downto 0);
    signal dbg_radrdest        : std_logic_vector(4 downto 0);
    signal dbg_dest            : std_logic_vector(4 downto 0);
    signal dbg_x_alu_a         : std_logic_vector(15 downto 0);
    signal dbg_y_alu_b         : std_logic_vector(15 downto 0);
    signal dbg_alusby          : std_logic;
    signal dbg_xy_xout         : std_logic_vector(15 downto 0);
    signal dbg_xy_yout         : std_logic_vector(15 downto 0);
    signal dbg_xy_out          : std_logic_vector(31 downto 0);
    signal dbg_xy_in           : std_logic_vector(31 downto 0);
    signal dbg_bsmux           : std_logic_vector(15 downto 0);
    signal dbg_ram_data        : std_logic_vector(31 downto 0);
    signal dbg_ramw_neg        : std_logic;
    signal dbg_ram_out         : std_logic_vector(31 downto 0);
    signal dbg_holder_x        : std_logic_vector(15 downto 0);
    signal dbg_holder_y        : std_logic_vector(15 downto 0);
    signal dbg_memsel_out      : std_logic_vector(15 downto 0);
    signal dbg_write_mux_out   : std_logic_vector(15 downto 0);
    signal dbg_mmap_consider   : std_logic;
    signal dbg_pciwe           : std_logic;
    signal dbg_iretsel         : std_logic;

    constant CLK_PERIOD : time := 10 ns;

begin

    -- 3. Port Map (Connecting EVERYTHING)
    uut: to_simulate_main
    port map (
        clk_extrn          => clk,
        reset              => reset,
        an                 => an,
        seg                => seg,
        out0               => out0,
        out1               => out1,
        in0                => in0,
        in1                => in1,
        interrupt          => interrupt,
        
        dbg_reg_0_out      => dbg_reg_0_out,
        dbg_opcode         => dbg_opcode,
        dbg_romcont        => dbg_romcont,
        dbg_pcwe           => dbg_pcwe,
        dbg_adrsel         => dbg_adrsel,
        dbg_segsel         => dbg_segsel,
        dbg_bssel          => dbg_bssel,
        dbg_arwe           => dbg_arwe,
        dbg_ramw           => dbg_ramw,
        dbg_irwe           => dbg_irwe,
        dbg_drwe           => dbg_drwe,
        dbg_memssel        => dbg_memssel,
        dbg_rwsel          => dbg_rwsel,
        dbg_rwe            => dbg_rwe,
        dbg_xywe           => dbg_xywe,
        dbg_xsel           => dbg_xsel,
        dbg_ysel           => dbg_ysel,
        dbg_alum           => dbg_alum,
        dbg_aluwe          => dbg_aluwe,
        dbg_pcsel          => dbg_pcsel,
        dbg_cswe           => dbg_cswe,
        dbg_dswe           => dbg_dswe,
        dbg_dsel           => dbg_dsel,
        dbg_sign_f         => dbg_sign_f,
        dbg_carry_f        => dbg_carry_f,
        dbg_overflow_f     => dbg_overflow_f,
        dbg_zero_f         => dbg_zero_f,
        dbg_bssel_vector   => dbg_bssel_vector,
        dbg_dsel_vector    => dbg_dsel_vector,
        dbg_segment_in     => dbg_segment_in,
        dbg_cs_out         => dbg_cs_out,
        dbg_ds_out         => dbg_ds_out,
        dbg_cs_ds_concat   => dbg_cs_ds_concat,
        dbg_seg_sel_vec    => dbg_seg_sel_vec,
        dbg_seg_mux        => dbg_seg_mux,
        dbg_pcsel_in       => dbg_pcsel_in,
        dbg_pc_out         => dbg_pc_out,
        dbg_adr_mux        => dbg_adr_mux,
        dbg_mem_addr       => dbg_mem_addr,
        dbg_ram_mux_out    => dbg_ram_mux_out,
        dbg_dr_out         => dbg_dr_out,
        dbg_dr_low         => dbg_dr_low,
        dbg_dr_high        => dbg_dr_high,
        dbg_seu_out        => dbg_seu_out,
        dbg_ses_out        => dbg_ses_out,
        dbg_alureg_low     => dbg_alureg_low,
        dbg_alureg_high    => dbg_alureg_high,
        dbg_alureg_out     => dbg_alureg_out,
        dbg_alu_out        => dbg_alu_out,
        dbg_alu_out_low    => dbg_alu_out_low,
        dbg_ar_in          => dbg_ar_in,
        dbg_ar_out         => dbg_ar_out,
        dbg_ir_out         => dbg_ir_out,
        dbg_radrx          => dbg_radrx,
        dbg_radry          => dbg_radry,
        dbg_radrdest       => dbg_radrdest,
        dbg_dest           => dbg_dest,
        dbg_x_alu_a        => dbg_x_alu_a,
        dbg_y_alu_b        => dbg_y_alu_b,
        dbg_alusby         => dbg_alusby,
        dbg_xy_xout        => dbg_xy_xout,
        dbg_xy_yout        => dbg_xy_yout,
        dbg_xy_out         => dbg_xy_out,
        dbg_xy_in          => dbg_xy_in,
        dbg_bsmux          => dbg_bsmux,
        dbg_ram_data       => dbg_ram_data,
        dbg_ramw_neg       => dbg_ramw_neg,
        dbg_ram_out        => dbg_ram_out,
        dbg_holder_x       => dbg_holder_x,
        dbg_holder_y       => dbg_holder_y,
        dbg_memsel_out     => dbg_memsel_out,
        dbg_write_mux_out  => dbg_write_mux_out,
        dbg_mmap_consider  => dbg_mmap_consider,
        dbg_pciwe          => dbg_pciwe,
        dbg_iretsel        => dbg_iretsel
    );

    -- 4. Clock Generation
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- 5. Stimulus
    stim_proc: process
    begin
        -- Initialization
        reset <= '1';
        interrupt <= '0';
        in0 <= x"1234";
        in1 <= x"5678";
        
        wait for 40 ns;
        reset <= '0';
        
        -- Run for a while
        wait for 500 ns;

        -- Trigger Interrupt
        interrupt <= '1';
        wait for 20 ns;
        interrupt <= '0';

        -- Observe execution
        wait for 1000 ns;

        wait;
    end process;

end Behavioral;