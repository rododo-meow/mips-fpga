.text
.org 0x0

main:   ori $4, $0, data                  # address of data[0]
        addi $5, $0, (data_end - data)/4  # counter
call:   jal sum                           # call function
        sw $2, 0($4)                      # store result
        lui $1, 0xf000
        andi $3, $2, 0xf
        sw $3, 0($1)
        srl $3, $2, 4
        andi $3, $3, 0xf
        sw $3, 4($1)
        srl $3, $2, 8
        andi $3, $3, 0xf
        sw $3, 8($1)
        srl $3, $2, 12
        andi $3, $3, 0xf
        sw $3, 12($1)
        lw $9, 0($4)                      # check sw
        sub $8, $9, $4                    # sub: $8 <- $9 - $4
        addi $5, $0, 3                    # counter
loop2:  addi $5, $5, -1                   # counter - 1
        ori $8, $5, 0xffff                # zero-extend: 0000ffff
        xori $8, $8, 0x5555               # zero-extend: 0000aaaa
        addi $9, $0, -1                   # sign-extend: ffffffff
        andi $10, $9, 0xffff              # zero-extend: 0000ffff
        or $6, $10, $9                    # or: ffffffff
        xor $8, $10, $9                   # xor: ffff0000
        and $7, $10, $6                   # and: 0000ffff
        beq $5, $0, shift                 # if $5 = 0, goto shift
        j loop2                           # jump loop2
shift:  addi $5, $0, -1                   # $5 = ffffffff
        sll $8, $5, 15                    # <<15 = ffff8000
        sll $8, $8, 16                    # <<16 = 80000000
        sra $8, $8, 16                    # >>16 = ffff8000 (arith)
        srl $8, $8, 15                    # >>15 = 0001ffff (logic)
finish: lui $1, 0xf300                    # load KEY IO addr
wait:   lw $2, 4($1)
        bne $2, $0, wait                  # loop until KEY1 is pressed
        jy86 y86main                      # jump to y86 code
sum:    add $8, $0, $0                    # sum
loop:   lw $9, 0($4)                      # load data
        addi $4, $4, 4                    # address + 4
        add $8, $8, $9                    # sum
        addi $5, $5, -1                   # counter - 1
        bne $5, $0, loop                  # finish?
        sll $2, $8, 0                     # move result to $v0
        jr $ra                            # return

.y86
y86entry: irmovl $0, %eax
          rrmovl %eax, %ebx
          rrmovl %eax, %ecx
          rrmovl %eax, %edx
          irmovl stack, %esp
          irmovl stack, %ebp
          call y86main
dead:     jmp dead

y86main:  pushl %ebp
          rrmovl %ebp, %esp
          irmovl data2_end - data2, %eax
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
          rmmovl %eax, 0xf0000012(%ebx)
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
