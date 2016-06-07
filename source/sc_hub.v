module sc_hub(resetn, addr, datain, dataout, we, clk, wmem, memout,
	LED, SEG0, SEG1, SEG2, SEG3, SEG4, SEG5, SW, KEY,
	vga_clk, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);
localparam ADDR_IO  = 32'hf0000000;
localparam ADDR_SEG = 32'hf0000000;
localparam ADDR_LED = 32'hf1000000;
localparam ADDR_SW  = 32'hf2000000;
localparam ADDR_KEY = 32'hf3000000;
localparam ADDR_VGA = 32'hf4000000;

input [31:0] addr, datain, memout;
input we, clk, resetn;
input [9:0] SW;
input [3:0] KEY;
output [31:0] dataout;
output wmem;
output [9:0] LED;
output [6:0] SEG0, SEG1, SEG2, SEG3, SEG4, SEG5;
input vga_clk;
output [7:0] VGA_R, VGA_G, VGA_B;
output VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK;

wire target_io  = addr[31:28] == ADDR_IO[31:28];
wire target_mem = ~target_io;

wire [23:0] seg_buf;
reg [31:0] ioout;
wire [31:0] sw_dataout, key_dataout;

assign wmem = target_mem && we;

assign dataout = target_io ? ioout : memout;

always @* begin
	case (addr[27:24])
	ADDR_SW[27:24]: ioout <= sw_dataout;
	ADDR_KEY[27:24]: ioout <= key_dataout;
	default: ioout <= 0;
	endcase
end

io_pio_output #(.WIDTH(10)) led_pio(
	.clk(clk),
	.resetn(resetn),
	.addr(addr[7:0]),
	.datain(datain),
	.we(we && addr[27:24] == ADDR_LED[27:24] && target_io),
	.pio(LED)
);

io_pio_output #(.WIDTH(24), .GROUP(4)) seg_pio(
	.clk(clk),
	.resetn(resetn),
	.addr(addr[7:0]),
	.datain(datain),
	.we(we && addr[27:24] == ADDR_SEG[27:24] && target_io),
	.pio(seg_buf)
);

io_pio_input #(.WIDTH(4)) key_pio(
	.clk(clk),
	.resetn(resetn),
	.addr(addr[7:0]),
	.dataout(key_dataout),
	.pio(KEY)
);

io_pio_input #(.WIDTH(10)) sw_pio(
	.clk(clk),
	.resetn(resetn),
	.addr(addr[7:0]),
	.dataout(sw_dataout),
	.pio(SW)
);

io_vga vga(
	.clk(clk), .resetn(resetn),
	.addr(addr[23:0]), .datain(datain),
	.we(we && addr[27:24] == ADDR_VGA[27:24] && target_io),
	.vga_clk(vga_clk),
	.VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B),
	.VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_BLANK_N(VGA_BLANK_N), .VGA_SYNC_N(VGA_SYNC_N), .VGA_CLK(VGA_CLK)
);

segdriver seg0(
	.hex(seg_buf[3:0]),
	.seg(SEG0)
);
segdriver seg1(
	.hex(seg_buf[7:4]),
	.seg(SEG1)
);
segdriver seg2(
	.hex(seg_buf[11:8]),
	.seg(SEG2)
);
segdriver seg3(
	.hex(seg_buf[15:12]),
	.seg(SEG3)
);
segdriver seg4(
	.hex(seg_buf[19:16]),
	.seg(SEG4)
);
segdriver seg5(
	.hex(seg_buf[23:20]),
	.seg(SEG5)
);

endmodule