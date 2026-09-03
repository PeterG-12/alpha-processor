# Custom ISA Reference

This processor uses fixed 32-bit instructions running on a 16-bit multi-cycle datapath. It has 32 general-purpose registers (`R0`–`R31`), and is micro-programmed with instruction latencies ranging between 3 to 5 clock cycles.

---

## Instruction Encoding Formats

Every instruction is exactly 32 bits wide and begins with a 6-bit opcode. Unused bits are padded with zeros by the assembler.

```text
1. 2-Register / ALU / MOV / Segment:
   [31:26] Opcode (6) | [25:21] Reg1 (5) | [20:16] Reg2 (5) | [15:0] Unused (16)

2. 3-Register / Multiply & Divide:
   [31:26] Opcode (6) | [25:21] Reg1 (5) | [20:16] Reg2 (5) | [15:11] Reg3 (5) | [10:0] Unused (11)

3. Immediate / Direct Memory:
   [31:26] Opcode (6) | [25:21] Reg1 (5) | [20:16] Unused (5) | [15:0] Immediate / Address (16)

4. Conditional Branch:
   [31:26] Opcode (6) | [25:21] Reg1 (5) | [20:16] Reg2 (5) | [15:0] Target Address (16)

5. Register Jump / Single Register:
   [31:26] Opcode (6) | [25:21] Reg1 (5) | [20:0] Unused (21)

6. System / No Operand:
   [31:26] Opcode (6) | [25:0] Unused (26)

```

---

## 1. Arithmetic & Logic Unit (ALU)

Standard ALU instructions operate directly on registers (`R1 = R1 op R2`). All basic ALU operations take **4 cycles** (`Fetch -> Decode -> ARIT_execute -> REG_wback`).

| Mnemonic | Opcode | Syntax | Cycles | Operation / Notes |
| --- | --- | --- | --- | --- |
| `ADD` | `001111` | `ADD R1, R2` | 4 | `R1 = R1 + R2` |
| `SUB` | `010000` | `SUB R1, R2` | 4 | `R1 = R1 - R2` |
| `AND` | `010001` | `AND R1, R2` | 4 | `R1 = R1 & R2` |
| `OR` | `010010` | `OR R1, R2` | 4 | `R1 = R1 | R2` |
| `XOR` | `010011` | `XOR R1, R2` | 4 | `R1 = R1 ^ R2` |
| `SHL` | `010100` | `SHL R1, R2` | 4 | Logical shift left |
| `SHR` | `010101` | `SHR R1, R2` | 4 | Logical shift right |
| `SAR` | `010110` | `SAR R1, R2` | 4 | Arithmetic shift right (preserves sign) |
| `ROL` | `010111` | `ROL R1, R2` | 4 | Rotate left |
| `ROR` | `011000` | `ROR R1, R2` | 4 | Rotate right |
| `NEG` | `011001` | `NEG R1, R2` | 4 | Two's complement negation |

---

## 2. Multiplication & Hardware Division

Multiplication and division take 3 register operands and require **5 cycles** (`Fetch -> Decode -> Exec -> REGS1_wback -> REGS2_wback`). The result is split across two destination registers.

| Mnemonic | Opcode | Syntax | Cycles | Result Layout |
| --- | --- | --- | --- | --- |
| `MUL` | `011010` | `MUL R1, R2, R3` | 5 | Unsigned: `R1` = Low 16 bits, `R3` = High 16 bits |
| `IMUL` | `011011` | `IMUL R1, R2, R3` | 5 | Signed: `R1` = Low 16 bits, `R3` = High 16 bits |
| `DIV` | `011100` | `DIV R1, R2, R3` | 5 | Unsigned: `R1 = R1 / R2` (Quotient), `R3` = Remainder |
| `IDIV` | `011101` | `IDIV R1, R2, R3` | 5 | Signed: `R1 = R1 / R2` (Quotient), `R3` = Remainder |

---

## 3. Data Transfer & Memory

### Direct Addressing (16-bit Immediate or Memory Address)

Direct loads take **5 cycles** (`Fetch -> Decode -> LD_read -> LD_intermed -> LD_wback`). Direct stores take **4 cycles** (`Fetch -> Decode -> STORE_execute -> STORE_write`).

| Mnemonic | Opcode | Syntax | Cycles | Description |
| --- | --- | --- | --- | --- |
| `LDI` | `001011` | `LDI R1, imm16` | 3 | Load 16-bit immediate constant into `R1` |
| `LDW` | `001010` | `LDW R1, addr` | 5 | Load 16-bit word from memory address |
| `LDU` | `001001` | `LDU R1, addr` | 5 | Load byte from memory, zero extended |
| `LDS` | `001000` | `LDS R1, addr` | 5 | Load byte from memory, sign extended |
| `STOREW` | `001100` | `STOREW R1, addr` | 4 | Store 16-bit word from `R1` into memory address |
| `STOREB` | `001101` | `STOREB R1, addr` | 4 | Store low byte of `R1` into memory address |

### Register-Indirect Addressing (Pointers) & Register Copy

Pointer loads take **5 cycles** (`Fetch -> Decode -> RLD_read -> LD_intermed -> LD_wback`). Pointer stores take **4 cycles** (`Fetch -> Decode -> STORE_execute -> RSTORE_write`).

| Mnemonic | Opcode | Syntax | Cycles | Description |
| --- | --- | --- | --- | --- |
| `MOV` | `000111` | `MOV R1, R2` | 4 | Copy value from `R2` into `R1` |
| `RLDW` | `100010` | `RLDW R1, R2` | 5 | Load 16-bit word using address in `R2` |
| `RLDU` | `100001` | `RLDU R1, R2` | 5 | Load byte using pointer in `R2`, zero extended |
| `RLDS` | `100000` | `RLDS R1, R2` | 5 | Load byte using pointer in `R2`, sign extended |
| `RSTOREW` | `100011` | `RSTOREW R1, R2` | 4 | Store word in `R1` to address in `R2` |
| `RSTOREB` | `100100` | `RSTOREB R1, R2` | 4 | Store low byte of `R1` to address in `R2` |

---

## 4. Control Flow & Jumps

Conditional jumps take **4 cycles** (`Fetch -> Decode -> JCOND_execute -> JCOND_wback`) and compare `R1` against `R2`. Unconditional jump takes **4 cycles** (`Fetch -> Decode -> JUMP_execute -> JUMP_wback`) and jumps to the address in the register.

| Mnemonic | Opcode | Syntax | Cycles | Condition |
| --- | --- | --- | --- | --- |
| `JUMP` | `001110` | `JUMP R1` | 4 | Unconditional jump to address in `R1` |
| `JE` | `000001` | `JE R1, R2, addr` | 4 | Jump if `R1 == R2` |
| `JNE` | `000010` | `JNE R1, R2, addr` | 4 | Jump if `R1 != R2` |
| `JL` | `000011` | `JL R1, R2, addr` | 4 | Jump if `R1 < R2` |
| `JG` | `000100` | `JG R1, R2, addr` | 4 | Jump if `R1 > R2` |
| `JGE` | `000101` | `JGE R1, R2, addr` | 4 | Jump if `R1 >= R2` |
| `JLE` | `000110` | `JLE R1, R2, addr` | 4 | Jump if `R1 <= R2` |

---

## 5. Segment Registers, Interrupts & Control

| Mnemonic | Opcode | Syntax | Cycles | Description |
| --- | --- | --- | --- | --- |
| `ISET` | `100101` | `ISET` | 3 | Enable hardware interrupts |
| `ICLR` | `100110` | `ICLR` | 3 | Disable hardware interrupts |
| `IRET` | `100111` | `IRET` | 4 | Return from interrupt (restores PC, disables interrupt state) |
| `NOOP` | `000000` | `NOOP` | 3 | No operation |
