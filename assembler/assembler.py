import sys

from lib.constant import operations_dict, opcodes, TYPE_IMM, TYPE_MEM, TYPE_PAD, TYPE_REG
from lib.utils import bitstring_to_hex, to_bin_string, tokenise_line

memory_labels = {}



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

    try:
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
    except FileNotFoundError:
        print("File not found: " + file_name)
        return
    



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