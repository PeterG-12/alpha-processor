import sys

opcodes = {'NOOP': '000000', 'JE': '000001', 'JNE': '000010', 'JL': '000011', 'JG': '000100', 'JGE': '000101', 'JLE': '000110', 'MOV': '000111', 'LDS': '001000', 'LDU': '001001', 'LDW': '001010', 'LDI': '001011', 'STOREW': '001100', 'STOREB': '001101', 'JUMP': '001110', 'ADD': '001111', 'SUB': '010000', 'AND': '010001', 'OR': '010010', 'XOR': '010011', 'SHL': '010100', 'SHR': '010101', 'SAR': '010110', 'ROL': '010111', 'ROR': '011000', 'NEG': '011001', 'MUL': '011010', 'IMUL': '011011', 'DIV': '011100', 'IDIV': '011101'}


operations_dict = {
    # No operands
    'NOOP': ["00000000000000000000000000"],

    # Conditional Jumps
    'JE': ["REG00", "REG00", "MEM0000000000000"],
    'JNE': ["REG00", "REG00", "MEM0000000000000"],
    'JL': ["REG00", "REG00", "MEM0000000000000"],
    'JG': ["REG00", "REG00", "MEM0000000000000"],
    'JGE': ["REG00", "REG00", "MEM0000000000000"],
    'JLE': ["REG00", "REG00", "MEM0000000000000"],

    # Data Transfer
    'MOV': ["REG00", "REG00", "0000000000000000"],
    'LDS': ["REG00", "00000", "MEM0000000000000"],
    'LDU': ["REG00", "00000", "MEM0000000000000"],
    'LDW': ["REG00", "00000", "MEM0000000000000"],
    'LDI': ["REG00", "00000", "IMM0000000000000"],
    'STOREW': ["REG00", "00000", "MEM0000000000000"],
    'STOREB': ["REG00", "00000", "MEM0000000000000"],

    # Unconditional Jump
    'JUMP': ["REG00", "000000000000000000000"],

    # Arithmetic & Logic
    'ADD': ["REG00", "REG00", "0000000000000000"],
    'SUB': ["REG00", "REG00", "0000000000000000"],
    'AND': ["REG00", "REG00", "0000000000000000"],
    'OR': ["REG00", "REG00", "0000000000000000"],
    'XOR': ["REG00", "REG00", "0000000000000000"],
    'SHL': ["REG00", "REG00", "0000000000000000"],
    'SHR': ["REG00", "REG00", "0000000000000000"],
    'SAR': ["REG00", "REG00", "0000000000000000"],
    'ROL': ["REG00", "REG00", "0000000000000000"],
    'ROR': ["REG00", "REG00", "0000000000000000"],
    'NEG': ["REG00", "REG00", "0000000000000000"],

    # Multiplication
    'MUL': ["REG00", "REG00", "REG00", "00000000000"],
    'IMUL': ["REG00", "REG00", "REG00", "00000000000"],

    # Division
    'DIV': ["REG00", "REG00", "REG00", "00000000000"],
    'IDIV': ["REG00", "REG00", "REG00", "00000000000"]
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

def main(file_name):
    program_hex_code = ""
    labels = dict()
    with open(file_name, 'r') as f:
        linecounter = 0
        for line in f.readlines():
            if ":" in line:
                label = line.strip('\n').strip(":")
                labels[label] = str(linecounter)
            linecounter += 1

    with open(file_name, 'r') as f:
        with open("pre" + file_name, 'w') as fw:
            for line in f.readlines():
                for label in labels.keys():
                    if label in line:
                        line = line.replace(label, labels[label])
                #print(line)
                if not ":" in line:
                    fw.write(line)

                

    with open("pre" + file_name, 'r') as f:
        linecounter = 0


        for line in f.readlines():
            
            current_bin = ""

            tokens = line.split(' ')
            tokens[-1] = tokens[-1].strip()
            

            opcode = tokens[0]

            if opcode not in opcodes.keys():
                raise_error(linecounter)


            current_bin += opcodes[opcode]

            x = 1

            for i in range(0, len(operations_dict[opcode])):   
                

                token_presumed = operations_dict[opcode][i]
                token_presumed_len = len(token_presumed)

                print("Token", token_presumed)

                #print("Presumed len token", token_presumed_len)

                if "REG" in token_presumed:
                    reg_num = int(tokens[x][1:])

                    if reg_num > 31:
                        raise_error(linecounter)

                    current_bin += to_bin_string(reg_num, token_presumed_len)
                    x+= 1
                elif "MEM" in token_presumed:
                    mem_val = int(tokens[x])
                    current_bin += to_bin_string(mem_val, token_presumed_len)
                    x+= 1
                elif "IMM" in token_presumed:
                    imm_val = int(tokens[x])
                    current_bin += to_bin_string(imm_val, token_presumed_len)
                    x+= 1
                else:
                    current_bin += to_bin_string(0, token_presumed_len)

            
            linecounter += 1
            print(current_bin)
            program_hex_code += bitstring_to_hex(current_bin) + '\n'
    
    print(program_hex_code)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        main(sys.argv[1])
    else:
        print("Provide the code file name")