import string
import cocotb
from cocotb.handle import ArrayObject
from cocotb.triggers import Timer, Edge, with_timeout
from cocotb.clock import Clock
from random import randint
import logging
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    import copra_stubs

async def generate_clock(dut : copra_stubs.Main):
    c = Clock(dut.clk_extrn, 10, "ns")
    c.start()

async def load_word(dut : copra_stubs.Main, address, word):
    dut.rom_inst.sim_we.value = 1
    dut.rom_inst.sim_data.value = word
    dut.rom_inst.sim_addr.value = address
    await Timer(1, unit="ps")
    dut.rom_inst.sim_we.value = 0




async def load_program(dut : copra_stubs.Main, file_name : str):
    await load_word(dut, 0, 0x123545)
    await load_word(dut, 1, 0x543132)

    with open(file_name) as f:
        for line in f.readlines():
            line_split = line.split("=>")
            index = line_split[0].strip()
            hex_val = line_split[1].strip().lstrip("x").rstrip(",").strip("\"")
            await load_word(dut ,int(index), int(hex_val, 16))

    ro_memory = dut.rom_inst.internal_memory

    """
    for i in range(len(ro_memory)):
        hexval = hex(ro_memory[i].value)
        if hexval != "0x0":
            print(i, hexval)
    """
    
@cocotb.test()
async def test_0(dut : copra_stubs.Main):
    logger = cocotb.log
    logger.setLevel(logging.INFO)
    
    KAT_dictionary = dict()
    count = 0

    clock_task = cocotb.start_soon(generate_clock(dut))
    dut.reset.value = 1
    await Timer(50, unit="ns")
    dut.reset.value = 0
    await load_program(dut, "test_programs/test0.hex")

    await Timer(500, unit="ns")
    clock_task.cancel()

@cocotb.test()
async def test_1(dut : copra_stubs.Main):
    logger = cocotb.log
    logger.setLevel(logging.INFO)
    
    KAT_dictionary = dict()
    count = 0

    clock_task = cocotb.start_soon(generate_clock(dut))
    dut.reset.value = 1
    await Timer(50, unit="ns")
    dut.reset.value = 0
    await load_program(dut, "test_programs/test1.hex")

    await Timer(1000, unit="ns")
    assert dut.register_holder_inst[f"registers({1})"].register_i.output.value == 0x600d, "Incorrect result"

    clock_task.cancel()

@cocotb.test()
async def test_2(dut : copra_stubs.Main):
    logger = cocotb.log
    logger.setLevel(logging.INFO)
    
    KAT_dictionary = dict()
    count = 0

    clock_task = cocotb.start_soon(generate_clock(dut))
    dut.reset.value = 1
    await Timer(50, unit="ns")
    dut.reset.value = 0
    await load_program(dut, "test_programs/test2.hex")

    await Timer(1000, unit="ns")
    assert dut.register_holder_inst[f"registers({1})"].register_i.output.value == 0x600d, "Incorrect result"

    clock_task.cancel()

@cocotb.test()
async def test_3(dut : copra_stubs.Main):
    logger = cocotb.log
    logger.setLevel(logging.INFO)
    
    KAT_dictionary = dict()
    count = 0

    clock_task = cocotb.start_soon(generate_clock(dut))
    dut.reset.value = 1
    await Timer(50, unit="ns")
    dut.reset.value = 0
    await load_program(dut, "test_programs/test3.hex")

    await Timer(1000, unit="ns")
    assert dut.register_holder_inst[f"registers({1})"].register_i.output.value == 0x600d, "Incorrect result"

    clock_task.cancel()

@cocotb.test()
async def test_4(dut : copra_stubs.Main):
    logger = cocotb.log
    logger.setLevel(logging.INFO)
    
    KAT_dictionary = dict()
    count = 0

    clock_task = cocotb.start_soon(generate_clock(dut))
    dut.reset.value = 1
    await Timer(50, unit="ns")
    dut.reset.value = 0
    await load_program(dut, "test_programs/test4.hex")

    await Timer(1000, unit="ns")

    assert dut.register_holder_inst[f"registers({1})"].register_i.output.value == 0x600d, "Incorrect result"

    clock_task.cancel()

@cocotb.test()
async def test_5(dut : copra_stubs.Main):
    logger = cocotb.log
    logger.setLevel(logging.INFO)
    
    KAT_dictionary = dict()
    count = 0

    clock_task = cocotb.start_soon(generate_clock(dut))
    dut.reset.value = 1
    await Timer(50, unit="ns")
    dut.reset.value = 0
    await load_program(dut, "test_programs/test5.hex")

    await Timer(1000, unit="ns")

    assert dut.register_holder_inst[f"registers({1})"].register_i.output.value == 0x600d, "Incorrect result"

    clock_task.cancel()

@cocotb.test()
async def test_6(dut : copra_stubs.Main):
    logger = cocotb.log
    logger.setLevel(logging.INFO)
    
    KAT_dictionary = dict()
    count = 0

    clock_task = cocotb.start_soon(generate_clock(dut))
    dut.reset.value = 1
    await Timer(50, unit="ns")
    dut.reset.value = 0
    await load_program(dut, "test_programs/test6.hex")

    await Timer(1000, unit="ns")

    assert dut.register_holder_inst[f"registers({1})"].register_i.output.value == 0x600d, "Incorrect result"

    clock_task.cancel()