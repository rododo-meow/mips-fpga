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

`define ALU_ADD 4'b0000
`define ALU_SUB 4'b0100
`define ALU_AND 4'b0001
`define ALU_OR  4'b0101
`define ALU_XOR 4'b0010
`define ALU_SLL 4'b0011
`define ALU_SRL 4'b0111
`define ALU_SRA 4'b1111