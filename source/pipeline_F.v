module pipeline_F(clk, resetn, f_stall, next_pc, f_pc);
input clk, resetn, f_stall;
input [31:0] next_pc;
output [31:0] f_pc;

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

endmodule
