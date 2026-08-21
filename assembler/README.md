# Logisim implementation of custom ISA processor

Custom 16-bit RISC processor inspired by RISC-V, MIPS and 8086 ideas with simplistic hardware interrupt system and GPIO registers implemented in Logisim-evolution. The project is great for interactively visualize the internal working of the CPU core.


## Technical details

1. Micro-programmed multi-cycle integer core
  - Register-register ALU operations
  - Load-store memory interfacing
  - Hardware Divider
  - Conditional and unconditional jumps
2. Memory mapped GPIO
  - Potential for 32 GPIOs
3. Interrupt system
  - Interrupt PC holder, enables 1 layered interrupts
  - Interrupt system can be enabled and disabled in code
  - Implementation for both external (e.g. emergency button) interrupt and timer interrupt

![Image of ISA operations](images/isa-image.png)
![Image of logisim implementation](images/logisim-image.png)
