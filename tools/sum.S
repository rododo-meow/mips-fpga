.text
.set noat
.org 0

main:             lui $16, 0xf300  # ADDR_KEY
                  lui $17, 0x0     # For accumulate
                  lui $18, 0xf000  # ADDR_SEG
                  lui $19, 0xf200  # ADDR_SW
                  lui $1, 0
                  jal print_num
                  jal wait_for_release
loop:             jal wait_for_key
                  jal read_sw
                  add $17, $17, $1
                  ori $1, $17, 0
                  jal print_num
                  jal wait_for_release
                  j loop
                  
read_sw:          lw $1, 40($19)
                  jr $ra

wait_for_key:     lw $1, 4($16)
                  bne $0, $1, wait_for_key
                  jr $ra

wait_for_release: lw $1, 4($16)
                  beq $0, $1, wait_for_release
                  jr $ra

print_num:        sw $1, 24($18)
                  jr $ra
