global main
extern printf

section .data
        formato         db      ' %c ', 0
        saltoLinea      db      10, 0
        matriz          db      ' ', ' ', 'X', 'X', 'X', ' ', ' '  ; Fila 1
                        db      ' ', ' ', 'X', 'X', 'X', ' ', ' '  ; Fila 2
                        db      'X', 'X', 'X', 'X', 'X', 'X', 'X'  ; Fila 3
                        db      'X', 'X', 'X', 'X', 'X', 'X', 'X'  ; Fila 4
                        db      'X', 'X', '.', '.', '.', 'X', 'X'  ; Fila 5
                        db      ' ', ' ', '.', '.', 'O', ' ', ' '  ; Fila 6
                        db      ' ', ' ', 'O', '.', '.', ' ', ' '  ; Fila 7

        CANT_FIL        equ     7
        CANT_COL        equ     7

section .bss
        i       resq    1
        j       resq    1

section .text
main:
        mov     QWORD [i],      1
        mov     QWORD [j],      1

inicio:
        cmp     QWORD [i],      CANT_FIL          ; Verificar si se llegó al final de las filas
        jg      fin

        cmp     QWORD [j],      CANT_COL         ; Verificar si se llegó al final de las columnas
        jg      cambioFila

        mov     rax, [i]              ; rax = fila
        dec     rax                   ; fila - 1
        imul    rax, CANT_COL        ; (fila - 1) * CANT_COL
        add     rax, [j]              ; (fila - 1) * CANT_COL + columna
        dec     rax                   ; índice base 0
        movzx   rdx, BYTE [matriz + rax] ; Cargar carácter desde matriz

        ; Imprimir el carácter
        sub     rsp,    8
        mov     rdi,    formato
        mov     rsi,    rdx
        xor     rax,    rax              ; Limpiar rax para printf
        call    printf
        add     rsp,    8

        inc     QWORD   [j]
        jmp     inicio

cambioFila:
                                ; Imprimir salto de línea
        sub     rsp,    8
        mov     rdi,    saltoLinea
        xor     rax,    rax              ; Limpiar rax para printf
        call    printf
        add     rsp,    8


        inc     QWORD   [i]           ; Ir a la siguiente fila
        mov     QWORD   [j],    1          ; Reiniciar columna
        jmp     inicio

fin:
        ret
