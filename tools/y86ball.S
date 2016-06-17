.define SPEED 3

.lib "key.S"
.lib "vga.S"
.lib "gui.S"

.y86
BallEntry:
         irmovl $400, %eax
         irmovl $300, %ebx
         irmovl -SPEED, %ecx
         irmovl -SPEED, %edx
loop:    cmpi %eax, $0
         jle flip_dx
         cmpi %eax, $800
         jge flip_dx
         jmp skip_dx
flip_dx: isubl $0, %ecx
skip_dx:
         cmpi %ebx, $0
         jle flip_dy
         cmpi %ebx, $600
         jge flip_dy
         jmp skip_dy
flip_dy: isubl $0, %edx
skip_dy:
         addl %ecx, %eax
         addl %edx, %ebx
         pushl %eax
         pushl %ebx
         call draw_ball
         call draw_border
         call switch_buf
         call read_key
         iandl $2, %eax
         popl %ebx
         popl %eax
         je loop
exit_loop:
         call read_key
         iandl $2, %eax
         jne exit_loop
         ret

.export BallEntry
