SOURCE_FILES = src/data_memory.sv src/imm_selector.sv src/instruction_memory.sv src/reg_write_addr_enb_decoder.sv src/register_file.sv src/testbench.sv src/top.sv

all: adaptive1 adaptive2 adaptive4 adaptive8 adaptive16 satcnt1 satcnt2 satcnt4 satcnt8 satcnt16

adaptive1:
	iverilog -g2012 -DADAPTIVE -DNUM_BITS=1 -o bin/adpt1.vvp $(SOURCE_FILES) src/adaptive_predictor.sv

adaptive2:
	iverilog -g2012 -DADAPTIVE -DNUM_BITS=2 -o bin/adpt2.vvp $(SOURCE_FILES) src/adaptive_predictor.sv

adaptive4:
	iverilog -g2012 -DADAPTIVE -DNUM_BITS=4 -o bin/adpt4.vvp $(SOURCE_FILES) src/adaptive_predictor.sv

adaptive8:
	iverilog -g2012 -DADAPTIVE -DNUM_BITS=8 -o bin/adpt8.vvp $(SOURCE_FILES) src/adaptive_predictor.sv

adaptive16:
	iverilog -g2012 -DADAPTIVE -DNUM_BITS=16 -o bin/adpt16.vvp $(SOURCE_FILES) src/adaptive_predictor.sv

satcnt1:
	iverilog -g2012 -DNUM_BITS=1 -o bin/scnt1.vvp $(SOURCE_FILES) src/sat_cnt.sv

satcnt2:
	iverilog -g2012 -DNUM_BITS=2 -o bin/scnt2.vvp $(SOURCE_FILES) src/sat_cnt.sv

satcnt4:
	iverilog -g2012 -DNUM_BITS=4 -o bin/scnt4.vvp $(SOURCE_FILES) src/sat_cnt.sv

satcnt8:
	iverilog -g2012 -DNUM_BITS=8 -o bin/scnt8.vvp $(SOURCE_FILES) src/sat_cnt.sv

satcnt16:
	iverilog -g2012 -DNUM_BITS=16 -o bin/scnt16.vvp $(SOURCE_FILES) src/sat_cnt.sv

clean:
	rm -f bin/*.vvp
