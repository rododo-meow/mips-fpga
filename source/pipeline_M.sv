module pipeline_M(
	input clk, resetn, m_stall, m_bubble,
	input e_wreg, e_m2reg, e_wmem, e_do_jmp_in_m, e_mode,
	input [31:0] e_data, e_aluout, dbg_e_pc,
	input [47:0] dbg_e_inst,
	input [4:0] e_rn,
	output m_wreg, m_m2reg, m_wmem, m_do_jmp_in_m, m_mode,
	output [31:0] m_data, m_aluout, dbg_m_pc,
	output [47:0] dbg_m_inst,
	output [4:0] m_rn);
	
pipeline_reg #(
	.BUBBLE_V(0)
) M_do_jmp_in_m(
	.clk(clk),
	.resetn(resetn),
	.stall(m_stall),
	.bubble(m_bubble),
	.d(e_do_jmp_in_m),
	.q(m_do_jmp_in_m)
);

pipeline_reg M_mode(
	.clk(clk),
	.resetn(resetn),
	.stall(m_stall),
	.bubble(m_bubble),
	.d(e_mode),
	.q(m_mode)
);

pipeline_reg #(
	.BUBBLE_V(0)
) M_wreg(
	.clk(clk),
	.resetn(resetn),
	.stall(m_stall),
	.bubble(m_bubble),
	.d(e_wreg),
	.q(m_wreg)
);

pipeline_reg M_m2reg(
	.clk(clk),
	.resetn(resetn),
	.stall(m_stall),
	.bubble(m_bubble),
	.d(e_m2reg),
	.q(m_m2reg)
);

pipeline_reg #(
	.BUBBLE_V(0)
) M_wmem(
	.clk(clk),
	.resetn(resetn),
	.stall(m_stall),
	.bubble(m_bubble),
	.d(e_wmem),
	.q(m_wmem)
);

pipeline_reg #(
	.WIDTH(32)
) M_data(
	.clk(clk),
	.resetn(resetn),
	.stall(m_stall),
	.bubble(m_bubble),
	.d(e_data),
	.q(m_data)
);

pipeline_reg #(
	.WIDTH(32)
) M_aluout(
	.clk(clk),
	.resetn(resetn),
	.stall(m_stall),
	.bubble(m_bubble),
	.d(e_aluout),
	.q(m_aluout)
);

pipeline_reg #(
	.WIDTH(5)
) M_rn(
	.clk(clk),
	.resetn(resetn),
	.stall(m_stall),
	.bubble(m_bubble),
	.d(e_rn),
	.q(m_rn)
);

pipeline_reg #(
	.WIDTH(32),
	.BUBBLE_V(1)
) M_dbg_pc(
	.clk(clk),
	.resetn(resetn),
	.stall(m_stall),
	.bubble(m_bubble),
	.d(dbg_e_pc),
	.q(dbg_m_pc)
);

pipeline_reg #(
	.WIDTH(48),
	.BUBBLE_V(0)
) M_dbg_inst(
	.clk(clk),
	.resetn(resetn),
	.stall(m_stall),
	.bubble(m_bubble),
	.d(dbg_e_inst),
	.q(dbg_m_inst)
);

endmodule
