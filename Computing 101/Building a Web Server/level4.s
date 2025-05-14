.intel_syntax noprefix
.globl _start

.section .text

_start:
    #int socket(int domain, int type, int protocol);
    mov rdi, 0x2    #AF_INET - Domain socket value
    mov rsi, 0x1    #SOCK_STREAM - Type socket value
    mov rdx, 0x0    #DEFAUT - Protocol socket value
    mov rax, 0x29   #SYS_SOCKET - System socket value
    syscall

    #struct sockaddr_in {
    #    short sin_family;   // 2 bytes
    #    short sin_port;     // 2 bytes (big endian)
    #    int   sin_addr;     // 4 bytes
    #    char  sin_zero[8];  // 8 bytes
    #};

    #int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
    mov rdi, rax    #Socket file descriptor
    xor rax, rax
    push rax #sin_zero[8]
    mov eax, 0x0 #0.0.0.0 - sin_addr
    push rax
    mov word ptr [rsp], 0x2 #AF_INET - sin_family
    mov word ptr [rsp + 2], 0x5000 #htons(80) - sin_port (little endian)
    mov rsi, rsp
    mov rdx, 0x10 #length strunct sockaddr
    mov rax, 0x31 #SYS_BIND - System bind value
    syscall

    #int listen(int sockfd, int backlog);
    #rdi is holding the value of socket fd
    mov rsi, 0x0    #set number backlog = 0
    mov rax, 0x32   #SYS_LISTEN - System listen value
    syscall

    xor rdi, rdi
    mov rax, 60     #SYS_EXIT
    syscall

.section .data
