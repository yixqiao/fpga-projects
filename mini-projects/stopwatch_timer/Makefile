ifndef TB
$(error TB is required. Usage: make TB=tb_top)
endif

LIB = ../../lib
SRCS = $(LIB)/clk/*.sv $(LIB)/seg7/*.sv src/*.sv sim/$(TB).sv
VCD  = sim/$(TB).vcd

sim: $(VCD)

$(VCD): $(SRCS)
	iverilog -g2012 -o sim/$(TB).vvp $(SRCS)
	vvp sim/$(TB).vvp

wave: $(VCD)
	gtkwave $(VCD) &

clean:
	rm -f sim/*.vvp sim/*.vcd