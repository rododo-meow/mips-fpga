module fetch_cu(
	input clk, resetn,
	input [31:0] f_pc, 
	output [31:0] next_pc, f_next_inst_pc,
	input [7:0] instmem_dataout,
	output [47:0] f_inst,
	input f_mode, 
	output next_mode,
	input d_do_jmp, d_target_mode,
	input [31:0] d_target_pc,
	input t_do_jmp, t_target_mode,
	input [31:0] t_target_pc,
	input m_do_jmp, m_target_mode,
	input [31:0] m_target_pc,
	output f_output, f_available,
	output [31:0] instmem_addr);
	
reg [2:0] inst_size[16];
reg [47:0] _f_inst, __f_inst;
reg [2:0] off;
reg [31:0] f_next_inst_pc_reg;
assign f_inst = _f_inst;
assign f_next_inst_pc = f_next_inst_pc_reg;
assign next_pc = f_next_inst_pc;

assign next_mode = m_do_jmp ? m_target_mode : (d_do_jmp ? d_target_mode : (t_do_jmp ? t_target_mode : f_mode));
assign instmem_addr = f_pc + off;

initial begin
	inst_size[0] = 1;
	inst_size[1] = 1;
	inst_size[2] = 2;
	inst_size[3] = 6;
	inst_size[4] = 6;
	inst_size[5] = 6;
	inst_size[6] = 2;
	inst_size[7] = 5;
	inst_size[8] = 5;
	inst_size[9] = 1;
	inst_size['ha] = 2;
	inst_size['hb] = 2;
	inst_size['hc] = 5;
	inst_size['hd] = 6;
	inst_size['he] = 6;
	inst_size['hf] = 1;
end

wire inst_done = (f_mode == 0) ? (off == 3'd3) : (off == (inst_size[_f_inst[7:4]] - 3'd1));
assign f_output = inst_done;
assign f_available = inst_done | m_do_jmp | d_do_jmp | t_do_jmp;

always @(posedge clk, negedge resetn) begin
	if (!resetn)
		__f_inst <= 48'd0;
	else if (f_mode == 0)
		case (off)
		0: __f_inst <= { 40'd0, instmem_dataout };
		1: __f_inst <= { 32'd0, instmem_dataout, __f_inst[7:0] };
		2: __f_inst <= { 24'd0, instmem_dataout, __f_inst[15:0] };
		3: __f_inst <= { 16'd0, instmem_dataout, __f_inst[23:0] };
		default: __f_inst <= 48'd0;
		endcase
	else
		case (off)
		0: __f_inst <= { 40'd0, instmem_dataout };
		1: __f_inst <= { 32'd0, instmem_dataout, __f_inst[7:0] };
		2: __f_inst <= { 24'd0, instmem_dataout, __f_inst[15:0] };
		3: __f_inst <= { 16'd0, instmem_dataout, __f_inst[23:0] };
		4: __f_inst <= { 8'd0, instmem_dataout, __f_inst[31:0] };
		5: __f_inst <= { instmem_dataout, __f_inst[39:0] };
		default: __f_inst <= 48'd0;
		endcase
end

always @(*) begin
	if (f_mode == 0)
		case (off)
		0: _f_inst <= { 40'd0, instmem_dataout };
		1: _f_inst <= { 32'd0, instmem_dataout, __f_inst[7:0] };
		2: _f_inst <= { 24'd0, instmem_dataout, __f_inst[15:0] };
		3: _f_inst <= { 16'd0, instmem_dataout, __f_inst[23:0] };
		default: _f_inst <= 48'd0;
		endcase
	else
		case (off)
		0: _f_inst <= { 40'd0, instmem_dataout };
		1: _f_inst <= { 32'd0, instmem_dataout, __f_inst[7:0] };
		2: _f_inst <= { 24'd0, instmem_dataout, __f_inst[15:0] };
		3: _f_inst <= { 16'd0, instmem_dataout, __f_inst[23:0] };
		4: _f_inst <= { 8'd0, instmem_dataout, __f_inst[31:0] };
		5: _f_inst <= { instmem_dataout, __f_inst[39:0] };
		default: _f_inst <= 48'd0;
		endcase
end

always @(posedge clk, negedge resetn) begin
	if (!resetn)
		off <= 0;
	else
		off <= (inst_done || m_do_jmp || d_do_jmp || t_do_jmp) ? 3'd0 : (off + 3'd1);
end

always @(*) begin
	if (m_do_jmp)
		f_next_inst_pc_reg <= m_target_pc;
	else if (d_do_jmp)
		f_next_inst_pc_reg <= d_target_pc;
	else if (t_do_jmp)
		f_next_inst_pc_reg <= t_target_pc;
	else if (inst_done)
		f_next_inst_pc_reg <= (f_mode == 0) ? (f_pc + 4) : (f_pc + inst_size[_f_inst[7:4]]);
	else 
		f_next_inst_pc_reg <= f_pc;
end

endmodule
