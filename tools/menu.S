main: jy86 y86entry

.lib "print.S"
.lib "vga.S"
.lib "key.S"

.y86
y86entry:
    irmovl Stack, %esp
    call y86main
dead: jmp dead

y86main:
    call switch_buf
    call switch_buf
    call switch_buf
menu_loop:
    call read_key
    orl %eax, %eax
    jne menu_loop

    irmovl cur, %eax
    mrmovl (%eax), %eax
    call print_cube
    irmovl menu, %eax
    irmovl 10, %ebx
    irmovl 1, %ecx
menu_print_loop:
    mrmovl (%eax), %edx
    cmpi %edx, $0
    je menu_print_done
    pushl %eax
    rrmovl %edx, %eax
    pushl %ebx
    pushl %ecx
    call print_string
    popl %ecx
    popl %ebx
    iaddl 9, %ecx
    popl %eax
    iaddl $8, %eax
    jmp menu_print_loop
menu_print_done:
    call switch_buf

menu_wait_key:
    call read_key
    iandl $2, %eax
    je skip_move_down
    irmovl cur, %eax
    mrmovl (%eax), %eax
    cmpi %eax, (menu_end-menu)/8-2
    jge skip_move_down
    iaddl $1, %eax
    irmovl cur, %ebx
    rmmovl %eax, (%ebx)
    jmp menu_loop
skip_move_down:

    call read_key
    iandl $4, %eax
    je skip_move_up
    irmovl cur, %eax
    mrmovl (%eax), %eax
    cmpi %eax, $0
    jle skip_move_down
    iaddl $-1, %eax
    irmovl cur, %ebx
    rmmovl %eax, (%ebx)
    jmp menu_loop
skip_move_up:

    call read_key
    iandl $8, %eax
    je skip_enter
    irmovl cur, %eax
    mrmovl (%eax), %eax
    slli %eax, $3
    mrmovl 4(%eax), %eax
    call rcall
    jmp menu_loop
skip_enter:

    jmp menu_wait_key

rcall:
    pushl %eax
    ret

print_cube:
    pushl %ebx
    pushl %ecx
    irmovl $3, %ebx
    rrmovl %eax, %ecx
    slli %eax, $3
    addl %ecx, %eax
    iaddl $4, %eax
    slli %eax, $10
    orl %ebx, %eax
    rmmovl %eax, 0xf4000000-1024*1-1(%eax)
    rmmovl %eax, 0xf4000000-1024*1-0(%eax)
    rmmovl %eax, 0xf4000000-1024*1+1(%eax)
    rmmovl %eax, 0xf4000000-1024*0-1(%eax)
    rmmovl %eax, 0xf4000000-1024*0-0(%eax)
    rmmovl %eax, 0xf4000000-1024*0+1(%eax)
    rmmovl %eax, 0xf4000000+1024*1-1(%eax)
    rmmovl %eax, 0xf4000000+1024*1-0(%eax)
    rmmovl %eax, 0xf4000000+1024*1+1(%eax)
    popl %ecx
    popl %ebx
    ret

.extern HelloWorldEntry
.data
menu:
    .word HelloWorld
    .word HelloWorldEntry
    .word BallGame
    .word BallGameEntry
    .word Ball
    .word BallEntry
    .word About
    .word AboutEntry
    .word 0
    .word 0
menu_end:

cur: .word 0

HelloWorld: .string "hello_world"
BallGame: .string "ball_game"
Ball: .string "ball"
About: .string "about"

    .zero 100
Stack:
