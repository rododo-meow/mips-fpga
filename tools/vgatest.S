.text
.org 0
main: lui $1, 0xf400
      lui $2, 0xffff
      ori $2, $2, 0xffff
      lui $3, 0xf4ff
      ori $3, $3, 0xfffc
loop: sw $2, 0($1)
      sw $2, 0($3)
      jal delay
      addi $1, $1, 1 
      j loop

wait_key: lui $30, 0xf300
wait1:    lw $29, 4($30)
          bne $29, $0, wait1
          jr $ra

delay:      lui $28, ((5000000/20/2)>>16)
            ori $27, $0, 0
delay_loop: addi $27, $27, 1
            bne $27, $28, delay_loop
            jr $ra
