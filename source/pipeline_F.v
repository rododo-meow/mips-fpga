module pipeline_F(
	input clk, resetn, f_stall, 
	input [31:0] next_pc,
	input next_mode,
	output [31:0] f_pc,
	output f_mode);

pipeline_reg #(
	.WIDTH(32),
	.RESET_V(0)
) F_pc(
	.clk(clk),
	.resetn(resetn),
	.stall(f_stall),
	.bubble(1'b0),
	.d(next_pc),
	.q(f_pc)
);

pipeline_reg #(
	.RESET_V(0)
) F_mode(
	.clk(clk),
	.resetn(resetn),
	.stall(f_stall),
	.bubble(1'b0),
	.d(next_mode),
	.q(f_mode)
);

endmodule
