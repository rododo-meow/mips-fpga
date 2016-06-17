.lib "print.S"

.y86

AboutEntry:
    irmovl Author, %eax
    irmovl $400, %ebx
    irmovl $300, %ecx
    call print_string

    irmovl Love, %eax
    irmovl $400, %ebx
    irmovl $310, %ecx
    call print_string

    call switch_buf

wait_key:
    call read_key
    iandl $2, %eax
    je wait_key
wait_key2:
    call read_key
    iandl $2, %eax
    jne wait_key2

    ret

.export AboutEntry

.data
Author: .string "Author: rododo"
Love: .string "Love Croky!"
