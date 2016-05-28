module pipeline_F(
	input clk, resetn, f_stall, 
	input [31:0] next_pc,
	input next_mode,
	input [2:0] next_off,
	input [47:0] _f_inst,
	output [31:0] f_pc,
	output [2:0] f_off,
	output f_mode,
	output [47:0] f_inst);

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

pipeline_reg #(
	.WIDTH(3),
	.RESET_V(0)
) F_off(
	.clk(clk),
	.resetn(resetn),
	.stall(f_stall),
	.bubble(1'b0),
	.d(next_off),
	.q(f_off)
);

pipeline_reg #(
	.WIDTH(48),
	.RESET_V(0)
) F_inst(
	.clk(clk),
	.resetn(resetn),
	.stall(f_stall),
	.bubble(1'b0),
	.d(_f_inst),
	.q(f_inst)
);

endmodule
