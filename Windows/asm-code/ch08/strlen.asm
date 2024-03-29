        segment .data
s       db      "Hello world!",0

        segment .text
        global  main
        global  strlenx
strlenx:
        cld                 ; prepare to increment rdi in scasb
        mov     rdi, rcx  
        mov     rcx, -1     ; maximum number of iterations for repne
        xor     al, al      ; will scan for 0
        repne   scasb       ; repeatedly scan for 0
        mov     rax, -2     ; we started at -1 and ended up 1 past the end
        sub     rax, rcx    ; the length is in rax
        ret

main:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 32
        lea     rcx, [s]
        call    strlenx
        xor     eax, eax
        leave
        ret
