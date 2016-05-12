.text
.set noat
.org 0

main:             lui $16, 0xf300  # ADDR_KEY
                  lui $17, 0x0     # For accumulate
                  lui $18, 0xf000  # ADDR_SEG
                  lui $19, 0xf200  # ADDR_SW
                  lui $1, 0
                  jal print_num
loop:             jal wait_for_release
                  jal get_key
                  ori $2, $0, 0xd
                  beq $2, $1, do_add
                  ori $2, $0, 0xb
                  beq $2, $1, do_or
                  j loop
do_add:           jal read_sw
                  add $17, $17, $1
                  ori $1, $17, 0
                  jal print_num
                  j loop
do_or:            jal read_sw
                  or $17, $17, $1
                  ori $1, $17, 0
                  jal print_num
                  j loop
                  
read_sw:          lw $1, 40($19)
                  jr $ra

get_key:          ori $2, $0, 0xf
get_key_loop:     lw $1, 16($16)
                  beq $2, $1, get_key_loop
                  jr $ra

wait_for_release: ori $2, $0, 0xf
_loop:            lw $1, 16($16)
                  bne $2, $1, _loop
                  jr $ra

print_num:        sw $1, 24($18)
                  jr $ra
