`default_nettype none

module colorBarVGAUSB
#(
  parameter usb_speed = 1 // 0 - slow - not implemented  - 1 - 48MHz fast 2.0
)
(
	input clk_i, 
	input rstn_i,
	output [3:0] o_r,
	output [3:0] o_g,
	output [3:0] o_b,
	output o_vsync,
	output o_hsync,
	output [7:0] o_led,
	input usb_fpga_dp,
	inout usb_fpga_bd_dp,
	inout usb_fpga_bd_dn,
	output usb_fpga_pu_dp,
	output usb_fpga_pu_dn
);

wire clk_pix, lock, lock_usb;
wire clk_usb;  // 48 MHz USB1.1
wire [63:0] S_report[0:2];
wire [2:0] S_valid;
reg [63:0] R_display; // something to display

/* PLL for 25MHz VGA */
pll pll_inst (
    .clock_in(clk_i), // 10 MHz
	.rst_in(~rstn_i),
    .clock_out(clk_pix), // 25 MHz, 0 deg
    .locked(lock)
);

/* PLL for 48MHz USB */
pll48 pll_inst_usb (
    .clock_in(clk_i), // 10 MHz
    .rst_in(~rstn_i),
    .clock_out(clk_usb), // 48 MHz, 0 deg
    .locked(lock_usb)
);

// USB START

assign usb_fpga_pu_dp = 1'b0;
assign usb_fpga_pu_dn = 1'b0;
usbh_host_hid
#(
  .C_report_length(20),
  .C_report_length_strict(0),
  .C_usb_speed(usb_speed) // '0':Low-speed '1':Full-speed
)
us2_hid_host_inst
(
  .clk(clk_usb), // 48 MHz for full-speed USB1.1 device
  .bus_reset(1'b1),
  .led(o_led), // debug output
  .usb_dif(usb_fpga_dp),
  .usb_dp(usb_fpga_bd_dp),
  .usb_dn(usb_fpga_bd_dn),
  .hid_report(S_report[0]),
  .hid_valid(S_valid[0])
);
always @(posedge clk_usb)
  if(S_valid[0])
    R_display[63:0] <= S_report[0][63:0];

// END USB

reg [19:0] reset_counter;
always @(posedge clk_pix)
begin
  if(rstn_i == 1'b1 && reset_counter[19] == 1'b0)
    reset_counter <= reset_counter + 1;
  if(rstn_i == 1'b0)
    reset_counter <= 0;
end
wire reset;
assign reset = reset_counter[19];
parameter C_color_bits = 16; 

wire [9:0] x;
wire [9:0] y;
// for reverse screen:
wire [9:0] rx = 636-x;
wire [C_color_bits-1:0] color;
hex_decoder_v
#(
    .c_data_len(64),
    .c_row_bits(4), // 2**n digits per row (4*2**n bits/row) 3->32, 4->64, 5->128, 6->256 
    .c_grid_6x8(0), // NOTE: TRELLIS needs -abc9 option to compile
    .c_font_file("hex/hex_font.mem"),
    .c_x_bits(8),
    .c_y_bits(4),
.c_color_bits(C_color_bits)
)
hex_decoder_v_inst
(
    .clk(clk_pix),
    .data(R_display),
    .x(rx[9:2]),
    .y(y[5:2]),
    .color(color)
);

//assign o_led = reset; 

assign o_r = color[15:12];
assign o_g = color[10:7];
assign o_b = color[4:1];

wire vga_hsync, vga_vsync, vga_blank;

vga
vga_instance
(
.clk_pixel(clk_pix),
.clk_pixel_ena(1'b1),
.test_picture(1'b0), // enable test picture generation
.beam_x(x),
.beam_y(y),
//.vga_r(vga_r),
//.vga_g(vga_g),
//.vga_b(vga_b),
.vga_hsync(o_hsync),
.vga_vsync(o_vsync),
.vga_blank(vga_blank)
);

endmodule
