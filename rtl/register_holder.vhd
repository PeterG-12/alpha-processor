library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


-- These are the processor's generel purpose registers
-- A single one can be written and two can be read at the same time

entity register_holder is
    generic(BIT_WIDTH : integer := 16;
            ADDRESS_SIZE : integer := 5);
    port(adress_x, address_y, dest_address : in std_logic_vector(ADDRESS_SIZE - 1 downto 0);
        write_enable, clk, reset  : in std_logic;
        input_w : in std_logic_vector(BIT_WIDTH - 1 downto 0);
        output_x, output_y : out std_logic_vector(BIT_WIDTH - 1 downto 0);
        reg_0_out : out std_logic_vector(BIT_WIDTH - 1 downto 0)
        );
end register_holder;

architecture Structural of register_holder is


    signal register_outputs_concatenated : std_logic_vector((2**ADDRESS_SIZE * BIT_WIDTH) - 1 downto 0);
    signal register_inputs_concatenated : std_logic_vector((2**ADDRESS_SIZE * BIT_WIDTH) - 1 downto 0);
    signal register_write_enable_concatenated : std_logic_vector((2**ADDRESS_SIZE) - 1 downto 0);
    -- For casting write_enable
    signal write_enable_vec : std_logic_vector(0 downto 0); 

    component multiplexer is
        generic(SEL_NUMBER : integer;
                BIT_WIDTH : integer);
        port(sel : in std_logic_vector(SEL_NUMBER - 1 downto 0);
            input : in std_logic_vector((2**SEL_NUMBER * BIT_WIDTH) - 1 downto 0);
            output : out std_logic_vector(BIT_WIDTH - 1 downto 0)
            );
    end component;

    component custom_register is
        generic(BIT_WIDTH : integer);
        
        port(input : in std_logic_vector(BIT_WIDTH - 1 downto 0);
            write_enable, clk, reset : in std_logic;
            output : out std_logic_vector(BIT_WIDTH - 1 downto 0)
        );
            
    end component;

    component demultiplexer is
    generic(SEL_NUMBER : integer;
            BIT_WIDTH : integer);
    port(sel : in std_logic_vector(SEL_NUMBER - 1 downto 0);
        input : in std_logic_vector(BIT_WIDTH - 1 downto 0);
        output : out std_logic_vector((2**SEL_NUMBER * BIT_WIDTH) - 1 downto 0)
        );
        
    end component;

    begin

        -- Typecast
        write_enable_vec <= (0 => write_enable); 

        x_mux : multiplexer
        generic map(
            SEL_NUMBER => ADDRESS_SIZE,
            BIT_WIDTH => BIT_WIDTH
        )
        port map(
            sel => adress_x,
            input => register_outputs_concatenated,
            output => output_x
        );
        

        y_mux : multiplexer
        generic map(
            SEL_NUMBER => ADDRESS_SIZE,
            BIT_WIDTH => BIT_WIDTH
        )
        port map(
            sel => address_y,
            input => register_outputs_concatenated,
            output => output_y
        );
        

        write_data_demux : demultiplexer
        generic map(
            SEL_NUMBER => ADDRESS_SIZE,
            BIT_WIDTH => BIT_WIDTH
        )
        port map(
            sel => dest_address,
            input => input_w,
            output => register_inputs_concatenated
        );
       

        write_enable_demux : demultiplexer
        generic map(
            SEL_NUMBER => ADDRESS_SIZE,
            BIT_WIDTH => 1
        )
        port map(
            sel => dest_address,
            input => write_enable_vec,
            output => register_write_enable_concatenated
        );
        

        registers : for i in 0 to 2**ADDRESS_SIZE - 1 generate
            register_i : custom_register
            generic map(
                BIT_WIDTH=>BIT_WIDTH
            )
            port map(
                clk => clk,
                reset => reset,
                write_enable => register_write_enable_concatenated(i),
                input => register_inputs_concatenated((i + 1) * BIT_WIDTH - 1 downto i * BIT_WIDTH),
                output => register_outputs_concatenated((i + 1) * BIT_WIDTH - 1 downto i * BIT_WIDTH)
            );
            
        end generate registers;

        reg_0_out <= register_outputs_concatenated(BIT_WIDTH - 1 downto 0);

end Structural;
