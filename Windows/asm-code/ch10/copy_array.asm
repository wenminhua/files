        segment .data
a:      dd      1, 2, 3, 4, 5
        segment .bss
b:      resd    10
        segment .text
        global  main
main:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 32
        lea     rcx, [b]
        lea     rdx, [a]
        mov     r8d, 5
        call    copy_array
        xor     eax, eax
        leave
        ret
copy_array:
        xor     ebx, ebx
more:   mov     eax, [rdx+4*rbx]
        mov     [rcx+4*rbx], eax
        add     rbx, 1
        cmp     rbx, r8
        jne     more
        xor     eax, eax
        ret
