/////////////////////////////////////////////////////////////
//                                                         //
// School of Software of SJTU                              //
//                                                         //
/////////////////////////////////////////////////////////////

module sc_computer (resetn,clock,mem_clk,pc,inst,aluout,cpu_memout,imem_clk,dmem_clk,KEY,SW,SEG0,SEG1,SEG2,SEG3,SEG4,SEG5,LED);
   
   input resetn,clock,mem_clk;
	input [3:0] KEY;
	input [9:0] SW;
	output [9:0] LED;
	output [6:0] SEG0, SEG1, SEG2, SEG3, SEG4, SEG5;
   output [31:0] pc,inst,aluout,cpu_memout;
   output        imem_clk,dmem_clk;
   wire   [31:0] data;
   wire          cpu_wmem, wmem; // all these "wire"s are used to connect or interface the cpu,dmem,imem and so on.
	wire   [31:0] memout;
   
   sc_cpu cpu (clock,resetn,inst,cpu_memout,pc,cpu_wmem,aluout,data);          // CPU module.
   sc_instmem  imem (pc,inst,clock,mem_clk,imem_clk);                  // instruction memory.
   sc_datamem  dmem (aluout,data,memout,wmem,dmem_clk); // data memory.
	sc_hub hub (resetn, aluout,data,cpu_memout,cpu_wmem,clock,mem_clk,dmem_clk,wmem,memout);

endmodule



