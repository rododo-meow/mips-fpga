.define SCREEN_X 800
.define SCREEN_Y 600
.define PAD_Y 570
.define BALL_RADIUS 3
.define PAD_LENGTH 60
.define SPEED 2
.define PAD_SPEED 2

.lib "vga.S"
.lib "key.S"
.lib "gui.S"

.y86
BallGameEntry:
         irmovl SCREEN_X / 2, %eax
         irmovl SCREEN_Y / 2, %ebx
         irmovl -SPEED, %ecx
         irmovl -SPEED, %edx
loop:    cmpi %eax, $0
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
         jge skip_check_pad
         cmpi %ebx, PAD_Y - BALL_RADIUS - SPEED
         jl skip_check_pad
         cmpl %eax, %esi
         jl skip_check_pad
         rrmovl %esi, %edi
         iaddl PAD_LENGTH, %edi
         cmpl %eax, %edi
         jg skip_check_pad
         isubl $0, %edx
skip_check_pad:

         cmpi %ebx, SCREEN_Y - BALL_RADIUS - SPEED
         jle skip_dead
         call gameover
         ret
skip_dead:

         addl %ecx, %eax
         addl %edx, %ebx
         pushl %eax
         pushl %ebx
         pushl %ecx
         call draw_ball

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
         irmovl PAD_Y, %ebx
         irmovl PAD_LENGTH, %ecx
         call draw_pad
         popl %ecx
         popl %ebx
         popl %eax
         call draw_border
         call switch_buf
         jmp loop

gameover:
         call read_key
         iandl $2, %eax
         je gameover
         ret

.export BallGameEntry

