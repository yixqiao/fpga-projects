SRC = src/top.sv src/counter.sv src/seg7_dec.sv sim/tb_top.sv
VCD = sim/tb_top.vcd

sim: $(VCD)

$(VCD): $(SRC)
	iverilog -g2012 -o sim/tb_top.vvp $(SRC)
	vvp sim/tb_top.vvp

wave: $(VCD)
	gtkwave $(VCD) &

clean:
	rm -f sim/tb_top.vvp sim/tb_top.vcd