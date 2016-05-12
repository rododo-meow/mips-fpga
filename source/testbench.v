`timescale 1ns/1ps

module testbench;
localparam FREQ = 1000 * 1000;

reg clock, mem_clk, resetn;
reg [3:0] KEY;
reg [9:0] SW;
wire [31:0] pc, inst, aluout, memout;
wire imem_clk, dmem_clk;
wire [9:0] LED;
wire [6:0] SEG0, SEG1, SEG2, SEG3, SEG4, SEG5;

sc_computer computer(resetn, clock, mem_clk, pc, inst, aluout, memout, imem_clk, dmem_clk,
	KEY, SW, SEG0, SEG1, SEG2, SEG3, SEG4, SEG5, LED);

initial begin
	resetn = 1;
	#100 resetn = 0;
	#900 resetn = 1;
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