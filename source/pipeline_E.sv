module pipeline_E(
	input clk, resetn, e_stall, e_bubble,
	input d_wreg, d_m2reg, d_wmem, d_setcond, d_do_jmp_in_m, d_mode,
	input [3:0] d_aluc, 
	input [31:0] d_alua, d_alub, d_data, dbg_d_pc,
	input [47:0] dbg_d_inst,
	input [4:0] d_rn,
	output e_wreg, e_m2reg, e_wmem, e_setcond, e_do_jmp_in_m, e_mode,
	output [3:0] e_aluc, 
	output [31:0] e_alua, e_alub, e_data, dbg_e_pc,
	output [47:0] dbg_e_inst,
	output [4:0] e_rn);
	
pipeline_reg E_mode(
	.clk(clk),
	.resetn(resetn),
	.stall(e_stall),
	.bubble(e_bubble),
	.d(d_mode),
	.q(e_mode)
);

pipeline_reg #(
	.BUBBLE_V(0)
) E_setcond(
	.clk(clk),
	.resetn(resetn),
	.stall(e_stall),
	.bubble(e_bubble),
	.d(d_setcond),
	.q(e_setcond)
);

pipeline_reg #(
	.BUBBLE_V(0)
) E_do_jmp_in_m(
	.clk(clk),
	.resetn(resetn),
	.stall(e_stall),
	.bubble(e_bubble),
	.d(d_do_jmp_in_m),
	.q(e_do_jmp_in_m)
);

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
) E_alua(
	.clk(clk),
	.resetn(resetn),
	.stall(e_stall),
	.bubble(e_bubble),
	.d(d_alua),
	.q(e_alua)
);

pipeline_reg #(
	.WIDTH(32)
) E_alub(
	.clk(clk),
	.resetn(resetn),
	.stall(e_stall),
	.bubble(e_bubble),
	.d(d_alub),
	.q(e_alub)
);

pipeline_reg #(
	.WIDTH(32)
) E_data(
	.clk(clk),
	.resetn(resetn),
	.stall(e_stall),
	.bubble(e_bubble),
	.d(d_data),
	.q(e_data)
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
	.WIDTH(48),
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
