`define JMP_ALWAYS  4'h0
`define JMP_LE      4'h1
`define JMP_L       4'h2
`define JMP_E       4'h3
`define JMP_NE      4'h4
`define JMP_GE      4'h5
`define JMP_G       4'h6
`define JMP_MIPS_E  4'h7
`define JMP_MIPS_NE 4'h8
`define JMP_NEVER   4'hf

`define TARGET_IMM 2'b00
`define TARGET_Q1  2'b01
`define TARGET_MEM 2'b10

`define ALU_ADD  4'b0000
`define ALU_AND  4'b0001
`define ALU_XOR  4'b0010
`define ALU_SLL  4'b0011
`define ALU_SUB  4'b0100
`define ALU_OR   4'b0101
`define ALU_SUB4 4'b0110
`define ALU_SRL  4'b0111
`define ALU_RSUB 4'b1000
`define ALU_RSLL 4'b1101
`define ALU_SRA  4'b1111

`define Y86_OP_HALT   4'h0
`define Y86_OP_NOP    4'h1
`define Y86_OP_RRMOVL 4'h2
`define Y86_OP_IRMOVL 4'h3
`define Y86_OP_RMMOVL 4'h4
`define Y86_OP_MRMOVL 4'h5
`define Y86_OP_OPL    4'h6
`define Y86_OP_JXX    4'h7
`define Y86_OP_CALL   4'h8
`define Y86_OP_RET    4'h9
`define Y86_OP_PUSHL  4'ha
`define Y86_OP_POPL   4'hb
`define Y86_OP_JMIPS  4'hc
`define Y86_OP_IOPL   4'hd
`define Y86_OP_OPIL   4'he


`define Y86_FUNC_ADD  4'h0
`define Y86_FUNC_SUB  4'h1
`define Y86_FUNC_AND  4'h2
`define Y86_FUNC_XOR  4'h3
`define Y86_FUNC_OR   4'h4
`define Y86_FUNC_SLL  4'h5
`define Y86_FUNC_CMP  4'h6

`define Y86_FUNC_ALWAYS 4'h0
`define Y86_FUNC_LE     4'h1
`define Y86_FUNC_L      4'h2
`define Y86_FUNC_E      4'h3
`define Y86_FUNC_NE     4'h4
`define Y86_FUNC_GE     4'h5
`define Y86_FUNC_G      4'h6

`define R_ESP 5'd5