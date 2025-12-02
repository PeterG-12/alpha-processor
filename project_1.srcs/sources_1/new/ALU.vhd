library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ALU is
    generic(BIT_WIDTH_IN : integer);
    port(clk, reset : in std_logic;
        alu_mode : in std_logic_vector(3 downto 0);
        A, B : in std_logic_vector(BIT_WIDTH_IN - 1 downto 0);
        Y : out std_logic_vector(2 * BIT_WIDTH_IN - 1 downto 0);
        carry_f, sign_f, zero_f, overflow_f, ALU_standby : out std_logic
    );
end ALU;

architecture Behavioral of ALU is

    component DIV is
    generic(BIT_WIDTH : integer);
    port(
        clk, reset, dividing : in std_logic;
        ALU_standby : out std_logic;
        divisor, dividend : in std_logic_vector(BIT_WIDTH - 1 downto 0);
        quotient, remainder : out std_logic_vector(BIT_WIDTH - 1 downto 0));
    end component;

    signal combinational_result : std_logic_vector(2 * BIT_WIDTH_IN - 1 downto 0);
    -- Intermediate signals for holding the results from DIV module
    signal div_quotient : std_logic_vector(BIT_WIDTH_IN - 1 downto 0);
    signal div_remainder : std_logic_vector(BIT_WIDTH_IN - 1 downto 0);
    -- Div module start signal
    signal do_divide : std_logic;

begin


    div_module : DIV
    generic map(
        BIT_WIDTH => BIT_WIDTH_IN
    )
    port map(
        clk => clk,
        reset => reset,
        dividing => do_divide,
        ALU_standby => ALU_standby,
        divisor => A,
        dividend => B,
        quotient => div_quotient,
        remainder => div_remainder
    );

    process(alu_mode, A, B)
    
    variable cf : std_logic;
    variable sf : std_logic;
    variable ovf : std_logic;
    variable zf : std_logic;

    variable a_ext : signed(BIT_WIDTH_IN downto 0);
    variable b_ext : signed(BIT_WIDTH_IN downto 0);
    variable res : signed(BIT_WIDTH_IN downto 0);
    variable add_sub_res : signed(BIT_WIDTH_IN downto 0);
    variable other_res : std_logic_vector(2 * BIT_WIDTH_IN - 1 downto 0);


    begin

        a_ext := signed(A);
        b_ext := signed(B);

        cf := '0';
        sf := '0';
        ovf := '0';
        zf := '0';

        case alu_mode is
            -- ADD
            when "0000" =>
                add_sub_res := a_ext + b_ext;
                res       := (resize(add_sub_res(BIT_WIDTH_IN - 1 downto 0), res'length));

                cf := add_sub_res(BIT_WIDTH_IN);
                ovf := a_ext(BIT_WIDTH_IN - 1) and b_ext(BIT_WIDTH_IN - 1) and (not add_sub_res(BIT_WIDTH_IN - 1));
                ovf := ovf or ((not a_ext(BIT_WIDTH_IN - 1)) and (not b_ext(BIT_WIDTH_IN - 1)) and add_sub_res(BIT_WIDTH_IN - 1));
            -- SUB            
            when "0001" =>
                add_sub_res := a_ext - b_ext;
                res       := (resize(add_sub_res(BIT_WIDTH_IN - 1 downto 0), res'length));

                cf := not(add_sub_res(BIT_WIDTH_IN));
                ovf := a_ext(BIT_WIDTH_IN - 1) and (not b_ext(BIT_WIDTH_IN - 1)) and (not add_sub_res(BIT_WIDTH_IN - 1));
                ovf := ovf or ((not a_ext(BIT_WIDTH_IN - 1)) and b_ext(BIT_WIDTH_IN - 1) and add_sub_res(BIT_WIDTH_IN - 1));
                sf := add_sub_res(BIT_WIDTH_IN - 1);
                if add_sub_res(BIT_WIDTH_IN - 1 downto 0) = to_signed(0, BIT_WIDTH_IN) then
                    zf := '1';
                else
                    zf := '0';
                end if;
                
            when "0010" =>
                res(BIT_WIDTH_IN - 1 downto 0) := a_ext and b_ext;

            when "0011" =>
                res(BIT_WIDTH_IN - 1 downto 0) := a_ext or b_ext;
            
            when "0100" =>
                res(BIT_WIDTH_IN - 1 downto 0) := a_ext xor b_ext;
                
            when "0101" =>
                res(BIT_WIDTH_IN - 1 downto 0) := signed(shift_left(unsigned(a_ext), to_integer(unsigned(b_ext))));

            when "0110" =>
                res(BIT_WIDTH_IN - 1 downto 0) := signed(shift_right(unsigned(a_ext), to_integer(unsigned(b_ext))));

            when "0111" =>
                res(BIT_WIDTH_IN - 1 downto 0) := signed(shift_right(signed(a_ext), to_integer(unsigned(b_ext))));

            when "1000" =>
                res(BIT_WIDTH_IN - 1 downto 0) := signed(rotate_left(unsigned(a_ext), to_integer(unsigned(b_ext))));

            when "1001" =>
                res(BIT_WIDTH_IN - 1 downto 0) := signed(rotate_right(unsigned(a_ext), to_integer(unsigned(b_ext))));

            when "1010" =>
                add_sub_res := -a_ext;
                res       := (resize(add_sub_res(BIT_WIDTH_IN - 1 downto 0), res'length));

            when "1011" =>
                res := signed(resize(unsigned(a_ext) * unsigned(b_ext), res'length));

            when "1100" =>
                res := (resize(signed(a_ext) * signed(b_ext), res'length));
            when others => 
                res := (others => '0');
        end case;

        carry_f <= cf;
        zero_f <= zf;
        sign_f <= sf;
        overflow_f <= ovf;

        combinational_result <= std_logic_vector(res);

    end process;
    -- Division handler
    process(alu_mode)
        begin
            if alu_mode = "1101" then
                do_divide <= '1';
                Y <= div_remainder & div_quotient;
            else
                do_divide <= '0';
                Y <= combinational_result;
            end if;
        end process;

end Behavioral;
