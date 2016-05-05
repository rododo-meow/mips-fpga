module sc_hub(resetn, addr, datain, dataout, we, clock, mem_clk, dmem_clk, wmem, memout);
localparam ADDR_IO  = 32'hf0000000;
localparam ADDR_SEG = 32'hf0000000;
localparam ADDR_LED = 32'hf1000000;

input [31:0] addr, datain, memout;
input we, clock, mem_clk, resetn;
output [31:0] dataout;
output dmem_clk, wmem;

wire target_io = addr[31:28] == ADDR_IO[31:28];
wire target_seg = target_io & (addr[27:24] == ADDR_SEG[27:24]);
wire target_led = target_io & (addr[27:24] == ADDR_LED[27:24]);
wire target_mem = ~target_io;

wire wio = target_io & we & dmem_clk;
wire wio_seg = wio & target_seg;
wire wio_led = wio & target_led;

wire rio = target_io & ~we & dmem_clk;
wire rio_seg = rio & target_seg;
wire rio_led = rio & target_led;

reg [31:0] ioout;
reg [3:0] seg_buf[6];
reg [9:0] led;

assign dmem_clk = ~clock & mem_clk;
assign wmem = target_mem && we;

assign dataout = target_io ? ioout : memout;

integer i;

always @(posedge wio_seg, negedge resetn) begin
	if (!resetn) begin
		seg_buf[0] <= 0;
		seg_buf[1] <= 0;
		seg_buf[2] <= 0;
		seg_buf[3] <= 0;
		seg_buf[4] <= 0;
		seg_buf[5] <= 0;
	end else begin
		case (addr[4:2])
		3'd0: seg_buf[0] <= datain[3:0];
		3'd1: seg_buf[1] <= datain[3:0];
		3'd2: seg_buf[2] <= datain[3:0];
		3'd3: seg_buf[3] <= datain[3:0];
		3'd4: seg_buf[4] <= datain[3:0];
		3'd5: seg_buf[5] <= datain[3:0];
		endcase;
	end
end

always @(posedge wio_led, negedge resetn) begin
	if (!resetn)
		led <= 10'd0;
	else
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
		endcase;
end

always @(posedge rio) begin
	if (rio_seg) begin
		case (addr[4:2])
		3'd0: ioout <= { 28'd0, seg_buf[0] };
		3'd1: ioout <= { 28'd0, seg_buf[1] };
		3'd2: ioout <= { 28'd0, seg_buf[2] };
		3'd3: ioout <= { 28'd0, seg_buf[3] };
		3'd4: ioout <= { 28'd0, seg_buf[4] };
		3'd5: ioout <= { 28'd0, seg_buf[5] };
		default: ioout <= 0;
		endcase
	end else if (rio_led) begin
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
		default: ioout <= 0;
		endcase
	end else
		ioout <= 0;
end

endmodule