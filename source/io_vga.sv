module io_vga(
	input clk, resetn,
	input [23:0] addr,
	input [31:0] datain,
	input we,
	input vga_clk,
	output [7:0] VGA_R, VGA_G, VGA_B,
	output VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);
	
reg [7:0] vga_r, vga_g, vga_b;
wire [9:0] x, y;

vga_cu vga_cu(
	.vga_clk(vga_clk),
	.resetn(resetn),
	.VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B),
	.VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_BLANK_N(VGA_BLANK_N), .VGA_SYNC_N(VGA_SYNC_N), .VGA_CLK(VGA_CLK),
	.x(x), .y(y),
	.vga_r(vga_r), .vga_g(vga_g), .vga_b(vga_b)
);

wire q1, q2;
reg bindex;

vga_buf vga_buf1(
	.data(datain != 0),
	.rdaddress({y,x}),
	.rdclock(~vga_clk),
	.wraddress(addr[19:0]),
	.wrclock(clk),
	.wren(bindex & we & (addr[23:20] == 0)),
	.q(q1)
);

vga_buf vga_buf2(
	.data(datain != 0),
	.rdaddress({y,x}),
	.rdclock(~vga_clk),
	.wraddress(addr[19:0]),
	.wrclock(clk),
	.wren(~bindex & we & (addr[23:20] == 0)),
	.q(q2)
);

always @(*) begin
	vga_r <= {8{bindex == 0 ? q1 : q2}};
	vga_g <= {8{bindex == 0 ? q1 : q2}};
	vga_b <= {8{bindex == 0 ? q1 : q2}};
end

always @(posedge clk, negedge resetn) begin
	if (!resetn)
		bindex <= 0;
	else if (we && addr == 24'hfffffc)
		bindex <= ~bindex;
end

endmodule
	