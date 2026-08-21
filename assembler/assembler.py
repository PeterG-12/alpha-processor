import sys

opcodes = {'NOOP': '000000', 'JE': '000001', 'JNE': '000010', 'JL': '000011', 'JG': '000100', 'JGE': '000101', 'JLE': '000110', 'MOV': '000111', 'LDS': '001000', 'LDU': '001001', 'LDW': '001010', 'LDI': '001011', 'STOREW': '001100', 'STOREB': '001101', 'JUMP': '001110', 'ADD': '001111', 'SUB': '010000', 'AND': '010001', 'OR': '010010', 'XOR': '010011', 'SHL': '010100', 'SHR': '010101', 'SAR': '010110', 'ROL': '010111', 'ROR': '011000', 'NEG': '011001', 'MUL': '011010', 'IMUL': '011011', 'DIV': '011100', 'IDIV': '011101', 'SWDS': '011110', 'SWCS': '011111', 'RLDS': '100000', 'RLDU': '100001', 'RLDW': '100010', 'RSTOREW': '100011', 'RSTOREB': '100100', 'ISET': '100101', 'ICLR': '100110', 'IRET': '100111'}


TYPE_REG = 1
TYPE_IMM = 2
TYPE_MEM = 3
TYPE_PAD = 4

memory_labels = {}

operations_dict = {
    # No operands
    'NOOP': [TYPE_PAD],

    # Conditional Jumps
    'JE': [TYPE_REG, TYPE_REG, TYPE_MEM],
    'JNE': [TYPE_REG, TYPE_REG, TYPE_MEM],
    'JL': [TYPE_REG, TYPE_REG, TYPE_MEM],
    'JG': [TYPE_REG, TYPE_REG, TYPE_MEM],
    'JGE': [TYPE_REG, TYPE_REG, TYPE_MEM],
    'JLE': [TYPE_REG, TYPE_REG, TYPE_MEM],

    # Data Transfer
    'MOV': [TYPE_REG, TYPE_REG, TYPE_PAD],
    'LDS': [TYPE_REG, TYPE_PAD, TYPE_MEM],
    'LDU': [TYPE_REG, TYPE_PAD, TYPE_MEM],
    'LDW': [TYPE_REG, TYPE_PAD, TYPE_MEM],
    'LDI': [TYPE_REG, TYPE_PAD, TYPE_IMM],
    'STOREW': [TYPE_REG, TYPE_PAD, TYPE_MEM],
    'STOREB': [TYPE_REG, TYPE_PAD, TYPE_MEM],

    # Unconditional Jump
    'JUMP': [TYPE_REG, TYPE_PAD],

    # Arithmetic & Logic
    'ADD': [TYPE_REG, TYPE_REG, TYPE_PAD],
    'SUB': [TYPE_REG, TYPE_REG, TYPE_PAD],
    'AND': [TYPE_REG, TYPE_REG, TYPE_PAD],
    'OR': [TYPE_REG, TYPE_REG, TYPE_PAD],
    'XOR': [TYPE_REG, TYPE_REG, TYPE_PAD],
    'SHL': [TYPE_REG, TYPE_REG, TYPE_PAD],
    'SHR': [TYPE_REG, TYPE_REG, TYPE_PAD],
    'SAR': [TYPE_REG, TYPE_REG, TYPE_PAD],
    'ROL': [TYPE_REG, TYPE_REG, TYPE_PAD],
    'ROR': [TYPE_REG, TYPE_REG, TYPE_PAD],
    'NEG': [TYPE_REG, TYPE_REG, TYPE_PAD],

    # Multiplication
    'MUL': [TYPE_REG, TYPE_REG, TYPE_REG, TYPE_PAD],
    'IMUL': [TYPE_REG, TYPE_REG, TYPE_REG, TYPE_PAD],

    # Division
    'DIV': [TYPE_REG, TYPE_REG, TYPE_REG, TYPE_PAD],
    'IDIV': [TYPE_REG, TYPE_REG, TYPE_REG, TYPE_PAD],

    # Register memory addressing
    'RLDS': [TYPE_REG, TYPE_REG, TYPE_PAD],
    'RLDU': [TYPE_REG, TYPE_REG, TYPE_PAD],
    'RLDW': [TYPE_REG, TYPE_REG, TYPE_PAD],
    'RSTOREW': [TYPE_REG, TYPE_REG, TYPE_PAD],
    'RSTOREB': [TYPE_REG, TYPE_REG, TYPE_PAD],

    'ISET' : [TYPE_PAD],
    'ICLR' : [TYPE_PAD],
    'IRET' : [TYPE_PAD]
}

def bitstring_to_hex(bitstring: str) -> str:

    if not isinstance(bitstring, str):
        raise TypeError("Input must be a string.")
    if len(bitstring) != 32:
        raise ValueError("Input bitstring must be exactly 32 bits long.")
    if not all(c in '01' for c in bitstring):
        raise ValueError("Input bitstring must contain only '0' or '1' characters.")

    decimal_value = int(bitstring, 2)
    hex_value = hex(decimal_value)
    return hex_value

def is_int(str_val):
    try:
        a = int(str_val)
        return 1
    except ValueError:
        return 0


def to_bin_string(value, size):
    return f"{value:0{size}b}"

def raise_error(linecounter):
    print(f"ERROR has occured in line {linecounter}")
    raise ValueError


def tokenise_line(line):
    if ';' in line:
        return []

    line = line.replace(',', ' ')

    tokens = line.split()

    return tokens

def assert_is_reg(token):
    if token[0] != 'R':
        print("Invalid register! : ", token)
        raise SyntaxError
    if token[1:].isdigit():
        digit = int(token[1:])
        if digit > 31:
            print("Invalid register! : ", token)
            raise SyntaxError


potential_invalid_labels = []

def assert_is_mem(token):
    global potential_invalid_labels

    immediate = -1
    try:
        immediate = int(token, 0)
    except ValueError:
        pass

    if not token.isdigit() and immediate == -1 and token not in memory_labels.keys():
        potential_invalid_labels.append(token)
        print("Ok")

def assert_is_immediate(token):
    immediate = 0
    try:
        immediate = int(token, 0)
    except ValueError:
        print("Not a valid immediate: ", token)

def assert_is_pad(token):
    if token != '':
        print("Invalid pad! : ", token)
        raise SyntaxError

def assert_correct_size(tokens, opcode):
    size = 0
    for token_type in operations_dict[opcode]:
        if token_type != TYPE_PAD:
            size += 1
    
    if len(tokens) != size + 1:
        print("Error size! ", tokens, size)
        raise SyntaxError
    

def validate_opcode_tokens(tokens):
    try:
        # Checking opcode and number of tokens
        opcode = tokens[0]
        if opcode not in operations_dict.keys():
            print("Invalid opcode! : ", opcode)
            raise SyntaxError

        assert_correct_size(tokens, opcode)


        types = operations_dict[opcode]

        # Checking if each token is of correct type
        x = 0
        for type_num in types:
            x += 1
            if x > len(tokens):
                continue
            token = tokens[x]

            if type_num == TYPE_PAD:
                x -= 1
                print("type pad")
                continue
            elif type_num == TYPE_REG:
                print("type reg", token)
                assert_is_reg(token)
            elif type_num == TYPE_MEM:
                print("type mem", token)
                assert_is_mem(token)
            elif type_num == TYPE_IMM:
                print("type imm", token)
                assert_is_immediate(token)

        
    except IndexError:
        print("Index error!")


    


def assert_variable_declaration_size(tokens):
    if len(tokens) != 3:
        print("Invalid variable declaration! :", tokens)
        raise SyntaxError

    if not tokens[2].isdigit():
        print("Invalid variable declaration! :", tokens)
        raise SyntaxError

    if tokens[0] in memory_labels.keys():
        print("Variable redeclaration! :", tokens)
        raise SyntaxError



def add_label(tokens, program_counter, memory_counter):
    global memory_labels
    if "var" in tokens[0].lower():
        memory_labels[tokens[1].lower()] = memory_counter
        return (int(tokens[2]), True)
    elif ":" == tokens[0][-1]:
        label_name = tokens[0].lower().rstrip(':')
        memory_labels[tokens[0].lower().rstrip(":")] = program_counter
        return (1, False)

    print("Error: ", tokens)
    raise SyntaxError

    

def is_label(tokens):
    for token in tokens:
        if "var" in token.lower():
            assert_variable_declaration_size(tokens)
            return True

        if ":" == token[-1].rstrip():
            label_name = tokens[-1].lower()
            if len(tokens) > 1:
                print("Invalid label declaration! :", tokens)
                raise SyntaxError
            elif label_name in memory_labels.keys():
                print("Label redeclaration! :", tokens)
            else:
                return True

    return False
    


OPCODE_LENGTH = 6
REGCODE_LENGTH = 5
LITERAL_LENGHT = 16
OPERATION_SIZE = 32


binstring_array = []

def main(file_name, start_line = 0):
    global memory_labels
    global binstring_array
    ## Check whether file exitst
    try:
        with open(file_name, 'r') as f:
            pass
    except FileNotFoundError:
        print("File not found: " + file_name)
        return
    
    

    with open(file_name, 'r') as f:
        lines = f.readlines()
        memory_counter = 0
        program_counter = 0 
        for line in lines:
            tokens = tokenise_line(line)
            print(tokens, "ens")
            # Label and variable validation and introduction into memory labels
            if is_label(tokens):
                print("LABEL: ", tokens)
                # result[0] - increment    result[1] - is variable
                result = add_label(tokens, program_counter, memory_counter)

                if result[1]:
                    memory_counter += result[0]

                
            # Operation line validation
            else:
                if len(tokens) != 0:
                    validate_opcode_tokens(tokens)
                    program_counter += 1

        for potential_invalid in potential_invalid_labels:
            if potential_invalid not in memory_labels:
                print("Invalid memory address! : ", potential_invalid,"----", memory_labels.keys())
                raise SyntaxError

        print("-------------")
        with open("rom.hex", "w") as fw:
            for line in lines:

                for memory_label in memory_labels:
                    if memory_label in line.split():
                        # Replace labels with addresses
                        line = line.replace(memory_label, str(memory_labels[memory_label] + start_line))

                # Tokenise
                tokens = tokenise_line(line)
                if len(tokens) > 0:
                    length = 0

                    # Only process opcodes
                    if tokens[0] in operations_dict.keys():
                        opcode = tokens[0]
                        bitstring = ""
                        length = 6
                        bitstring += opcodes[opcode]
                        types = operations_dict[opcode]
                        
                        x = 0
                        for type_num in types:
                            x += 1
                            print(x, tokens)
                            if x >= len(tokens):
                                break
                            token = tokens[x]

                            if type_num == TYPE_PAD:
                                x -= 1
                                bitstring += 'X'
                                print("type pad")
                            elif type_num == TYPE_REG:
                                length += REGCODE_LENGTH
                                register_name = token
                                register_number = int(register_name.lstrip('R'))
                                bitstring += to_bin_string(register_number, REGCODE_LENGTH)
                                print("type reg", token)
                            elif type_num == TYPE_MEM:
                                length += LITERAL_LENGHT
                                bitstring += to_bin_string(int(token, 0), LITERAL_LENGHT)
                                print("type mem", token)
                            elif type_num == TYPE_IMM:
                                length += LITERAL_LENGHT
                                bitstring += to_bin_string(int(token, 0), LITERAL_LENGHT)
                                print("type imm", token)
                            
                        #  MAX 1 X allowed
                        bits_missing = OPERATION_SIZE - length
                        if 'X' in bitstring:
                            
                            parts = bitstring.split('X')
                            bitstring = parts[0]
                            for i in range(bits_missing):
                                bitstring += '0'
                            bitstring += parts[1]
                        elif bits_missing > 0:
                            for i in range(bits_missing):
                                bitstring += '0'
                        
                        print(bitstring, len(bitstring))
                        binstring_array.append(bitstring)
                        fw.write(bitstring_to_hex(bitstring)[2:] + '\n')

    with open("rom.hex", "r") as f:
        i = start_line
        with open("vhdl_rom.hex", "w") as fw:
            lines = f.readlines()
            
            for line in lines:
                #print(line)
                while len(line) < 9:
                    line = "0" + line
                write_line = str(i) + " => x\"" + line.strip() + "\",\n"
                fw.write(write_line)
                i += 1

    



if __name__ == "__main__":
    if len(sys.argv) > 1:
        if len(sys.argv) > 2:
            main(sys.argv[1], int(sys.argv[2]))
        else:
            main(sys.argv[1])
    else:
        print("Provide the code file name")

    for binstring in binstring_array:
        print(binstring)