###################################################################
# 
# Lattice Yosys FPGA Makefile
# 
###################################################################
# 
# Parameters:
# FPGA_TOP - Top module name
# FPGA_FAMILY - FPGA family (e.g. VirtexUltrascale)
# FPGA_DEVICE - FPGA device (e.g. xcvu095-ffva2104-2-e)
# BOARD - Version of the Colorlight board, possible values
# pinout_v7(by default), pinout_v8
# SYN_FILES - space-separated list of source files
# 
# Example:
# 
# FPGA_TOP = fpga
# FPGA_FAMILY = ECP5
# FPGA_DEVICE = LFE5U-25F-6BG256C
# SYN_FILES = rtl/fpga.v
# TRELLIS = /usr/local/share/trellis
# include ../common/lattice.mk
# 
###################################################################

# phony targets
.PHONY: clean fpga

BOARD:=pinout_v7

SYN_FILES_REL = $(patsubst %, ../%, $(SYN_FILES))
FILES_TO_SCRIPT = $(patsubst %.sv, "-sv %.sv", $(SYN_FILES_REL))

###################################################################
# Main Targets
#
# all: build everything
# clean: remove output files
###################################################################

all: fpga

fpga: $(FPGA_TOP).bit

clean:
	rm -f *.svf *.bit *.config *.ys *.json *.log

###################################################################
# Target implementations
###################################################################

$(FPGA_TOP).json: $(FPGA_TOP).ys $(SYN_FILES_REL)
	yosys -q -l "Synth.log" $(FPGA_TOP).ys

$(FPGA_TOP).ys:
	echo "verilog_defaults -push" > $(FPGA_TOP).ys
	echo "verilog_defaults -add -defer" >> $(FPGA_TOP).ys
	for file in $(FILES_TO_SCRIPT); do \
		echo "read_verilog $$file" >> $(FPGA_TOP).ys; \
	done
	echo "verilog_defaults -pop" >> $(FPGA_TOP).ys
	echo "attrmap -tocase keep -imap keep="true" keep=1 -imap keep="false" keep=0 -remove keep=0" >> $(FPGA_TOP).ys
	echo "synth_ecp5 -top $(FPGA_TOP) -json $(FPGA_TOP).json -abc2" >> $(FPGA_TOP).ys

$(FPGA_TOP)_out.config: $(FPGA_TOP).json ../$(BOARD).lpf
	python3 ../common/place_and_route.py --25k --package CABGA381 --speed 6 --json $< --textcfg $@ --lpf ../$(BOARD).lpf --freq 166 --quiet --force --log PlaceAndRoute.log

$(FPGA_TOP).bit: $(FPGA_TOP)_out.config
	ecppack --svf ${FPGA_TOP}.svf $< $@

${FPGA_TOP}.svf : ${FPGA_TOP}.bit
