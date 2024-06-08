`default_nettype none

module blink_led (
	input wire clk_i,
	output wire o_led
);

reg [31:0] cnt = 0;

always @(posedge clk_i) 
  begin
    cnt <= cnt + 1;
  end

assign o_led = cnt[24];

endmodule
