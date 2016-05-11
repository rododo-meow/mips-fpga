module sc_hub(resetn, addr, datain, dataout, we, clock, mem_clk, dmem_clk, wmem, memout,
	LED, SEG0, SEG1, SEG2, SEG3, SEG4, SEG5, SW, KEY);
localparam ADDR_IO  = 32'hf0000000;
localparam ADDR_SEG = 32'hf0000000;
localparam ADDR_LED = 32'hf1000000;
localparam ADDR_SW  = 32'hf2000000;
localparam ADDR_KEY = 32'hf3000000;

input [31:0] addr, datain, memout;
input we, clock, mem_clk, resetn;
input [9:0] SW;
input [3:0] KEY;
output [31:0] dataout;
output dmem_clk, wmem;
output [9:0] LED;
output [6:0] SEG0, SEG1, SEG2, SEG3, SEG4, SEG5;

wire target_io  = addr[31:28] == ADDR_IO[31:28];
wire target_mem = ~target_io;

wire [23:0] seg_buf;
reg [31:0] ioout;
wire [31:0] sw_dataout, key_dataout;

assign dmem_clk = ~clock & mem_clk;
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
	.clk(dmem_clk),
	.resetn(resetn),
	.addr(addr[7:0]),
	.datain(datain),
	.we(we & addr[27:24] == ADDR_LED[27:24]),
	.pio(LED)
);

io_pio_output #(.WIDTH(24), .GROUP(4)) seg_pio(
	.clk(dmem_clk),
	.resetn(resetn),
	.addr(addr[7:0]),
	.datain(datain),
	.we(we & addr[27:24] == ADDR_SEG[27:24]),
	.pio(seg_buf)
);

io_pio_input #(.WIDTH(4)) key_pio(
	.clk(dmem_clk),
	.resetn(resetn),
	.addr(addr[7:0]),
	.dataout(key_dataout),
	.pio(KEY)
);

io_pio_input #(.WIDTH(10)) sw_pio(
	.clk(dmem_clk),
	.resetn(resetn),
	.addr(addr[7:0]),
	.dataout(sw_dataout),
	.pio(SW)
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