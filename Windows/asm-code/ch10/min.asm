        segment .text
        extern  printf, rand, malloc, atoi
        global  main, create, fill, min

;       array = create ( size );
create:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 32
        imul    rcx, 4
        call    malloc
        leave
        ret

;       fill ( array, size );
fill:
.array  equ     32
.size   equ     40
.i      equ     48
        push    rbp
        mov     rbp, rsp
        sub     rsp, 64
        mov     [rsp+.array], rcx
        mov     [rsp+.size], rdx
        xor     ecx, ecx
.more   mov     [rsp+.i], rcx
        call    rand
        mov     rcx, [rsp+.i]
        mov     rdi, [rsp+.array]
        mov     [rdi+rcx*4], eax
        inc     rcx
        cmp     rcx, [rsp+.size]
        jl      .more
        leave
        ret

;       print ( array, size );
print:
.array  equ     32
.size   equ     40
.i      equ     48
        push    rbp
        mov     rbp, rsp
        sub     rsp, 64
        mov     [rsp+.array], rcx
        mov     [rsp+.size], rdx
        xor     ebx, ebx
        mov     [rsp+.i], rbx
        segment .data
.format:
        db      "%10d",0x0a,0
        segment .text
.more   lea     rcx, [.format]
        mov     rdx, [rsp+.array]
        mov     rbx, [rsp+.i]
        mov     edx, [rdx+rbx*4]
        mov     [rsp+.i], rbx
        call    printf
        mov     rbx, [rsp+.i]
        inc     rbx
        mov     [rsp+.i], rbx
        cmp     rbx, [rsp+.size]
        jl      .more
        leave
        ret

;       x = min ( array, size );
min:
        mov     eax, [rcx]
        mov     rbx, 1
.more   mov     r8d, [rcx+rbx*4]
        cmp     r8d, eax
        cmovl   eax, r8d
        inc     rcx
        cmp     rcx, rsi
        jl      .more
        ret

main:
.array  equ     32
.size   equ     40
        push    rbp
        mov     rbp, rsp
        sub     rsp, 48

;       set default size
        mov     ebx, 10
        mov     [rsp+.size], rbx

;       check for argv[1] providing a size
        cmp     ecx, 2
        jl      .nosize
        mov     rcx, [rdx+8]
        call    atoi
        mov     [rsp+.size], rax
.nosize:

;       create the array
        mov     rcx, [rsp+.size]
        call    create
        mov     [rsp+.array], rax

;       fill the array with random numbers
        mov     rcx, rax
        mov     rdx, [rsp+.size]
        call    fill

;       if size <= 20 print the array
        mov     rdx, [rsp+.size]
        cmp     rdx, 20
        jg      .toobig
        mov     rcx, [rsp+.array]
        call    print
.toobig:

;       print the minimum
        segment .data
.format:
        db      "min: %ld",0xa,0
        segment .text
        mov     rcx, [rsp+.array]
        mov     rdx, [rsp+.size]
        call    min
        lea     rcx, [.format]
        mov     rdx, rax
        call    printf

        leave
        ret
