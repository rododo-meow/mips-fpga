.y86

read_sw:
    irmovl $0xf2000000, %eax
    mrmovl 4*10(%eax), %eax
    ret

.export read_sw
