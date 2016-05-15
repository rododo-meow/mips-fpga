module pipeline_W(
	input clk, resetn, w_stall, w_bubble,
	input m_wreg, m_m2reg,
	input [31:0] m_data, m_memout, dbg_m_pc, dbg_m_inst,
	input [4:0] m_rn,
	output w_wreg, w_m2reg,
	output [31:0] w_data, w_memout, dbg_w_pc, dbg_w_inst,
	output [4:0] w_rn);
	
pipeline_reg #(
	.BUBBLE_V(0)
) W_wreg(
	.clk(clk),
	.resetn(resetn),
	.stall(w_stall),
	.bubble(w_bubble),
	.d(m_wreg),
	.q(w_wreg)
);

pipeline_reg W_m2reg(
	.clk(clk),
	.resetn(resetn),
	.stall(w_stall),
	.bubble(w_bubble),
	.d(m_m2reg),
	.q(w_m2reg)
);

pipeline_reg #(
	.WIDTH(32)
) W_data(
	.clk(clk),
	.resetn(resetn),
	.stall(w_stall),
	.bubble(w_bubble),
	.d(m_data),
	.q(w_data)
);

pipeline_reg #(
	.WIDTH(32)
) W_memout(
	.clk(clk),
	.resetn(resetn),
	.stall(w_stall),
	.bubble(w_bubble),
	.d(m_memout),
	.q(w_memout)
);

pipeline_reg #(
	.WIDTH(5)
) W_rn(
	.clk(clk),
	.resetn(resetn),
	.stall(w_stall),
	.bubble(w_bubble),
	.d(m_rn),
	.q(w_rn)
);

pipeline_reg #(
	.WIDTH(32),
	.BUBBLE_V(1)
) W_dbg_pc(
	.clk(clk),
	.resetn(resetn),
	.stall(w_stall),
	.bubble(w_bubble),
	.d(dbg_m_pc),
	.q(dbg_w_pc)
);

pipeline_reg #(
	.WIDTH(32),
	.BUBBLE_V(0)
) W_dbg_inst(
	.clk(clk),
	.resetn(resetn),
	.stall(w_stall),
	.bubble(w_bubble),
	.d(dbg_m_inst),
	.q(dbg_w_inst)
);

endmodule
