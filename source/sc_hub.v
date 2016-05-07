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
wire target_seg = target_io & (addr[27:24] == ADDR_SEG[27:24]);
wire target_led = target_io & (addr[27:24] == ADDR_LED[27:24]);
wire target_sw  = target_io & (addr[27:24] == ADDR_SW [27:24]);
wire target_key = target_io & (addr[27:24] == ADDR_KEY[27:24]);
wire target_mem = ~target_io;

reg [31:0] ioout;
reg [23:0] seg_buf;
reg [9:0] led;

assign dmem_clk = ~clock & mem_clk;
assign wmem = target_mem && we;

assign dataout = target_io ? ioout : memout;

assign LED = led;

integer i;

always @(posedge dmem_clk, negedge resetn) begin
	if (!resetn) begin
		seg_buf <= 0;
	end else if (we & target_seg & addr[4:2] >= 0 & addr[4:2] <= 6) begin
		case (addr[4:2])
		3'd0: seg_buf[3:0] <= datain[3:0];
		3'd1: seg_buf[7:4] <= datain[3:0];
		3'd2: seg_buf[11:8] <= datain[3:0];
		3'd3: seg_buf[15:12] <= datain[3:0];
		3'd4: seg_buf[19:16] <= datain[3:0];
		3'd5: seg_buf[23:20] <= datain[3:0];
		3'd6: seg_buf <= datain[23:0];
		default: seg_buf <= 0;
		endcase
	end
end

always @(posedge dmem_clk, negedge resetn) begin
	if (!resetn)
		led <= 10'd0;
	else if (we & target_led & addr[5:2] >= 0 & addr[5:2] <= 10)
		case (addr[5:2])
		4'd0: led[0] <= datain[0];
		4'd1: led[1] <= datain[0];
		4'd2: led[2] <= datain[0];
		4'd3: led[3] <= datain[0];
		4'd4: led[4] <= datain[0];
		4'd5: led[5] <= datain[0];
		4'd6: led[6] <= datain[0];
		4'd7: led[7] <= datain[0];
		4'd8: led[8] <= datain[0];
		4'd9: led[9] <= datain[0];
		4'd10: led <= datain[9:0];
		default: led <= 0;
		endcase
end

always begin
	case (addr[27:24])
	ADDR_SEG[27:24]:
		case (addr[4:2])
		3'd0: ioout <= { 28'd0, seg_buf[3:0] };
		3'd1: ioout <= { 28'd0, seg_buf[7:4] };
		3'd2: ioout <= { 28'd0, seg_buf[11:8] };
		3'd3: ioout <= { 28'd0, seg_buf[15:12] };
		3'd4: ioout <= { 28'd0, seg_buf[19:16] };
		3'd5: ioout <= { 28'd0, seg_buf[23:20] };
		3'd6: ioout <= { 8'd0, seg_buf };
		default: ioout <= 0;
		endcase
	ADDR_LED[27:24]:
		case (addr[5:2])
		4'd0: ioout <= { 31'd0, led[0] };
		4'd1: ioout <= { 31'd0, led[1] };
		4'd2: ioout <= { 31'd0, led[2] };
		4'd3: ioout <= { 31'd0, led[3] };
		4'd4: ioout <= { 31'd0, led[4] };
		4'd5: ioout <= { 31'd0, led[5] };
		4'd6: ioout <= { 31'd0, led[6] };
		4'd7: ioout <= { 31'd0, led[7] };
		4'd8: ioout <= { 31'd0, led[8] };
		4'd9: ioout <= { 31'd0, led[9] };
		4'd10: ioout <= { 22'd0, led };
		default: ioout <= 0;
		endcase
	ADDR_SW[27:24]:
		case (addr[5:2])
		4'd0: ioout <= { 31'd0, SW[0] };
		4'd1: ioout <= { 31'd0, SW[1] };
		4'd2: ioout <= { 31'd0, SW[2] };
		4'd3: ioout <= { 31'd0, SW[3] };
		4'd4: ioout <= { 31'd0, SW[4] };
		4'd5: ioout <= { 31'd0, SW[5] };
		4'd6: ioout <= { 31'd0, SW[6] };
		4'd7: ioout <= { 31'd0, SW[7] };
		4'd8: ioout <= { 31'd0, SW[8] };
		4'd9: ioout <= { 31'd0, SW[9] };
		4'd10: ioout <= { 22'd0, SW };
		default: ioout <= 0;
		endcase
	ADDR_KEY[27:24]:
		case (addr[4:2])
		3'd0: ioout <= { 31'd0, KEY[0] };
		3'd1: ioout <= { 31'd0, KEY[1] };
		3'd2: ioout <= { 31'd0, KEY[2] };
		3'd3: ioout <= { 31'd0, KEY[3] };
		3'd4: ioout <= { 28'd0, KEY };
		default: ioout <= 0;
		endcase
	default:
		ioout <= 0;
	endcase
end

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