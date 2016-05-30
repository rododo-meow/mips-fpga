module pipeline_T(
	input clk, resetn, t_stall, t_bubble,
	input [47:0] f_inst,
	input f_mode,
	input [31:0] dbg_f_pc, f_next_inst_pc,
	output [47:0] t_inst,
	output t_mode,
	output [31:0] dbg_t_pc, t_next_inst_pc);
	
pipeline_reg #(
	.WIDTH(48),
	.BUBBLE_V(48'b0)
) T_inst(
	.clk(clk),
	.resetn(resetn),
	.stall(t_stall),
	.bubble(t_bubble),
	.d(f_inst),
	.q(t_inst)
);

pipeline_reg #(
	.BUBBLE_V(0)
) T_mode(
	.clk(clk),
	.resetn(resetn),
	.stall(t_stall),
	.bubble(t_bubble),
	.d(f_mode),
	.q(t_mode)
);

pipeline_reg #(
	.WIDTH(32),
	.BUBBLE_V(32'b1)
) T_dbg_t_pc(
	.clk(clk),
	.resetn(resetn),
	.stall(t_stall),
	.bubble(t_bubble),
	.d(dbg_f_pc),
	.q(dbg_t_pc)
);

pipeline_reg #(
	.WIDTH(32)
) T_next_inst_pc_pc(
	.clk(clk),
	.resetn(resetn),
	.stall(t_stall),
	.bubble(t_bubble),
	.d(f_next_inst_pc),
	.q(t_next_inst_pc)
);

endmodule
