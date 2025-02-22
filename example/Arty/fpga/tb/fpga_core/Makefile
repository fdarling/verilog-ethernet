# Copyright (c) 2020 Alex Forencich
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

TOPLEVEL_LANG = verilog

SIM ?= icarus
WAVES ?= 0

COCOTB_HDL_TIMEUNIT = 1ns
COCOTB_HDL_TIMEPRECISION = 1ps

DUT      = fpga_core
TOPLEVEL = $(DUT)
MODULE   = test_$(DUT)
VERILOG_SOURCES += ../../rtl/$(DUT).v
VERILOG_SOURCES += ../../lib/eth/rtl/eth_mac_mii_fifo.v
VERILOG_SOURCES += ../../lib/eth/rtl/eth_mac_mii.v
VERILOG_SOURCES += ../../lib/eth/rtl/ssio_sdr_in.v
VERILOG_SOURCES += ../../lib/eth/rtl/mii_phy_if.v
VERILOG_SOURCES += ../../lib/eth/rtl/eth_mac_1g.v
VERILOG_SOURCES += ../../lib/eth/rtl/axis_gmii_rx.v
VERILOG_SOURCES += ../../lib/eth/rtl/axis_gmii_tx.v
VERILOG_SOURCES += ../../lib/eth/rtl/lfsr.v
VERILOG_SOURCES += ../../lib/eth/rtl/hash_11_bits.v
VERILOG_SOURCES += ../../lib/eth/rtl/eth_axis_rx.v
VERILOG_SOURCES += ../../lib/eth/rtl/eth_axis_tx.v
VERILOG_SOURCES += ../../lib/eth/rtl/udp_complete.v
VERILOG_SOURCES += ../../lib/eth/rtl/udp_checksum_gen.v
VERILOG_SOURCES += ../../lib/eth/rtl/udp.v
VERILOG_SOURCES += ../../lib/eth/rtl/udp_ip_rx.v
VERILOG_SOURCES += ../../lib/eth/rtl/udp_ip_tx.v
VERILOG_SOURCES += ../../lib/eth/rtl/ip_complete.v
VERILOG_SOURCES += ../../lib/eth/rtl/ip.v
VERILOG_SOURCES += ../../lib/eth/rtl/ip_eth_rx.v
VERILOG_SOURCES += ../../lib/eth/rtl/ip_eth_tx.v
VERILOG_SOURCES += ../../lib/eth/rtl/ip_arb_mux.v
VERILOG_SOURCES += ../../lib/eth/rtl/arp.v
VERILOG_SOURCES += ../../lib/eth/rtl/arp_cache.v
VERILOG_SOURCES += ../../lib/eth/rtl/arp_eth_rx.v
VERILOG_SOURCES += ../../lib/eth/rtl/arp_eth_tx.v
VERILOG_SOURCES += ../../lib/eth/rtl/eth_arb_mux.v
VERILOG_SOURCES += ../../lib/eth/lib/axis/rtl/arbiter.v
VERILOG_SOURCES += ../../lib/eth/lib/axis/rtl/priority_encoder.v
VERILOG_SOURCES += ../../lib/eth/lib/axis/rtl/axis_fifo.v
VERILOG_SOURCES += ../../lib/eth/lib/axis/rtl/axis_async_fifo.v
VERILOG_SOURCES += ../../lib/eth/lib/axis/rtl/axis_async_fifo_adapter.v

# module parameters
#export PARAM_A ?= value

ifeq ($(SIM), icarus)
	PLUSARGS += -fst

#	COMPILE_ARGS += -P $(TOPLEVEL).A=$(PARAM_A)

	ifeq ($(WAVES), 1)
		VERILOG_SOURCES += iverilog_dump.v
		COMPILE_ARGS += -s iverilog_dump
	endif
else ifeq ($(SIM), verilator)
	COMPILE_ARGS += -Wno-SELRANGE -Wno-WIDTH

#	COMPILE_ARGS += -GA=$(PARAM_A)

	ifeq ($(WAVES), 1)
		COMPILE_ARGS += --trace-fst
	endif
endif

include $(shell cocotb-config --makefiles)/Makefile.sim

iverilog_dump.v:
	echo 'module iverilog_dump();' > $@
	echo 'initial begin' >> $@
	echo '    $$dumpfile("$(TOPLEVEL).fst");' >> $@
	echo '    $$dumpvars(0, $(TOPLEVEL));' >> $@
	echo 'end' >> $@
	echo 'endmodule' >> $@

clean::
	@rm -rf iverilog_dump.v
	@rm -rf dump.fst $(TOPLEVEL).fst
