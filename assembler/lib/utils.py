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