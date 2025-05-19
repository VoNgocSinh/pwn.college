.intel_syntax noprefix
.globl _start

.section .text
_start:

.socket:
    #int socket(int domain, int type, int protocol);

    mov rdi, 0x2    #AF_INET - Domain socket value
    mov rsi, 0x1    #SOCK_STREAM - Type socket value
    mov rdx, 0x0    #DEFAUT - Protocol socket value
    mov rax, 0x29   #SYS_SOCKET - System socket value
    syscall
    mov r12, rax    #Socket file descriptor

.bind:
    #struct sockaddr_in {
    #    short sin_family;   // 2 bytes
    #    short sin_port;     // 2 bytes (big endian)
    #    int   sin_addr;     // 4 bytes
    #    char  sin_zero[8];  // 8 bytes
    #};

    #int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);

    mov rdi, r12    #Socket file descriptor
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

.listen:
    #int listen(int sockfd, int backlog);
    mov rdi, r12    #Socket file descriptor
    mov rsi, 0x0    #Set number backlog = 0
    mov rax, 0x32   #SYS_LISTEN - System listen value
    syscall

.accept:
    #int accept(int sockfd, struct sockaddr *_Nullable restrict addr,
    #              socklen_t *_Nullable restrict addrlen);
    mov rdi, r12    #Socket file descriptor
    mov rsi, 0      #Sockaddr = NULL
    mov rdx, 0x0    #Addrlen = NULL
    mov rax, 0x2b   #SYS_ACCEPT - System accept value
    syscall
    mov r13, rax

.fork:
    mov rax, 0x39
    syscall
    cmp rax, 0x0
    je .child_process
    jg .parent_process
    jmp .exit

.parent_process:
    mov rax, 0x3
    mov rdi, r13
    syscall
    jmp .accept

.child_process:
    mov rax, 0x3
    mov rdi, r12
    syscall
    jmp .read

.read:
    #ssize_t read(int fd, void buf[.count], size_t count);
    mov rdi, r13
    sub rsp, 0x400
    mov rsi, rsp
    mov rdx, 0x400
    xor rax, rax
    syscall
    lea r14, [rsp+5]    #skip "POST "
    xor rax, rax

.getPath:
    cmp byte ptr [r14+rax], 0x20    #check space char
    je .open
    inc rax
    jmp .getPath

.open:
    mov byte ptr [r14+rax], 0x00
    mov rdi, r14
    mov rsi, 65
    mov rax, 0x2
    mov rdx, 0777
    syscall
    mov r15, rax    #file descriptor opened

.get_address_string:
    cmp dword ptr [r14], 0x0a0d0a0d    #check space char
    je .count_char2
    inc r14
    jmp .get_address_string

.count_char2:
    cmp byte ptr [r14+rax+0x4], 0x00
    je .write_file
    inc rax
    jmp .count_char2

.write_file:
    add r14, 0x4
    #ssize_t write(int fd, void buf[.count], size_t count);
    mov rdi, r15
    mov rsi, r14
    mov rdx, rax
    mov rax, 0x1
    syscall
    xor rax, rax

.close_file:
    #int close(int fd);
    mov rdi, r15    #clientfd
    mov rax, 0x3    #SYS_CLOSE - System close value
    syscall

.write1:
    #ssize_t write(int fd, void buf[.count], size_t count);
    mov rdi, r13    #clientfd
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
    add rsp, 0x18

.count_char:
    cmp byte ptr [rsp + rax], 0x00
    je .write
    inc rax
    jmp .count_char

.write:
    #ssize_t write(int fd, const void buf[.count], size_t count);
    mov rdi, r13    #clientfd
    mov rsi, rsp    #address response
    mov rdx, rax
    mov rax, 0x1    #SYS_WRITE - System write value
    syscall
    jmp .exit

.close:
    #int close(int fd);
    mov rdi, r13    #clientfd
    mov rax, 0x3    #SYS_CLOSE - System close value
    syscall

.loop:
    jmp .accept     #multiple requests

.exit:
    xor rdi, rdi
    mov rax, 60     #SYS_EXIT
    syscall

.section .data
