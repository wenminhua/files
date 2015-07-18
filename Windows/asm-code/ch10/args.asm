        segment .data
format  db      "%s",0x0a,0
        segment .text
        global  main            ; let the linker know about main
        extern  printf          ; resolve printf from libc
main:
        push    rbp             ; prepare stack frame for main
        mov     rbp, rsp
        sub     rsp, 48         ; space for shadow parameters
                                ; and 2 local variables
        mov     rbx, rdx        ; move argv to rbx
        mov     rdx, [rbx]      ; get first argv string
start_loop:
        lea     rcx, [format]
        mov     [rsp+32], rbx   ; save argv
        call    printf
        mov     rbx, [rsp+32]   ; restore argv
        add     rbx, 8          ; advance to the next pointer in argv
        mov     rdx, [rbx]      ; get next argv string
        cmp     rdx, 0          ; it's sad that mov doesn't also test
        jnz     start_loop      ; end with NULL pointer
end_loop:
        xor     eax, eax
        leave
        ret
