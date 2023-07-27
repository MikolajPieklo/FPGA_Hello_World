BOARD=tangnano9k
FAMILY=GW1N-9C
DEVICE=GW1NR-LV9QN88PC6/I5

OUT_DIR          := out

all: make$(OUT_DIR) $(OUT_DIR)/counter.fs

make$(OUT_DIR):	
	@if [ ! -e $(OUT_DIR) ]; then mkdir $(OUT_DIR); fi

# Synthesis
$(OUT_DIR)/counter.json: counter.v
	yosys -p "read_verilog counter.v; synth_gowin -top counter -json $(OUT_DIR)/counter.json"

# Place and Route
$(OUT_DIR)/counter_pnr.json: $(OUT_DIR)/counter.json
	nextpnr-gowin --json $(OUT_DIR)/counter.json --freq 27 --write $(OUT_DIR)/counter_pnr.json --device ${DEVICE} --family ${FAMILY} --cst ${BOARD}.cst

# Generate Bitstream
$(OUT_DIR)/counter.fs: $(OUT_DIR)/counter_pnr.json
	gowin_pack -d ${FAMILY} -o $(OUT_DIR)/counter.fs $(OUT_DIR)/counter_pnr.json

# Program Board
load:
	openFPGALoader -b ${BOARD} -v $(OUT_DIR)/counter.fs
	
clean:
	rm -rf out
	
.PHONY: load clean
#.INTERMEDIATE: counter_pnr.json counter.json
