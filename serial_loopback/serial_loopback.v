`default_nettype none

module serial_loopback (
	input wire clk_i,
	input wire i_Rx_Serial,
	output wire o_Tx_Serial,
	output wire o_led
);

assign o_Tx_Serial = i_Rx_Serial;
assign o_led = o_Tx_Serial;

endmodule
