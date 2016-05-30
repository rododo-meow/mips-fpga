module pipeline_D(
	input clk, resetn, d_stall, d_bubble,
	input [31:0] dbg_t_pc, t_imm,
	input [3:0] t_aluc, t_jmp,
	input [4:0] t_ra, t_rb, t_rn,
	input t_m2reg, t_wreg, t_wmem, t_useimm, t_need_ra, t_need_rb, t_setcond,
	input [47:0] dbg_t_inst,
	input [1:0] t_target_sel,
	output [31:0] dbg_d_pc, d_imm,
	output [3:0] d_aluc, d_jmp,
	output [4:0] d_ra, d_rb, d_rn, 
	output d_m2reg, d_wreg, d_wmem, d_useimm, d_need_ra, d_need_rb, d_setcond,
	output [47:0] dbg_d_inst,
	output [1:0] d_target_sel);

pipeline_reg #(
	.WIDTH(48),
	.BUBBLE_V(0)
) D_dbg_d_inst(
	.clk(clk),
	.resetn(resetn),
	.stall(d_stall),
	.bubble(d_bubble),
	.d(dbg_t_inst),
	.q(dbg_d_inst)
);

pipeline_reg #(
	.WIDTH(2),
	.BUBBLE_V(0)
) D_target_sel(
	.clk(clk),
	.resetn(resetn),
	.stall(d_stall),
	.bubble(d_bubble),
	.d(t_target_sel),
	.q(d_target_sel)
);

pipeline_reg #(
	.BUBBLE_V(0)
) D_setcond(
	.clk(clk),
	.resetn(resetn),
	.stall(d_stall),
	.bubble(d_bubble),
	.d(t_setcond),
	.q(d_setcond)
);

pipeline_reg D_useimm(
	.clk(clk),
	.resetn(resetn),
	.stall(d_stall),
	.bubble(d_bubble),
	.d(t_useimm),
	.q(d_useimm)
);

pipeline_reg #(
	.BUBBLE_V(0)
) D_need_ra(
	.clk(clk),
	.resetn(resetn),
	.stall(d_stall),
	.bubble(d_bubble),
	.d(t_need_ra),
	.q(d_need_ra)
);

pipeline_reg #(
	.BUBBLE_V(0)
) D_need_rb(
	.clk(clk),
	.resetn(resetn),
	.stall(d_stall),
	.bubble(d_bubble),
	.d(t_need_rb),
	.q(d_need_rb)
);

pipeline_reg #(
	.WIDTH(32)
) D_imm(
	.clk(clk),
	.resetn(resetn),
	.stall(d_stall),
	.bubble(d_bubble),
	.d(t_imm),
	.q(d_imm)
);

pipeline_reg #(
	.WIDTH(4),
	.BUBBLE_V(4'hf)
) D_jmp(
	.clk(clk),
	.resetn(resetn),
	.stall(d_stall),
	.bubble(d_bubble),
	.d(t_jmp),
	.q(d_jmp)
);

pipeline_reg #(
	.WIDTH(4)
) D_aluc(
	.clk(clk),
	.resetn(resetn),
	.stall(d_stall),
	.bubble(d_bubble),
	.d(t_aluc),
	.q(d_aluc)
);

pipeline_reg #(
	.WIDTH(5)
) D_ra(
	.clk(clk),
	.resetn(resetn),
	.stall(d_stall),
	.bubble(d_bubble),
	.d(t_ra),
	.q(d_ra)
);

pipeline_reg #(
	.WIDTH(5)
) D_rb(
	.clk(clk),
	.resetn(resetn),
	.stall(d_stall),
	.bubble(d_bubble),
	.d(t_rb),
	.q(d_rb)
);

pipeline_reg #(
	.WIDTH(5)
) D_rn(
	.clk(clk),
	.resetn(resetn),
	.stall(d_stall),
	.bubble(d_bubble),
	.d(t_rn),
	.q(d_rn)
);

pipeline_reg D_m2reg(
	.clk(clk),
	.resetn(resetn),
	.stall(d_stall),
	.bubble(d_bubble),
	.d(t_m2reg),
	.q(d_m2reg)
);

pipeline_reg #(
	.BUBBLE_V(0)
) D_wreg(
	.clk(clk),
	.resetn(resetn),
	.stall(d_stall),
	.bubble(d_bubble),
	.d(t_wreg),
	.q(d_wreg)
);

pipeline_reg #(
	.BUBBLE_V(0)
) D_wmem(
	.clk(clk),
	.resetn(resetn),
	.stall(d_stall),
	.bubble(d_bubble),
	.d(t_wmem),
	.q(d_wmem)
);

pipeline_reg #(
	.WIDTH(32),
	.BUBBLE_V(1)
) D_dbg_pc(
	.clk(clk),
	.resetn(resetn),
	.stall(d_stall),
	.bubble(d_bubble),
	.d(dbg_t_pc),
	.q(dbg_d_pc)
);

endmodule
