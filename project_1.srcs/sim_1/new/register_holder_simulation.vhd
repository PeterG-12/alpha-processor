-- Test bench for the register_holder entity

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_holder_simulation is
end entity register_holder_simulation;

architecture Behavioral of register_holder_simulation is

    -- Component declaration for the Unit Under Test (UUT)
    component register_holder is
        generic(BIT_WIDTH : integer;
                ADDRESS_SIZE : integer);
        port(adress_x, address_y, dest_address : in std_logic_vector(ADDRESS_SIZE - 1 downto 0);
            write_enable, clk, reset  : in std_logic;
            input_w : in std_logic_vector(BIT_WIDTH - 1 downto 0);
            output_x, output_y : out std_logic_vector(BIT_WIDTH - 1 downto 0)
            );
    end component;
    
    -- Define generic values for this specific simulation
    constant TB_BIT_WIDTH : integer := 16;
    constant TB_ADDRESS_SIZE : integer := 5;

    -- Signal declarations for the test bench
    signal tb_adress_x, tb_address_y, tb_dest_address : std_logic_vector(TB_ADDRESS_SIZE - 1 downto 0);
    signal tb_write_enable, tb_clk, tb_reset  : std_logic;
    signal tb_input_w : std_logic_vector(TB_BIT_WIDTH - 1 downto 0);
    signal tb_output_x, tb_output_y : std_logic_vector(TB_BIT_WIDTH - 1 downto 0);

    -- Clock constant
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    holder : register_holder
    generic map(
        BIT_WIDTH => TB_BIT_WIDTH,
        ADDRESS_SIZE => TB_ADDRESS_SIZE
    )
    port map(
        adress_x => tb_adress_x,
        address_y => tb_address_y,
        dest_address => tb_dest_address,
        write_enable => tb_write_enable,
        clk => tb_clk,
        reset => tb_reset,
        input_w => tb_input_w,
        output_x => tb_output_x,
        output_y => tb_output_y
    );

    -- Clock generation process
    clk_gen_process : process
    begin
        tb_clk <= '0';
        wait for CLK_PERIOD / 2;
        tb_clk <= '1';
        wait for CLK_PERIOD / 2;
    end process clk_gen_process;

    -- Stimulus generation process
    process
    begin
        -- Step 1: Initialize all inputs to a known state and assert reset.
        tb_adress_x <= (others => '0');
        tb_address_y <= (others => '0');
        tb_dest_address <= (others => '0');
        tb_input_w <= (others => '0');
        tb_write_enable <= '0';
        tb_reset <= '1';
        
        -- Wait for a few clock cycles to allow the reset to be effective.
        wait for CLK_PERIOD * 3;
        
        -- Step 2: De-assert reset to begin normal operation.
        tb_reset <= '0';
        wait for CLK_PERIOD;
        
        -- Step 3: Write to register 0. Inputs must be stable before the clock edge.
        tb_write_enable <= '1';
        tb_dest_address <= std_logic_vector(to_unsigned(0, TB_ADDRESS_SIZE));
        tb_input_w <= std_logic_vector(to_unsigned(3, TB_BIT_WIDTH));
        wait for CLK_PERIOD;
        
        -- Step 4: Write to register 1.
        tb_dest_address <= std_logic_vector(to_unsigned(1, TB_ADDRESS_SIZE));
        tb_input_w <= std_logic_vector(to_unsigned(4, TB_BIT_WIDTH));
        wait for CLK_PERIOD;
        
        -- Step 5: Read from two different registers simultaneously.
        tb_write_enable <= '0';
        tb_adress_x <= std_logic_vector(to_unsigned(0, TB_ADDRESS_SIZE));
        tb_address_y <= std_logic_vector(to_unsigned(1, TB_ADDRESS_SIZE));
        wait for CLK_PERIOD;
        
        -- End of simulation
        wait;
        
    end process;

end Behavioral;