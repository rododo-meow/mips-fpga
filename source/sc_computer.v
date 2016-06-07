/////////////////////////////////////////////////////////////
//                                                         //
// School of Software of SJTU                              //
//                                                         //
/////////////////////////////////////////////////////////////

module sc_computer (resetn,clock,
	KEY,SW,SEG0,SEG1,SEG2,SEG3,SEG4,SEG5,LED,
	vga_clk, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);
   
   input resetn,clock;
	input [3:0] KEY;
	input [9:0] SW;
	output [9:0] LED;
	output [6:0] SEG0, SEG1, SEG2, SEG3, SEG4, SEG5;
   wire [31:0] instmem_addr,aluout,cpu_memout;
   wire imem_clk,dmem_clk;
   wire   [31:0] data;
   wire          cpu_wmem, wmem; // all these "wire"s are used to connect or interface the cpu,dmem,imem and so on.
	wire   [31:0] memout;
	wire [7:0] instmem_dataout;
	input vga_clk;
	output [7:0] VGA_R, VGA_G, VGA_B;
	output VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK;
   
   sc_cpu cpu (
		.clock(clock),
		.resetn(resetn),
		.instmem_dataout(instmem_dataout),
		.mem_dataout(cpu_memout),
		.instmem_addr(instmem_addr),
		.wmem(cpu_wmem),
		.mem_addr(aluout),
		.mem_datain(data));          // CPU module.
   sc_instmem  imem (instmem_addr,instmem_dataout,~clock);                  // instruction memory.
   sc_datamem  dmem (aluout,data,memout,wmem,~clock); // data memory.
	sc_hub hub (resetn, aluout,data,cpu_memout,cpu_wmem,~clock,wmem,memout,
		LED, SEG0, SEG1, SEG2, SEG3, SEG4, SEG5, SW, KEY,
		vga_clk, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);

endmodule



