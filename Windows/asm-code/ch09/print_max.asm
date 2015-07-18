    segment .text
    global  main
    extern  printf

; void print_max ( long a, long b )
; {
a   equ  0
b   equ  8
print_max:
    push rbp;         ; normal stack frame
    mov  rbp, rsp
;   leave space for a, b and max and shadow
    sub  rsp, 64
;   int max;
max equ  16
    mov  [rsp+a], rcx ; save a
    mov  [rsp+b], rdx ; save b
;   max = a;
    mov  [rsp+max], rcx
;   if ( b > max ) max = b;
    cmp  rdx, rcx
    jng  skip
    mov  [rsp+max], rdx
skip:
;   printf ( "max(%ld,%ld) = %ld\n",
;            a, b, max );
    segment .data
fmt db   'max(%ld,%ld) = %ld',0xa,0
    segment .text
    lea  rcx, [fmt]
    mov  rdx, [rsp+a]
    mov  r8, [rsp+b]
    call printf
; }
    leave
    ret

main:
    push rbp
    mov  rbp, rsp
    sub  rsp, 32     ; shadow space for register parameters
;   print_max ( 100, 200 );
    mov  rcx, 200    ; first parameter
    mov  rdx, 200    ; second parameter
    call print_max
    xor  eax, eax    ; to return 0
    leave
    ret
