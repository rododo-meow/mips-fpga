.lib "print.S"
.lib "key.S"

.y86
.extern print_string
.extern read_key
HelloWorldEntry:
    irmovl HelloWorld, %eax
    irmovl $400, %ebx
    irmovl $300, %ecx
    call print_string
    irmovl $0, %eax
    rmmovl %eax, 0xf4fffffc(%eax)
wait_key:
    call read_key
    iandl $2, %eax
    je wait_key
    ret

.export HelloWorldEntry

.data
HelloWorld:
    .string "Hello, World!"
