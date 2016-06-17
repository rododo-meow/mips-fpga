.define SCREEN_X 800
.define SCREEN_Y 600
.define PAD_Y 570
.define BALL_RADIUS 3
.define PAD_LENGTH 60
.define SPEED 2
.define PAD_SPEED 4

.lib "vga.S"
.lib "key.S"
.lib "gui.S"
.lib "seg.S"
.lib "sw.S"

.y86
BallGameEntry:
         irmovl score, %ebx
         irmovl $0, %eax
         rmmovl %eax, (%ebx)
         call seg_display
         irmovl SCREEN_X / 2, %eax
         irmovl SCREEN_Y / 2, %ebx
         irmovl -SPEED, %ecx
         irmovl -SPEED, %edx
loop:    cmpi %eax, BALL_RADIUS
         jle flip_dx
         cmpi %eax, SCREEN_X - BALL_RADIUS
         jge flip_dx
         jmp skip_dx
flip_dx: isubl $0, %ecx
skip_dx:

         cmpi %ebx, BALL_RADIUS
         jle flip_dy
         jmp skip_dy
flip_dy: isubl $0, %edx
skip_dy:

         pushl %ecx
         pushl %edx
         pushl %eax
         call read_sw
         iandl $1, %eax
         popl %eax
         je skip_speedup
         addl %ecx, %ecx
         addl %edx, %edx
skip_speedup:

         cmpi %ebx, PAD_Y - BALL_RADIUS
         jge skip_check_pad
         pushl %ebx
         addl %edx, %ebx
         cmpi %ebx, PAD_Y - BALL_RADIUS
         popl %ebx
         jl skip_check_pad
         cmpl %eax, %esi
         jl skip_check_pad
         rrmovl %esi, %edi
         iaddl PAD_LENGTH, %edi
         cmpl %eax, %edi
         jg skip_check_pad
         mrmovl 0(%esp), %edi
         isubl $0, %edi
         rmmovl %edi, 0(%esp)

         # add score
         irmovl score, %edi
         mrmovl (%edi), %edi
         iaddl $1, %edi
         pushl %eax
         rrmovl %edi, %eax
         call seg_display
         irmovl score, %eax
         rmmovl %edi, (%eax)
         popl %eax
skip_check_pad:

         cmpi %ebx, SCREEN_Y - BALL_RADIUS
         jle skip_dead
         call gameover
         popl %edx
         popl %ecx
         ret
skip_dead:

         addl %ecx, %eax
         addl %edx, %ebx
         pushl %eax
         pushl %ebx
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
         popl %ebx
         popl %eax
         popl %edx
         popl %ecx
         call draw_border
         call switch_buf
         jmp loop

gameover:
         call read_key
         iandl $2, %eax
         je gameover
         ret

.export BallGameEntry

.data
score: .word 0
