main: jy86 y86entry

.lib "print.S"

.y86
y86entry:
    irmovl Stack, %esp
    call y86main
dead: jmp dead

.extern print_string
y86main:
    irmovl HelloWorld, %eax
    irmovl $400, %ebx
    irmovl $300, %ecx
    call print_string
    irmovl $0, %eax
    rmmovl %eax, 0xf4fffffc(%eax)
    ret

.data
    .zero 60
Stack:

HelloWorld:
    .string "Hello, World!"
