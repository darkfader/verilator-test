#
# brew reinstall --build-from-source gdk-pixbuf
# make SHELL='sh -x' obj_dir/Vabc__ALL.a

# CFLAGS += -DBLAAT

VFLAGS += --default-language 1800-2012
VFLAGS += --bbox-sys --bbox-unsup
VFLAGS += -Wall
VFLAGS += --trace --assert
VFLAGS += -O2

# VFLAGS += -CFLAGS $(CFLAGS)
VFLAGS += -DBLAAT

#TOPMODULE = our
#TOPMODULE = abc

GTKW = gtkwave.gtkw


# V_SRCS = abc.v


## This must point to the root of the VERILATOR kit
# VERILATOR_ROOT := $(shell pwd)/..
# export VERILATOR_ROOT

# Pick up PERL and other variable settings
# include $(VERILATOR_ROOT)/include/verilated.mk


#sim_main: sim_main.cpp
#	# g++ -o sim_main sim_main.cpp -I obj_dir -I /usr/local/share/verilator/include -I /usr/local/share/verilator/include/vltstd obj_dir/Vour__ALL.a $(wildcard /usr/local/share/verilator/include/*.cpp)
#	verilator $(VFLAGS) --exe -o sim_main sim_main.o obj_dir/Vour__ALL.a


# Note the --public --output-split-cfunc is here for testing only,
# Avoid using these settings in real application Makefiles!
# VERILATOR_FLAGS = --public --output-split-cfuncs 1000 --output-split 1000 --sp --coverage --stats --trace $(VFLAGS) top.v
VERILATOR_FLAGS = --public --coverage --stats --trace $(VFLAGS)

VERILATOR_ROOT ?= /usr/local/share/verilator

.SHELLFLAGS = -o pipefail -c

.PHONY: run
run: obj_dir/sim_main     # obj_dir/V$(TOPMODULE)
	-killall gtkwave-bin 2>/dev/null
	gtimeout 10.0 $< | grep -a -F -e '' -e 'Error' | head -c 1000000
	# ( for i in 1 2 3; do sleep 0.5; osascript -e 'tell application "gtkwave" to activate' 2>/dev/null; done ) &
	( for i in 1 2 3; do sleep 0.5; open -a gtkwave 2>/dev/null; done ) &
	cat vlt_dump.vcd | "/Applications/gtkwave.app/Contents/MacOS/gtkwave-bin" -v $(GTKW) 2>/dev/null &

.PHONY: clean
clean:
	-rm -rf obj_dir

abc.v: sine.bin

# top.v: cpu.v sb_spram256ka.v

sb_spram256ka.v: spram.bin

sine.bin: sine
	./$< > $@

spram.bin: spram
	./$< > $@

sine: sine.c

obj_dir/V%__ALL.a: obj_dir/V%.mk obj_dir/V%.cpp
	make -C obj_dir -f $(notdir $<)

obj_dir/V%.mk obj_dir/V%.cpp obj_dir/V%.h: %.v cpu.v sb_spram256ka.v
	verilator $(VERILATOR_FLAGS) --cc $<

# obj_dir/sim_main: obj_dir/sim_main.o obj_dir/Vabc__ALL.a obj_dir/verilated.o obj_dir/verilated_cov.o obj_dir/verilated_vcd_c.o
obj_dir/sim_main: obj_dir/sim_main.o obj_dir/Vtop__ALL.a obj_dir/verilated.o obj_dir/verilated_cov.o obj_dir/verilated_vcd_c.o
	g++ -o $@ $+

obj_dir/sim_main.o: sim_main.cpp obj_dir
	g++ -c -I obj_dir -I $(VERILATOR_ROOT)/include -DVM_TRACE -o $@ $<

# sim_main.cpp: obj_dir/Vabc.h
sim_main.cpp: obj_dir/Vtop.h

obj_dir/verilated.o: $(VERILATOR_ROOT)/include/verilated.cpp
	g++ -c -o $@ $+

obj_dir/verilated_cov.o: $(VERILATOR_ROOT)/include/verilated_cov.cpp
	g++ -c -o $@ $+

obj_dir/verilated_vcd_c.o: $(VERILATOR_ROOT)/include/verilated_vcd_c.cpp
	g++ -c -o $@ $+

obj_dir:
	mkdir -p $@
