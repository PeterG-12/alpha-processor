export PYTHONPATH := $(PWD)/..:$(PYTHONPATH)

# Simulator settings
SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl

EXTRA_ARGS += --std=08
COMPILE_ARGS += --std=08
EXTRA_ARGS += -Wno-hide

#Stub generation
# Python test module name (Runs Copra first, then your test)
COCOTB_TEST_MODULES = copra.integration.autostub,test_processor

VHDL_SOURCES += $(wildcard ../../rtl/*.vhd)
TOPLEVEL = main

#VHDL_SOURCES += $(PWD)/vhdl/*.vhd
# Top-level entity name

SIM_ARGS += --wave=wave.ghw
SIM_ARGS += --backtrace-severity=warning
SIM_ARGS += --ieee-asserts=disable-at-0
# Include cocotb make rules
include $(shell cocotb-config --makefiles)/Makefile.sim