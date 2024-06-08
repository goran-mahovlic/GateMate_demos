OFL   = openFPGALoader
RM    = rm -rf

CC_TOOL_DIR=$(CC_TOOL)
YOSYS = $(CC_TOOL)/bin/yosys/yosys
P_R   = $(CC_TOOL)/bin/p_r/p_r

PRFLAGS = --verbose -cCP

VGA    ?= olimex
TOP    = blink_led
CONSTR = $(TOP)_$(VGA).ccf

OBJS += $(TOP).v

ifeq ($(VGA), olimex)
BOARD=olimex_gatemateevb
else
BOARD=gatemate_evb_jtag
endif

all:impl
synth: $(TOP)_synth.v
$(TOP)_synth.v: $(OBJS)
	$(YOSYS) -l synth.log $(YS_OPTS) -p 'read -sv $^; synth_gatemate -top $(TOP) -nomx8 -dff -vlog $(TOP)_synth.v'

$(TOP)_00.cfg: $(TOP)_synth.v $(CONSTR)
	$(P_R) -v -i $(TOP)_synth.v -ccf $(CONSTR) -o $(TOP) $(PRFLAGS) > $@.log
impl:$(TOP)_00.cfg

jtag: $(TOP)_00.cfg
	$(OFL) $(OFLFLAGS) -b $(BOARD) $^

jtag-flash: $(TOP)_00.cfg
	$(OFL) $(OFLFLAGS) -b $(BOARD) -f --verify $^

clean:
	$(RM) *.log *_synth.v *.history *.txt *.refwire *.refparam
	$(RM) *.refcomp *.pos *.pathes *.path_struc *.net *.id *.prn
	$(RM) *_00.v *.used *.sdf *.place *.pin *.cfg* *.cdf
