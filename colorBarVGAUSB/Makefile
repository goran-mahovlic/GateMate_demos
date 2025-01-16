OFL   = openFPGALoader
RM    = rm -rf

CC_TOOL_DIR=$(CC_TOOL)
YOSYS = $(CC_TOOL)/bin/yosys/yosys
P_R   = $(CC_TOOL)/bin/p_r/p_r

PRFLAGS = --verbose -cCP

VGA    = olimex
TOP    = colorBarVGAUSB
CONSTR = $(TOP).ccf

OBJS += $(TOP).v
OBJS += hdl/vga.v
OBJS += hdl/hex_decoder_v.v
OBJS += graphics/vga_core.v
OBJS += graphics/color_bar.v
OBJS += clocks/gatemate_25MHz_125MHz_pll.v
OBJS += clocks/gatemate_48MHz_pll.v
OBJS += usbhost/usbh_host_hid.v
OBJS += usbhost/usbh_crc16.v
OBJS += usbhost/usbh_crc5.v
OBJS += usbhost/usbh_sie.v
OBJS += usbhost/usb_phy.v
OBJS += usbhost/usb_rx_phy.v
OBJS += usbhost/usb_tx_phy.v
OBJS += ../libs/graphics/dvi_core.v
OBJS += ../libs/graphics/tmds_encoder.v
OBJS += ../libs/ios/serializer_gatemate_10_to_1_generic_ddr.v

YS_OPTS = -D DISP_640x480_60Hz=1

BOARD=olimex_gatemateevb

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
