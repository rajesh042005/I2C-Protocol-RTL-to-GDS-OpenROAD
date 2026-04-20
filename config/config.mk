# ================= DESIGN =================
export DESIGN_NAME = i2c_top
export TOP_MODULE  = i2c_top
export PLATFORM=sky130hd

# ================= RTL =================
export VERILOG_FILES = \
    $(DESIGN_HOME)/sky130hd/i2c/src/i2c_master.v \
    $(DESIGN_HOME)/sky130hd/i2c/src/i2c_slave.v \
    $(DESIGN_HOME)/sky130hd/i2c/src/i2c_top.v

export SDC_FILE= $(DESIGN_HOME)/sky130hd/i2c/const.sdc

# ================= CLOCK =================
export CLOCK_PORT   = clk
export CLOCK_PERIOD = 10.0   # 100 MHz

# ================= FLOORPLAN =================
export DIE_AREA  = 0 0 110 110
export CORE_AREA = 10 10 100 100

# ================= PLACEMENT =================
export PLACE_DENSITY = 0.60

# ================= SYNTHESIS =================
#export SYNTH_STRATEGY = AREA 0

#================= POWER =================
#export VDD_NETS = VDD
#export GND_NETS = VSS

