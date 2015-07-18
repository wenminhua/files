        section .data
msg:    db      "Hello World!",0x0a,0

        section .text
        global  main
        extern  printf
main:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 32     ; shadow space for register parameters
        lea     rcx, [msg]  ; parameter 1 for printf
        call    printf
        xor     eax, eax    ; return 0
        leave
        ret
