## Microcode Control Word

The control unit utilizes a 33-bit horizontal microcode word driving all datapath enables, mux selectors, and segment control registers:

| Bit Range | Signal | Width | Description |
| :--- | :--- | :--- | :--- |
| `0` | `IRESET` | 1 | Internal reset |
| `1` | `PCWE` | 1 | Program Counter Write Enable |
| `2:3` | `ADRSEL` | 2 | Address bus source select |
| `4` | `SEGSEL` | 1 | Segment register select (CS / DS) |
| `5` | `BSSEL` | 1 | Byte / Word select |
| `6` | `ARWE` | 1 | Address Register Write Enable |
| `7` | `RAMW` | 1 | Memory write strobe |
| `8` | `IRWE` | 1 | Instruction Register Write Enable |
| `9` | `DRWE` | 1 | Data Register Write Enable |
| `10:11`| `MEMSSEL` | 2 | Memory source select mux |
| `12:13`| `RWSEL` | 2 | Register write data select mux |
| `14` | `RWE` | 1 | Register File Write Enable |
| `15` | `XYWE` | 1 | Temporary operand latch enable |
| `16:17`| `XSEL` | 2 | ALU Operand A select mux |
| `18:19`| `YSEL` | 2 | ALU Operand B select mux |
| `20:23`| `ALUM` | 4 | ALU operation mode select |
| `24` | `ALUWE` | 1 | ALU output register write enable |
| `25:26`| `PCSEL` | 2 | Next PC source select mux |
| `27` | `CSWE` | 1 | Code Segment register write enable |
| `28` | `DSWE` | 1 | Data Segment register write enable |
| `29` | `DSEL` | 1 | Destination register select |
| `30` | `IFWE` | 1 | Interrupt Flag Write Enable (internal signal in C. U.) |
| `31` | `PCIWE` | 1 | Saved PC latch enable (interrupt entry) |
| `32` | `IRETSEL`| 1 | Interrupt return multiplexer select |
