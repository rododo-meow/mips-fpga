.define FREQ 20000000

.y86

delay:
    pushl %ebx
loop:
    orl %eax, %eax
    je delay_ret
    irmovl FREQ/1000/11, %ebx
loop2:
    iaddl $-1, %ebx
    jne loop2
    iaddl $-1, %eax
    jmp loop
delay_ret:
    popl %ebx
    ret

.export delay
