; Calculates and prints Fibonacci numbers (Fn)
; Prints numbers 1 - 47 (largest 32bit Fn that fits)
; Build:
;   nasm -felf32 fib.asm
;   ld -m elf32_i386 fib.o -o fib

global  _start
section .text

_start:
    mov ecx, 48         ; Initialize loop counter
.loop:
    mov ebx, 48         ; Calculate which Fn will be computed
    sub ebx, ecx        ; Takes into account the reversed nature
    push    ebx         ; Pass the parameter in on the stack
    call    .fib        ; Initial call to fib(n)
    add esp, 4          ; Remove the parameter from the stack
    push    ecx         ; Save the counter between calls
    push    eax         ; Print the number
    call    print_num
    add esp, 4
    pop ecx             ; Restore the loop counter
    loop    .loop       ; Loop until 0

    mov eax, 0x01       ; sys_exit(int error)
    xor ebx, ebx        ; error = 0 (success)
    int 0x80            ; syscall

; int fib (int n)
; Returns the n'th Fn
; fib(n) =  0                   if n <= 0
;           1                   if n == 1
;           fib(n-1) + fib(n-2) otherwise
.fib:
    push    ebp         ; Setup stack frame
    mov ebp, esp
    push    ebx         ; Save needed registers

    xor eax, eax
    mov ebx, [ebp + 8]  ; Get the parameter
    cmp ebx, 1          ; Test for base cases
    jl  .return
    mov eax, 1
    je  .return
    dec ebx             ; Calculate fib(n-1)
    push    ebx
    call    .fib
    add esp, 4
    push    eax         ; Save the first result
    dec ebx             ; Calculate fib(n-2)
    push    ebx
    call    .fib
    add esp, 4
    pop edx             ; Add the first to the second
    add eax, edx
.return:
    pop ebx             ; Restore modified registers
    mov esp, ebp        ; Tear down stack frame and return
    pop ebp
    ret

; void print_num (int n)
; Prints an integer and newline
print_num:
    push    ebp
    mov ebp, esp
    sub esp, 11         ; Save space for digits and newline
    push    ebx

    mov BYTE [ebp - 1], 0x0A    ; Set the newline at the end
    mov DWORD [ebp - 5], 0  ; Clear the digit buffer
    mov DWORD [ebp - 9], 0
    mov WORD [ebp - 11], 0

    lea ecx, [ebp - 1]  ; Save a pointer to after the buffer
    mov eax, [ebp + 8]  ; Get the parameter
    mov ebx, DWORD 10   ; Divisor
.loop:
    dec ecx             ; Move pointer to next digit
    xor edx, edx
    div ebx             ; Extract one digit, quot in eax, rem in edx
    add dl, 0x30        ; Convert remainder to ascii
    mov [ecx], dl       ; Save the ascii form
    cmp eax, 0          ; Loop until all digits have been converted
    jg  .loop

    mov eax, 0x04       ; sys_write(int fd, char **buf, int len)
    mov ebx, 1          ; stdout
    mov edx, ebp        ; Calculate the length
    sub edx, ecx        ; address after newline - address of first digit
    int 0x80

    pop ebx
    mov esp, ebp
    pop ebp
    ret