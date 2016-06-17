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

wire q1, q2, q3;

reg [19:0] cleanaddr;
wire cleanclk;

/* read 1, write 2, clean 3
 * clean 1, read 2, write 3
 * write 1, clean 2, read 3
 */
reg [2:0] clean;

assign cleanclk = vga_clk;

always @(negedge cleanclk) begin
	if (cleanaddr[19:10] > 600)
		cleanaddr <= 0;
	else
		cleanaddr <= cleanaddr + 1;
end

vga_buf vga_buf1(
	.data(clean[0] ? 0 : (datain != 0)),
	.rdaddress({y,x}),
	.rdclock(~vga_clk),
	.wraddress(clean[0] ? cleanaddr : addr[19:0]),
	.wrclock(clean[0] ? cleanclk : clk),
	.wren(clean[0] | (clean[1] & we & (addr[23:20] == 0))),
	.q(q1)
);

vga_buf vga_buf2(
	.data(clean[1] ? 0 : (datain != 0)),
	.rdaddress({y,x}),
	.rdclock(~vga_clk),
	.wraddress(clean[1] ? cleanaddr : addr[19:0]),
	.wrclock(clean[1] ? cleanclk : clk),
	.wren(clean[1] | (clean[2] & we & (addr[23:20] == 0))),
	.q(q2)
);

vga_buf vga_buf3(
	.data(clean[2] ? 0 : (datain != 0)),
	.rdaddress({y,x}),
	.rdclock(~vga_clk),
	.wraddress(clean[2] ? cleanaddr : addr[19:0]),
	.wrclock(clean[2] ? cleanclk : clk),
	.wren(clean[2] | (clean[0] & we & (addr[23:20] == 0))),
	.q(q3)
);

always @(*) begin
	vga_r <= {8{clean[2] ? q1 : (clean[0] ? q2 : q3)}} | {8{(x == 0)}};
	vga_g <= {8{clean[2] ? q1 : (clean[0] ? q2 : q3)}} | {8{(x == 0)}};
	vga_b <= {8{clean[2] ? q1 : (clean[0] ? q2 : q3)}} | {8{(x == 0)}};
end

always @(posedge clk, negedge resetn) begin
	if (!resetn)
		clean <= 3'b100;
	else if (we && addr == 24'hfffffc) begin
		case (clean)
		3'b100: clean <= 3'b001;
		3'b001: clean <= 3'b010;
		3'b010: clean <= 3'b100;
		default: clean <= 3'b100;
		endcase
	end
end

endmodule
	