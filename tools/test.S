.text
.set noat
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
finish: j finish                          # dead loop
sum:    add $8, $0, $0                    # sum
loop:   lw $9, 0($4)                      # load data
        addi $4, $4, 4                    # address + 4
        add $8, $8, $9                    # sum
        addi $5, $5, -1                   # counter - 1
        bne $5, $0, loop                  # finish?
        sll $2, $8, 0                     # move result to $v0
        jr $ra                            # return

.data
.org 0x50
data:
	.word 0xA3
	.word 0x27
	.word 0x79
	.word 0x115
data_end:
