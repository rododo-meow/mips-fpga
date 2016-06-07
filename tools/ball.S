.text
.org 0

main:  jal init_vga
       jal init_seg
       ori $29, $0, 400
       ori $27, $0, 600
reset: ori $28, $0, 0
loop:  jal clean_screen
       or $1, $0, $29
       or $2, $0, $28
       jal draw_point
       addi $28, $28, 1
       bne $28, $27, loop
       j reset

delay:  lui $1, ((20000000/4/40/2)>>16)
        ori $1, $1, ((20000000/4/40/2)&0xffff)
        ori $2, $0, 0
delay1: addi $2, $2, 1
        bne $2, $1, delay1
        jr $ra

init_vga: lui $30, 0xf400
          jr $ra

init_seg: lui $26, 0xf000
          jr $ra

print_num: sw $1, 24($26)
           jr $ra

clean_screen: addi $1, $30, (1024*600/32)
clean_loop:   sw $0, 0($1)
              addi $1, $1, -4
              bne $1, $30, clean_loop
              jr $ra

draw_point:   or $4, $0, $31
              sll $2, $2, 10
              or $1, $1, $2
              andi $2, $1, 31
              srl $1, $1, 5
              lui $3, 0x8000
              srlv $3, $3, $2
              add $1, $1, $30
              sw $3, 0($1)
              jr $4
              
.data
.org 200
Stack:
