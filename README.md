# VHDL implementation of custom ISA processor

Custom 16-bit RISC processor inspired by RISC-V, MIPS and 8086 ideas with simplistic hardware interrupt system and GPIO registers implemented in VHDL, deployed and demonstrated on Basys 3 board.

## Technical details

1. Micro-programmed multi-cycle integer core
  - Register-register ALU operations
  - Load-store memory interfacing
  - Hardware Divider
  - Conditional and unconditional jumps
2. Memory mapped devices
  - Potential for 32 GPIOs
3. Interrupt system
  - Interrupt PC holder, enables 1 layered interrupts
  - Interrupt system can be enabled and disabled in code
  - Implementation for both external (e.g. emergency button) interrupt and timer interrupt

  
## GPIO pins demo

                XX_RBW_RBW
Nothing:        10_000_000 = 0x08
Red:            10_100_100 = 0xA4
Blue:           10_010_010 = 0x92
White:          10_001_001 = 0x89
White and Blue: 10_011_011 = 0x9B


![GPIO demo](images/demo.gif)
