.intel_syntax noprefix
.globl _start

.section .text

_start:
    mov rdi, 0x2    #AF_INET - Domain socket value
    mov rsi, 0x1    #SOCK_STREAM - Type socket value
    mov rdx, 0x0    #DEFAUT - Protocol socket value
    mov rax, 0x29   #SYS_SOCKET - System socket value 
    syscall

    xor rdi, rdi
    mov rax, 60     #SYS_EXIT
    syscall

.section .data
