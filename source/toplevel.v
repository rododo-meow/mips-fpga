module toplevel(CLOCK_50, KEY, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
input CLOCK_50;
input [3:0] KEY;
output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

wire mem_clk, clock, locked;
wire [31:0] pc;

pll pll(
	.refclk(CLOCK_50),
	.outclk_0(mem_clk),
	.outclk_1(clock),
	.rst(~KEY[0]),
	.locked(locked)
);

sc_computer computer(KEY[0] & locked, clock, mem_clk, pc);

segdriver seg0(
	.clk(clock),
	.hex(pc[3:0]),
	.seg(HEX0)
);
segdriver seg1(
	.clk(clock),
	.hex(pc[7:4]),
	.seg(HEX1)
);
segdriver seg2(
	.clk(clock),
	.hex(pc[11:8]),
	.seg(HEX2)
);
segdriver seg3(
	.clk(clock),
	.hex(pc[15:12]),
	.seg(HEX3)
);
segdriver seg4(
	.clk(clock),
	.hex(pc[19:16]),
	.seg(HEX4)
);
segdriver seg5(
	.clk(clock),
	.hex(pc[23:20]),
	.seg(HEX5)
);

endmodule