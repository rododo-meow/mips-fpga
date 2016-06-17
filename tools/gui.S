.y86

draw_ball: slli %ebx, $10
           orl %ebx, %eax # get base
           iaddl 1024*3, %eax # get end variable
           rrmovl %eax, %ebx
           iaddl -1024*5, %eax # set start variable
draw_loop: rmmovl %ebx, (0xf4000000-2)(%eax)
           rmmovl %ebx, (0xf4000000-1)(%eax)
           rmmovl %ebx, (0xf4000000-0)(%eax)
           rmmovl %ebx, (0xf4000000+1)(%eax)
           rmmovl %ebx, (0xf4000000+2)(%eax) # draw a row
           iaddl $1024, %eax # move to next row
           cmpl %eax, %ebx # got end?
           jne draw_loop
           ret

draw_pad:      slli %ebx, $10
               orl %ebx, %eax # get base
               rrmovl %eax, %ebx
               addl %ecx, %ebx # get end variable
draw_pad_loop: rmmovl %ecx, (0xf4000000+1024*0)(%eax)
               rmmovl %ecx, (0xf4000000+1024*1)(%eax)
               rmmovl %ecx, (0xf4000000+1024*2)(%eax)
               iaddl $1, %eax
               cmpl %eax, %ebx
               jne draw_pad_loop
               ret

draw_border:
    pushl %eax
    irmovl $0xf4000000, %eax
loop1:
    rmmovl %eax, (%eax)
    rmmovl %eax, 1024*599(%eax)
    iaddl $1, %eax
    cmpi %eax, 0xf4000000+800
    jl loop1

    irmovl $0xf4000000, %eax
loop2:
    rmmovl %eax, (%eax)
    rmmovl %eax, 799(%eax)
    iaddl $1024, %eax
    cmpi %eax, 0xf4000000+1024*600
    jl loop2

    popl %eax
    ret

.export draw_ball
.export draw_pad
.export draw_border
