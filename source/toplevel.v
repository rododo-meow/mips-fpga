module toplevel(CLOCK_50, KEY, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, SW);
input CLOCK_50;
input [3:0] KEY;
input [9:0] SW;
output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
output [9:0] LEDR;

wire mem_clk, clock, locked;
wire [31:0] pc;

pll pll(
	.refclk(CLOCK_50),
	.outclk_0(mem_clk),
	.outclk_1(clock),
	.rst(~KEY[0]),
	.locked(locked)
);

sc_computer computer(
	.resetn(KEY[0] & locked),
	.clock(clock),
	.mem_clk(mem_clk),
	.LED(LEDR),
	.SEG0(HEX0),
	.SEG1(HEX1),
	.SEG2(HEX2),
	.SEG3(HEX3),
	.SEG4(HEX4),
	.SEG5(HEX5),
	.SW(SW),
	.KEY(KEY)
);

endmodule