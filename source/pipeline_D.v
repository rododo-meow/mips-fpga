module pipeline_D(
	input clk, resetn, d_stall, d_bubble,
	input [31:0] t_inst, t_next_inst_pc, dbg_t_pc,
	output [31:0] d_inst, d_next_inst_pc, dbg_d_pc);

pipeline_reg #(
	.WIDTH(32),
	.BUBBLE_V(0)
) D_inst(
	.clk(clk),
	.resetn(resetn),
	.stall(d_stall),
	.bubble(d_bubble),
	.d(t_inst),
	.q(d_inst)
);

pipeline_reg #(
	.WIDTH(32),
	.BUBBLE_V(0)
) D_next_inst_pc(
	.clk(clk),
	.resetn(resetn),
	.stall(d_stall),
	.bubble(d_bubble),
	.d(t_next_inst_pc),
	.q(d_next_inst_pc)
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
