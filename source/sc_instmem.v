module sc_instmem (addr,instmem_dataout,clock);
   input  [31:0] addr;
   input         clock;
   output [7:0] instmem_dataout;   
   
   lpm_rom_irom irom (addr[9:0],clock,instmem_dataout);
endmodule 