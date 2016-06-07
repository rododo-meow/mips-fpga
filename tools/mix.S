.text
.org 0x0

main:      ori $4, $0, data                  # address of data[0]
           addi $5, $0, (data_end - data)/4  # counter
           jal sum                           # call function
           or $30, $0, $8                    # save result to $30
           jy86 y86entry                     # jump to y86 code
mips_back: lui $1, 0xf300                    # load KEY IO addr
wait:      lw $2, 4($1)
           bne $2, $0, wait                  # loop until KEY1 is pressed
           or $1, $30, $0                    # get result back
           jal display                       # display
halt:      j halt                            # dead loop

sum:       add $8, $0, $0                    # sum
loop:      lw $9, 0($4)                      # load data
           addi $4, $4, 4                    # address + 4
           add $8, $8, $9                    # sum
           addi $5, $5, -1                   # counter - 1
           bne $5, $0, loop                  # finish?
           sll $2, $8, 0                     # move result to $v0
           jr $ra                            # return

display:   lui $2, 0xf000                    # load SEG IO addr
           sw $1, 24($2)
           jr $ra

.y86
y86entry: irmovl $0, %eax
          rrmovl %eax, %ebx
          rrmovl %eax, %ecx
          rrmovl %eax, %edx
          irmovl stack, %esp
          irmovl stack, %ebp
          call y86main
          jmips mips_back

y86main:  pushl %ebp
          rrmovl %esp, %ebp
          irmovl (data2_end - data2)/4, %eax
          pushl %eax
          irmovl data2, %edx
          pushl %edx
          call Sum
          call Display
          rrmovl %ebp, %esp
          popl %ebp
          ret

Sum:      pushl %ebp
          rrmovl %esp, %ebp
          mrmovl 8(%ebp), %ecx # ecx = Start
          mrmovl 12(%ebp), %edx # edx = Count
          xorl %eax,%eax # sum = 0
          andl %edx,%edx # test
          je End
Loop:     mrmovl (%ecx),%esi # get *Start
          addl %esi, %eax # add to sum
          irmovl $4, %ebx
          addl %ebx,%ecx # Start++
          irmovl $-1,%ebx
          addl %ebx,%edx # Count--
          jne Loop # Stop until Count == 0
End:      rrmovl %ebp, %esp
          popl %ebp
          ret

Display:  xorl %ebx, %ebx
          rmmovl %eax, 0xf0000018(%ebx)
          ret

.data
.org 0x50
data:
	.word 0xA3
	.word 0x27
	.word 0x79
	.word 0x115
data_end:
data2:
	.word 0x12
	.word 0x18279
	.word 0x123
	.word 0xaad
data2_end:

stack_top:
.org 0x100
stack:
