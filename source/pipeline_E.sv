module pipeline_E(
	input clk, resetn, e_stall, e_bubble,
	input d_wreg, d_m2reg, d_wmem, d_jal, d_shift, d_aluimm, 
	input [3:0] d_aluc, 
	input [31:0] d_p4, d_q1, d_q2, d_ext_imm, dbg_d_pc, dbg_d_inst,
	input [4:0] d_rn,
	output e_wreg, e_m2reg, e_wmem, e_jal, e_shift, e_aluimm, 
	output [3:0] e_aluc, 
	output [31:0] e_p4, e_q1, e_q2, e_ext_imm, dbg_e_pc, dbg_e_inst,
	output [4:0] e_rn);
	
pipeline_reg #(
	.BUBBLE_V(0)
) E_wreg(
	.clk(clk),
	.resetn(resetn),
	.stall(e_stall),
	.bubble(e_bubble),
	.d(d_wreg),
	.q(e_wreg)
);

pipeline_reg E_m2reg(
	.clk(clk),
	.resetn(resetn),
	.stall(e_stall),
	.bubble(e_bubble),
	.d(d_m2reg),
	.q(e_m2reg)
);

pipeline_reg #(
	.BUBBLE_V(0)
) E_wmem(
	.clk(clk),
	.resetn(resetn),
	.stall(e_stall),
	.bubble(e_bubble),
	.d(d_wmem),
	.q(e_wmem)
);

pipeline_reg E_jal(
	.clk(clk),
	.resetn(resetn),
	.stall(e_stall),
	.bubble(e_bubble),
	.d(d_jal),
	.q(e_jal)
);

pipeline_reg E_shift(
	.clk(clk),
	.resetn(resetn),
	.stall(e_stall),
	.bubble(e_bubble),
	.d(d_shift),
	.q(e_shift)
);

pipeline_reg E_aluimm(
	.clk(clk),
	.resetn(resetn),
	.stall(e_stall),
	.bubble(e_bubble),
	.d(d_aluimm),
	.q(e_aluimm)
);

pipeline_reg #(
	.WIDTH(4)
) E_aluc(
	.clk(clk),
	.resetn(resetn),
	.stall(e_stall),
	.bubble(e_bubble),
	.d(d_aluc),
	.q(e_aluc)
);

pipeline_reg #(
	.WIDTH(32)
) E_p4(
	.clk(clk),
	.resetn(resetn),
	.stall(e_stall),
	.bubble(e_bubble),
	.d(d_p4),
	.q(e_p4)
);

pipeline_reg #(
	.WIDTH(32)
) E_q1(
	.clk(clk),
	.resetn(resetn),
	.stall(e_stall),
	.bubble(e_bubble),
	.d(d_q1),
	.q(e_q1)
);

pipeline_reg #(
	.WIDTH(32)
) E_q2(
	.clk(clk),
	.resetn(resetn),
	.stall(e_stall),
	.bubble(e_bubble),
	.d(d_q2),
	.q(e_q2)
);

pipeline_reg #(
	.WIDTH(32)
) E_ext_imm(
	.clk(clk),
	.resetn(resetn),
	.stall(e_stall),
	.bubble(e_bubble),
	.d(d_ext_imm),
	.q(e_ext_imm)
);

pipeline_reg #(
	.WIDTH(5)
) E_rn(
	.clk(clk),
	.resetn(resetn),
	.stall(e_stall),
	.bubble(e_bubble),
	.d(d_rn),
	.q(e_rn)
);

pipeline_reg #(
	.WIDTH(32),
	.BUBBLE_V(1)
) E_dbg_pc(
	.clk(clk),
	.resetn(resetn),
	.stall(e_stall),
	.bubble(e_bubble),
	.d(dbg_d_pc),
	.q(dbg_e_pc)
);

pipeline_reg #(
	.WIDTH(32),
	.BUBBLE_V(0)
) E_dbg_inst(
	.clk(clk),
	.resetn(resetn),
	.stall(e_stall),
	.bubble(e_bubble),
	.d(dbg_d_inst),
	.q(dbg_e_inst)
);

endmodule
