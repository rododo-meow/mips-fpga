.y86
read_key:
    irmovl $0xf3000000, %eax
    mrmovl 16(%eax), %eax
    ixorl $0xf, %eax
    ret

.export read_key
