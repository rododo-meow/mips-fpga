`include "common.v"
module alu (a,b,aluc,s);
   input [31:0] a,b;
   input [3:0] aluc;
   output [31:0] s;
   reg [31:0] s;
   always @ (a or b or aluc) 
      begin                                   // event
         case (aluc)
             `ALU_ADD:  s = a + b;              //x000 ADD
             `ALU_SUB:  s = a - b;              //x100 SUB
             `ALU_AND:  s = a & b;              //x001 AND
             `ALU_OR:   s = a | b;              //x101 OR
             `ALU_XOR:  s = a ^ b;              //x010 XOR        
             `ALU_SLL:  s = a << b;             //0011 SLL: rd <- (rt << sa)
             `ALU_SRL:  s = a >> b;             //0111 SRL: rd <- (rt >> sa) (logical)
             `ALU_SRA:  s = $signed(a) >>> b;   //1111 SRA: rd <- (rt >> sa) (arithmetic)
				 `ALU_SUB4: s = a - 4;
				 `ALU_RSUB: s = b - a;
             default: s = 0;
         endcase       
      end      
endmodule 