.y86

seg_display:
    pushl %ebx
    irmovl $0xf0000000+4*6, %ebx
    rmmovl %eax, (%ebx)
    popl %ebx
    ret

.export seg_display
