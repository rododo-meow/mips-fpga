`timescale 1ns/1ps

module testbench;
localparam FREQ = 1000 * 1000;

reg clock, mem_clk, resetn;
wire [31:0] pc, inst, aluout, memout;
wire imem_clk, dmem_clk;

sc_computer computer(resetn, clock, mem_clk, pc, inst, aluout, memout, imem_clk, dmem_clk);

initial begin
	resetn = 0;
	#1000 resetn = 1;
end

initial begin
	clock = 1;
	forever
		#(1000000000 / (FREQ * 2)) clock = ~clock;
end

initial begin
	mem_clk = 1;
	forever
		#(1000000000 / (FREQ * 4)) mem_clk = ~mem_clk;
end

endmodule