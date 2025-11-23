library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ALU is
    generic(BIT_WIDTH_IN : integer);
    port(alumode : in std_logic_vector(3 downto 0);
        A, B : in std_logic_vector(BIT_WIDTH_IN - 1 downto 0);
        Y : out std_logic_vector(2 * BIT_WIDTH_IN - 1 downto 0);
        carry_f, sign_f, zero_f, overflow_f : out std_logic
    );
end ALU;

architecture Behavioral of ALU is

begin

    process(alumode, A, B)
    
    variable cf : std_logic;
    variable sf : std_logic;
    variable ovf : std_logic;
    variable zf : std_logic;

    variable a_ext : signed(BIT_WIDTH_IN downto 0);
    variable b_ext : signed(BIT_WIDTH_IN downto 0);
    variable add_sub_res : signed(BIT_WIDTH_IN downto 0);
    variable other_res : std_logic_vector(2 * BIT_WIDTH_IN - 1 downto 0);


    begin
        case alumode is
            "0000" =>
                add_sub_res := a_ext + b_ext;
                y_res       := std_logic_vector(resize(add_sub_res(BIT_WIDTH_IN - 1 downto 0), y_res'length));

                cf := add_sub_res(BIT_WIDTH_IN);
                overflow_var := a_ext(BIT_WIDTH_IN - 1) and b_ext(BIT_WIDTH_IN - 1) and (not add_sub_res(BIT_WIDTH_IN - 1));
                overflow_var := overflow_var or ((not a_ext(BIT_WIDTH_IN - 1)) and (not b_ext(BIT_WIDTH_IN - 1)) and add_sub_res(BIT_WIDTH_IN - 1));
            "0001" =>
                add_sub_res := a_ext - b_ext;
                y_res       := std_logic_vector(resize(add_sub_res(BIT_WIDTH_IN - 1 downto 0), y_res'length));

                cf := not(add_sub_res(BIT_WIDTH_IN));
                overflow_var := a_ext(BIT_WIDTH_IN - 1) and (not b_ext(BIT_WIDTH_IN - 1)) and (not add_sub_res(BIT_WIDTH_IN - 1));
                overflow_var := overflow_var or ((not a_ext(BIT_WIDTH_IN - 1)) and b_ext(BIT_WIDTH_IN - 1) and add_sub_res(BIT_WIDTH_IN - 1));
            when "0010" =>
                y_res(BIT_WIDTH_IN - 1 downto 0) := A and B;

            when "0011" =>
                y_res(BIT_WIDTH_IN - 1 downto 0) := A or B;
            
            when "0100" =>
                y_res(BIT_WIDTH_IN - 1 downto 0) := A xor B;
                
            when "0101" =>
                y_res(BIT_WIDTH_IN - 1 downto 0) := std_logic_vector(shift_left(unsigned(A), to_integer(unsigned(B))));

            when "0110" =>
                y_res(BIT_WIDTH_IN - 1 downto 0) := std_logic_vector(shift_right(unsigned(A), to_integer(unsigned(B))));

            when "0111" =>
                y_res(BIT_WIDTH_IN - 1 downto 0) := std_logic_vector(shift_right(signed(A), to_integer(unsigned(B))));

            when "1000" =>
                y_res(BIT_WIDTH_IN - 1 downto 0) := std_logic_vector(rotate_left(unsigned(A), to_integer(unsigned(B))));

            when "1001" =>
                y_res(BIT_WIDTH_IN - 1 downto 0) := std_logic_vector(rotate_right(unsigned(A), to_integer(unsigned(B))));

            when "1010" =>
                add_sub_res := -a_ext;
                y_res       := std_logic_vector(resize(add_sub_res(BIT_WIDTH_IN - 1 downto 0), y_res'length));

            when "1011" =>
                y_res := std_logic_vector(resize(unsigned(A) * unsigned(B), y_res'length));

            when "1100" =>
                y_res := std_logic_vector(resize(signed(A) * signed(B), y_res'length));
        end case;
    end process;

end Behavioral;
