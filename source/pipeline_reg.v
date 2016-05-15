module pipeline_reg(clk, resetn, stall, bubble, d, q);
parameter WIDTH = 1;
parameter [WIDTH-1:0] BUBBLE_V = 0;
parameter [WIDTH-1:0] RESET_V = BUBBLE_V;

input clk, resetn, stall, bubble;
input [WIDTH-1:0] d;
output [WIDTH-1:0] q;

reg [WIDTH-1:0] r;
assign q = r;

always @(posedge clk, negedge resetn) begin
	if (!resetn)
		r <= RESET_V;
	else if (bubble)
		r <= BUBBLE_V;
	else if (!stall)
		r <= d;
end

endmodule
