.text
.org 0

main:  jal init_vga
       jal init_seg
loop:  ori $1, $0, x
       lw $1, 0($1)
       ori $2, $0, y
       lw $2, 0($2)
       jal clean_ball
       or $1, $0, $29
       or $2, $0, $28
       jal draw_ball
       jal swap_buf
       addi $28, $28, 1
       bne $28, $27, loop
       j reset

delay:  lui $1, ((20000000/4/2/100)>>16)
        ori $1, $1, ((20000000/4/100/2)&0xffff)
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

clean_ball:    ori $25, $31, 0
               addi $24, $1, -4
               addi $23, $2, -4
               addi $22, $1, 5
               addi $21, $2, 5
clean_ball_l1: beq $22, $24, clean_ball_d1
clean_ball_l2: ori $1, $24, 0
               ori $2, $23, 0
               jal clean_point
               addi $23, $23, 1
               bne $23, $21, clean_ball_l2
               addi $23, $23, -9
               addi $24, $24, 1
               j clean_ball_l1
clean_ball_d1: jr $25

swap_buf:     lui $1, 0xf4ff
              ori $1, $1, 0xfffc
              sw $0, 0($1)
              jr $ra

draw_ball:    ori $25, $31, 0
              addi $24, $1, -2
              addi $23, $2, -2
              addi $22, $1, 3
              addi $21, $2, 3
draw_ball_l1: beq $22, $24, draw_ball_d1
draw_ball_l2: ori $1, $24, 0
              ori $2, $23, 0
              jal draw_point
              addi $23, $23, 1
              bne $23, $21, draw_ball_l2
              addi $23, $23, -5
              addi $24, $24, 1
              j draw_ball_l1
draw_ball_d1: jr $25

draw_point:   sll $2, $2, 10
              or $1, $1, $2
              add $1, $1, $30
              sw $1, 0($1)
              jr $ra
              
clean_point:  sll $2, $2, 10
              or $1, $1, $2
              add $1, $1, $30
              sw $0, 0($1)
              jr $ra

.data
x: .word 400
dx: .word -1
y: .word 300
dy: .word -1

.org 200
Stack:
