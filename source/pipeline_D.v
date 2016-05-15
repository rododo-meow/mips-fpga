module pipeline_D(
	input clk, resetn, d_stall, d_bubble,
	input [31:0] f_inst, f_p4, dbg_f_pc,
	output [31:0] d_inst, d_p4, dbg_d_pc);

pipeline_reg #(
	.WIDTH(32),
	.BUBBLE_V(0)
) D_inst(
	.clk(clk),
	.resetn(resetn),
	.stall(d_stall),
	.bubble(d_bubble),
	.d(f_inst),
	.q(d_inst)
);

pipeline_reg #(
	.WIDTH(32),
	.BUBBLE_V(0)
) D_p4(
	.clk(clk),
	.resetn(resetn),
	.stall(d_stall),
	.bubble(d_bubble),
	.d(f_p4),
	.q(d_p4)
);

pipeline_reg #(
	.WIDTH(32),
	.BUBBLE_V(1)
) D_dbg_pc(
	.clk(clk),
	.resetn(resetn),
	.stall(d_stall),
	.bubble(d_bubble),
	.d(dbg_f_pc),
	.q(dbg_d_pc)
);

endmodule
