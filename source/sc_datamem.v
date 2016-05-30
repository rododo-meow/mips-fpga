module sc_datamem (addr,datain,dataout,we,mem_clk);
 
   input  [31:0]  addr;
   input  [31:0]  datain;
   
   input          we,mem_clk;
   output [31:0]  dataout;
   
   lpm_ram_dq_dram  dram(addr[7:2],mem_clk,datain,we,dataout );

endmodule 