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

    #int accept(int sockfd, struct sockaddr *_Nullable restrict addr,
    #              socklen_t *_Nullable restrict addrlen);
    #rdi is holding the value of socket fd
    mov rsi, 0    #sockaddr = NULL
    mov rdx, 0x0    #addrlen = NULL
    mov rax, 0x2b   #SYS_ACCEPT - System accept value
    syscall

    #ssize_t read(int fd, void buf[.count], size_t count);
    mov r14, rax    #clientfd value
    mov rdi, r14    
    sub rsp, 0x400
    mov rsi, rsp
    mov rdx, 0x400
    xor rax, rax
    syscall

    #ssize_t read(int fd, void buf[.count], size_t count);
    mov rdi, r14    #clientfd
    #HTTP/1.0 200 OK\r\n\r\n -> hex
    #48 54 54 50 2f 31 2e 30 | 20 32 30 30 20 4f 4b 0d | 0a 0d 0a 00
    mov rax, 0x00000000000a0d0a
    push rax
    mov rax, 0x0d4b4f2030303220
    push rax
    mov rax, 0x302e312f50545448
    push rax
    mov rsi, rsp    #address response
    mov rdx, 0x13   #length response string = 19 -> hex = 0x13
    mov rax, 0x1    #SYS_WRITE - System write value
    syscall

    #int close(int fd);
    mov rdi, r14    #clientfd
    mov rax, 0x3    #SYS_CLOSE - System close value
    syscall

    xor rdi, rdi
    mov rax, 60     #SYS_EXIT
    syscall

.section .data
