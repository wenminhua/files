        segment .data
a:      db      "This is fun"
b:      db      "This is not"
        segment .text
        global  main
        global  memcmp
memcmp:
        mov     rdi, rcx
        mov     rsi, rdx
        mov     rcx, r8
        repe    cmpsb
        cmp     rcx, 0
        jz      equal
        movzx   eax, byte [rdi-1]
        movzx   ecx, byte [rsi-1]
        sub     rax, rcx
        ret
equal:  xor     eax, eax
        ret

main:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 32
        lea     rcx, [a]   ; first parameter to memcmp     
        lea     rdx, [b]   ; second parameter
        mov     r8, 11     ; third parameter, count
        call    memcmp
        xor     eax, eax
        leave
        ret
