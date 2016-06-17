.lib "util.S"

.y86
switch_buf:
    pushl %eax
    irmovl $16, %eax
    rmmovl %eax, 0xf4fffffc-16(%eax)
    call delay
    popl %eax
    ret

.export switch_buf
