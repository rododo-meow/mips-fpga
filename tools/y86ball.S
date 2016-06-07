.text
.org 0

main:  jy86 y86entry

.y86
y86entry: irmovl Stack, %esp
          rrmovl %esp, %ebp
          call y86main
dead:     jmp dead

y86main: irmovl $400, %eax
         irmovl $300, %ebx
         irmovl $-1, %ecx
         irmovl $-1, %edx
loop:    call clean_ball
         cmpi %eax, $0
         je flip_dx
         cmpi %eax, $800
         je flip_dx
         jmp skip_dx
flip_dx: isubl $0, %ecx
skip_dx:
         cmpi %ebx, $0
         je flip_dy
         cmpi %ebx, $600
         je flip_dy
         jmp skip_dy
flip_dy: isubl $0, %edx
skip_dy:
         addl %ecx, %eax
         addl %edx, %ebx
         call draw_ball
         call swap_buf
         call delay
         jmp loop

delay:   pushl %eax
         irmovl 20000000/2/4/100, %eax
delay_l: iaddl $-1, %eax
         jne delay_l
         popl %eax
         ret

clean_ball: pushl %ecx
            pushl %eax
            pushl %ebx
            irmovl $0, %ecx # get 0
            slli %ebx, $10
            orl %ebx, %eax # get base
            iaddl 1024*4, %eax # get end variable
            rrmovl %eax, %ebx
            iaddl -1024*9, %eax # set start variable
clean_loop: rmmovl %ecx, (0xf4000000-4)(%eax)
            rmmovl %ecx, (0xf4000000-3)(%eax)
            rmmovl %ecx, (0xf4000000-2)(%eax)
            rmmovl %ecx, (0xf4000000-1)(%eax)
            rmmovl %ecx, (0xf4000000-0)(%eax)
            rmmovl %ecx, (0xf4000000+1)(%eax)
            rmmovl %ecx, (0xf4000000+2)(%eax)
            rmmovl %ecx, (0xf4000000+3)(%eax)
            rmmovl %ecx, (0xf4000000+4)(%eax) # clean a row
            iaddl $1024, %eax # move to next row
            cmpl %eax, %ebx # got end?
            jne clean_loop
            popl %ebx
            popl %eax
            popl %ecx
            ret

swap_buf: pushl %eax
          irmovl $0, %eax
          rmmovl %eax, 0xf4fffffc(%eax)
          popl %eax
          ret

draw_ball: pushl %ecx
           pushl %eax
           pushl %ebx
           irmovl $1, %ecx # get 1
           slli %ebx, $10
           orl %ebx, %eax # get base
           iaddl 1024*3, %eax # get end variable
           rrmovl %eax, %ebx
           iaddl -1024*5, %eax # set start variable
draw_loop: rmmovl %ecx, (0xf4000000-2)(%eax)
           rmmovl %ecx, (0xf4000000-1)(%eax)
           rmmovl %ecx, (0xf4000000-0)(%eax)
           rmmovl %ecx, (0xf4000000+1)(%eax)
           rmmovl %ecx, (0xf4000000+2)(%eax) # draw a row
           iaddl $1024, %eax # move to next row
           cmpl %eax, %ebx # got end?
           jne draw_loop
           popl %ebx
           popl %eax
           popl %ecx
           ret

.data
.org 200
Stack:
