# Xilinx Build Automation script

# Change the Name of Project here!
PROJECT = uart
SRC     = /home/installation/xilinx/14.7/ISE_DS
XST     = $(SRC)/ISE/bin/lin64/


# Do Not Modify Anything BEyond this line!
PART	= xc3s50a-tq144-4
FORMAT  = verilog

UT_OPTS = -w -g DebugBitstream:No -g Binary:yes -g CRC:Enable -g Reset_on_err:No -g ConfigRate:25 -g ProgPin:PullUp -g DonePin:PullUp -g TckPin:PullUp -g TdiPin:PullUp -g TdoPin:PullUp -g TmsPin:PullUp -g UnusedPin:PullDown -g UserID:0xFFFFFFFF -g StartUpClk:CClk -g DONE_cycle:4 -g GTS_cycle:5 -g GWE_cycle:6 -g LCK_cycle:NoWait -g Security:None -g DonePipe:Yes -g DriveDone:No -g en_sw_gsr:No -g en_porb:Yes -g drive_awake:No -g sw_clk:Startupclk -g sw_gwe_cycle:5 -g sw_gts_cycle:4

XST_OPT = "run -ifn ./src/$(PROJECT).v -ifmt verilog -ofn $(PROJECT) -ofmt NGC -p $(PART) -top $(PROJECT) -opt_mode Speed -opt_level 1 -iuc NO -keep_hierarchy No -netlist_hierarchy As_Optimized -rtlview Yes -glob_opt AllClockNets -read_cores YES -write_timing_constraints NO -cross_clock_analysis NO -hierarchy_separator / -bus_delimiter <> -case Maintain -slice_utilization_ratio 100 -bram_utilization_ratio 100 -verilog2001 YES -fsm_extract YES -fsm_encoding Auto -safe_implementation No -fsm_style LUT -ram_extract Yes -ram_style Auto -rom_extract Yes -mux_style Auto -decoder_extract YES -priority_extract Yes -shreg_extract YES -shift_extract YES -xor_collapse YES -rom_style Auto -auto_bram_packing NO -mux_extract Yes -resource_sharing YES -async_to_sync NO -mult_style Auto -iobuf YES -max_fanout 100000 -bufg 24 -register_duplication YES -register_balancing No -slice_packing YES -optimize_primitives NO -use_clock_enable Yes -use_sync_set Yes -use_sync_reset Yes -iob Auto -equivalent_register_removal YES -slice_utilization_ratio_maxmargin 5"

all:  ./src/$(PROJECT).v ./src/$(PROJECT).ucf
	@echo "source $(SRC)/settings64.sh" | bash
	@echo $(XST_OPT) | $(XST)/xst 
	@$(XST)/ngdbuild -intstyle ise -dd _ngo -nt timestamp -uc ./src/$(PROJECT).ucf -p $(PART) $(PROJECT).ngc $(PROJECT).ngd 
	@$(XST)/map -intstyle ise -p $(PART) -cm area -ir off -pr off -c 100 -o $(PROJECT)_map.ncd $(PROJECT).ngd $(PROJECT).pcf 
	@$(XST)/par -w -intstyle ise -ol high -t 1 $(PROJECT)_map.ncd $(PROJECT).ncd $(PROJECT).pcf 
	@$(XST)/trce -intstyle ise -v 3 -s 4 -n 3 -fastpaths -xml $(PROJECT).twx $(PROJECT).ncd -o $(PROJECT).twr $(PROJECT).pcf -ucf $(PROJECT).ucf 
	@$(XST)/bitgen -intstyle ise $(UT_OPTS) $(PROJECT).ncd
	-@find * -name *.ucf -o -name *.v -o -name src -o -name *.bin -o -name Makefile -prune -o -exec rm -rf '{}' ';' ||: 
	@echo "Generated: $(PROJECT).bin"
	@echo "Done!"
# Comment the line below if You wish to keep all the generated Reports.

# Flashing part
flash:  $(PROJECT).bin
	@flash /dev/ttyACM0 $(PROJECT).bin

clean:
	@echo "Cleaning...."
	-@find * -name *.ucf -o -name *.v -o -name src -o -name Makefile -prune -o -exec rm -rf '{}' ';' ||: 
	@echo "Done!"
