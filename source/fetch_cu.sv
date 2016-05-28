module fetch_cu(
	input [31:0] f_pc, 
	output [31:0] next_pc, f_next_inst_pc,
	input [2:0] f_off,
	output [2:0] next_off,
	input [7:0] instmem_dataout,
	input [47:0] f_inst,
	output [47:0] _f_inst,
	input f_mode, 
	output next_mode,
	input d_flush_fetch,
	input [31:0] d_target_pc,
	input d_target_mode);
	
reg [2:0] inst_size[16];
reg [47:0] _f_inst_reg;
reg [2:0] next_off_reg;
reg [31:0] f_next_inst_pc_reg;
assign _f_inst = _f_inst_reg;
assign next_off = next_off_reg;
assign f_next_inst_pc = f_next_inst_pc_reg;
assign next_pc = f_next_inst_pc;

assign next_mode = f_mode;

always @(*) begin
	inst_size[0] = 1;
	inst_size[1] = 1;
	inst_size[2] = 2;
	inst_size[3] = 6;
	inst_size[4] = 6;
	inst_size[5] = 6;
	inst_size[6] = 2;
	inst_size[7] = 5;
	inst_size[8] = 2;
	inst_size[9] = 5;
	inst_size['ha] = 1;
	inst_size['hb] = 2;
	inst_size['hc] = 2;
end

wire inst_done = (f_mode == 0) ? (f_off == 3'd3) : (f_off == (inst_size[_f_inst[7:0]] - 3'd1));

always @(*) begin
	if (f_mode == 0)
		case (f_off)
		0: _f_inst_reg <= { 16'd0, instmem_dataout, 28'd0 };
		1: _f_inst_reg <= { 16'd0, f_inst[31:24], instmem_dataout, 16'd0 };
		2: _f_inst_reg <= { 16'd0, f_inst[31:16], instmem_dataout, 8'd0 };
		3: _f_inst_reg <= { 16'd0, f_inst[31:8], instmem_dataout };
		default: _f_inst_reg <= 48'd0;
		endcase
	else
		case (f_off)
		0: _f_inst_reg <= { 40'd0, instmem_dataout };
		1: _f_inst_reg <= { 32'd0, instmem_dataout, f_inst[7:0] };
		2: _f_inst_reg <= { 24'd0, instmem_dataout, f_inst[15:0] };
		3: _f_inst_reg <= { 16'd0, instmem_dataout, f_inst[23:0] };
		4: _f_inst_reg <= { 8'd0, instmem_dataout, f_inst[31:0] };
		5: _f_inst_reg <= { instmem_dataout, f_inst[39:0] };
		default: _f_inst_reg <= 48'd0;
		endcase
end

always @(*) begin
	next_off_reg <= inst_done ? 3'd0 : (f_off + 3'd1);
end

always @(*) begin
	if (inst_done)
		f_next_inst_pc_reg <= (f_mode == 0) ? (f_pc + 4) : (f_pc + inst_size[_f_inst[7:0]]);
	else
		f_next_inst_pc_reg <= f_pc;
end

endmodule
