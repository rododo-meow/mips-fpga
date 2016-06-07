.define SCREEN_X 800
.define SCREEN_Y 600
.define PAD_Y 570
.define BALL_RADIUS 3
.define PAD_LENGTH 60
.define SPEED 200
.define PAD_SPEED 2

.text
.org 0

main:  jy86 y86entry

.y86
y86entry: irmovl Stack, %esp
          rrmovl %esp, %ebp
          call y86main
dead:     jmp dead

y86main: irmovl SCREEN_X / 2, %eax
         irmovl SCREEN_Y / 2, %ebx
         irmovl $-1, %ecx
         irmovl $-1, %edx
         call clean_screen
         call swap_buf
         call clean_screen
loop:    call clean_ball
         pushl %eax
         rrmovl %esi, %eax
         call clean_pad
         popl %eax

         cmpi %eax, $0
         je flip_dx
         cmpi %eax, SCREEN_X
         je flip_dx
         jmp skip_dx
flip_dx: isubl $0, %ecx
skip_dx:

         cmpi %ebx, $0
         je flip_dy
         jmp skip_dy
flip_dy: isubl $0, %edx
skip_dy:

         cmpi %ebx, PAD_Y - BALL_RADIUS
         jne skip_check_pad
         cmpl %eax, %esi
         jl skip_check_pad
         rrmovl %esi, %edi
         iaddl PAD_LENGTH, %edi
         cmpl %eax, %edi
         jg skip_check_pad
         isubl $0, %edx
skip_check_pad:

         cmpi %ebx, SCREEN_Y - BALL_RADIUS
         jne skip_dead
         call gameover
skip_dead:

         addl %ecx, %eax
         addl %edx, %ebx
         call draw_ball

         pushl %eax
         cmpi %esi, SCREEN_X - PAD_LENGTH
         jg skip_move_pad_right
         irmovl $0xf3000004, %edi
         mrmovl 0(%edi), %edi
         cmpi %edi, $1
         je skip_move_pad_right
         iaddl PAD_SPEED, %esi
skip_move_pad_right:

         cmpi %esi, 0
         jle skip_move_pad_left
         irmovl $0xf3000008, %edi
         mrmovl 0(%edi), %edi
         cmpi %edi, $1
         je skip_move_pad_left
         iaddl -PAD_SPEED, %esi
skip_move_pad_left:

         rrmovl %esi, %eax
         call draw_pad
         popl %eax
         call swap_buf
         call delay
         jmp loop

gameover: jmp gameover

delay:   pushl %eax
         irmovl int(20000000/12*(1.0/SPEED)), %eax
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

clean_pad:      pushl %ecx
                pushl %eax
                pushl %ebx
                irmovl $0, %ecx # get 0
                iorl (PAD_Y << 10), %eax # get base
                rrmovl %eax, %ebx
                iaddl PAD_LENGTH+PAD_SPEED*2, %ebx # get end variable
                iaddl -PAD_SPEED * 2, %eax
clean_pad_loop: rmmovl %ecx, (0xf4000000+1024*0)(%eax)
                rmmovl %ecx, (0xf4000000+1024*1)(%eax)
                rmmovl %ecx, (0xf4000000+1024*2)(%eax)
                iaddl $1, %eax
                cmpl %eax, %ebx
                jne clean_pad_loop
                popl %ebx
                popl %eax
                popl %ecx
                ret

draw_pad:      pushl %ecx
               pushl %eax
               pushl %ebx
               irmovl $1, %ecx # get 0
               iorl (PAD_Y << 10), %eax # get base
               rrmovl %eax, %ebx
               iaddl PAD_LENGTH, %ebx # get end variable
draw_pad_loop: rmmovl %ecx, (0xf4000000+1024*0)(%eax)
               rmmovl %ecx, (0xf4000000+1024*1)(%eax)
               rmmovl %ecx, (0xf4000000+1024*2)(%eax)
               iaddl $1, %eax
               cmpl %eax, %ebx
               jne draw_pad_loop
               popl %ebx
               popl %eax
               popl %ecx
               ret

clean_screen:      pushl %eax
                   pushl %ebx
                   pushl %ecx
                   irmovl $0, %eax
                   irmovl $0xf4000000, %ebx
                   irmovl 0xf4000000+1024*600, %ecx
clean_screen_loop: rmmovl %eax, 0(%ebx)
                   iaddl $1, %ebx
                   cmpl %ebx, %ecx
                   jne clean_screen_loop
                   popl %ecx
                   popl %ebx
                   popl %eax
                   ret
.data
.org 200
Stack:
