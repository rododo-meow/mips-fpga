module pipeline_T(
	input clk, resetn, t_stall, t_bubble,
	input [47:0] f_inst,
	input f_mode,
	output [47:0] t_inst,
	output t_mode, t_isbubble);
	
pipeline_reg #(
	.WIDTH(48)
) T_inst(
	.clk(clk),
	.resetn(resetn),
	.stall(t_stall),
	.bubble(t_bubble),
	.d(f_inst),
	.q(t_inst)
);

pipeline_reg #(
	.BUBBLE_V(1)
) T_isbubble(
	.clk(clk),
	.resetn(resetn),
	.stall(t_stall),
	.bubble(t_bubble),
	.d(0),
	.q(t_isbubble)
);

endmodule
