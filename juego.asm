global main
extern printf;    imprimir_matriz formato, saltoLinea,matriz,CANT_COL,CANT_FIL,i,j
extern scanf
extern puts
extern strcpy
extern strcmp
;cancular direccion : %1 : fil %2 :col, %3: cantidad_columnas
%macro calcular_direccion_de_una_posicion 3
        movzx   rax,    BYTE [%1]              ; rax = fila (ampliar a 64 bits para cálculos)
        dec     al                          ; fila - 1
        imul    rax,    %3                     ; (fila - 1) * CANT_COL
        movzx   rbx,    BYTE [%2]              ; rbx = columna (ampliar a 64 bits)
        add     rax,    rbx                    ; (fila - 1) * CANT_COL + columna
        dec     al                          ; índice base 0
%endmacro
; imprime la matriz => 
;%1 : fomato para imprimir, %2: cadena de salto de linea, %3:matriz  %4:cantidad de columnas %5: cantidad de filas %6: indice fil fila %7: indice col 
%macro imprimir_matriz 7
        mov     BYTE [%6],      1           ; Inicializar fila (1 byte)
        mov     BYTE [%7],      1           ; Inicializar columna (1 byte)

%%inicio:
        cmp     BYTE [%6],      %5          ; Verificar si se llegó al final de las filas
        jg      %%fin

        cmp     BYTE [%7],      %4          ; Verificar si se llegó al final de las columnas
        jg      %%cambioFila

        calcular_direccion_de_una_posicion      %6,%7,%4

        movzx   rdx, BYTE [%3 + rax]        ; Cargar carácter desde matriz

        ; Imprimir el carácter
        sub     rsp,    8
        mov     rdi,    %1
        mov     rsi,    rdx                    ; El carácter se pasa en rsi
        xor     rax,    rax                    ; Limpiar rax para printf
        call    printf
        add     rsp,    8

        inc     BYTE [%7]
        jmp     %%inicio

%%cambioFila:
        ; Imprimir salto de línea
        sub     rsp,    8
        mov     rdi,    %2
        xor     rax,    rax                    ; Limpiar rax para printf
        call    printf
        add     rsp,    8

        inc     BYTE    [%6]                   ; Ir a la siguiente fila
        mov     BYTE    [%7],   1                ; Reiniciar columna
        jmp     %%inicio

%%fin:
%endmacro

; imprime las opciones que hay => en %1 esta el vector, en %2 esta la cantidad de elementos, %3: cadena para pedir
%macro mostrarOpciones 3
        sub     rsp,    8 
        mov     rdi,    %3
        call    puts
        add     rsp,    8 
        mov     rbx,    %2
opcionesJugada:
        cmp     rbx,    0
        jle      finOpciones

        lea     rdi,    [%1]      ; Dirección del vector destino
        sub     rsp,    8 
        call    puts              ; Llamar a strcpy para copiar la cadena
        add     rsp,    8 
        dec     rbx
        jmp     opcionesJugada

finOpciones:
%endmacro
;ejecuta la instruccion ingresada => %1 : opcion ingresada, %2 : opcion
%macro ejecutar_intruccion 2

        mov     rdi,    %1
        mov     rsi,    %2
        sub     rsp,    8 
        call    strcmp
        add     rsp,    8 
        cmp     rax,     0; son iguales
        je      final
%endmacro
;voltea la matriz hacia abajo %1 matriz fuente, %2: matriz destino
%macro tablero_vertical 2
        mov     rdi,    0       ;direccion inicio
        mov     rsi,    48     ;direccion final 
%%espejo:
        cmp     rdi,   rsi
        jg      %%fin
        mov     al, [%1 + rdi]   ; inicio
        mov     dl, [%1 + rsi]   

        mov     [%2 + rdi], dl
        mov     [%2 + rsi], al

        inc     rdi
        dec     rsi
        jmp     %%espejo

%%fin:
%endmacro   

;rotar derecha =>  %1:i,%2:j,%3:CANT_FIL,%4:CANT_COL,%5:matriz,%6:tablero_rotacion_derecha
%macro rotar_derecha 6
        mov     BYTE [%1],      1
        mov     BYTE [%2],      1
%%inicio:
        cmp     BYTE [%1],      %3          
        jg      %%aca

        cmp     BYTE [%2],      %4        
        jg      %%cambioFila


        calcular_direccion_de_una_posicion  %2,%1,%4
        movzx   rdx, BYTE [%5 + rax]   


        calcular_direccion_de_una_posicion %1,%2, %4
        mov     [%6 + rax], rdx  

        inc     BYTE [%2]                   
        jmp     %%inicio                     

%%cambioFila:
        inc     BYTE [%1]                  
        mov     BYTE [%2],    1            
        jmp     %%inicio
%%aca:
%endmacro
;--------------------------


section .data
        formato                 db      ' %c ', 0
        saltoLinea              db      10, 0
        matriz                  db      ' ', ' ', 'X', 'X', 'X', ' ', ' '  ; Fila 1
                                db      ' ', ' ', 'X', 'X', 'X', ' ', ' '  ; Fila 2
                                db      'X', 'X', 'X', 'X', 'X', 'X', 'X'  ; Fila 3
                                db      'X', 'X', 'X', 'X', 'X', 'X', 'X'  ; Fila 4
                                db      'X', 'X', '.', '.', '.', 'X', 'X'  ; Fila 5
                                db      ' ', ' ', '.', '.', 'O', ' ', ' '  ; Fila 6
                                db      ' ', ' ', 'O', '.', '.', ' ', ' '  ; Fila 7

        CANT_FIL        equ     7
        CANT_COL        equ     7
        LONG_ELEM       equ     1
        cadena_pedir            db      "Seleccione una opcion",10,0
        opcion_salir            db      "[q] = para salir",10,0
        posicion                dq      0
        formato_Caracter        db      "%c",0
        primer_oficial          db      "O"
        segundo_oficial         db      "O"
        soldados                times           24        db      "X" ; vector de 24 soldados
        dirrecciones_invalidas  dq      0,8,40,48,56,67,104,112,280,288,328,336,344,352,384,392
        invalido                db      " ",0


section .bss
        i                               resb    1
        j                               resb    1
        opcion_ingresada                resb    1
        opciones                        resb    2
        tablero                         resb    CANT_FIL*CANT_COL ; tablero a llenar
        tablero_espejo                  resb    49
        tablero_rotacion_derecha        resb    49
        tablero_rotacion_izquierda      resb    49

section .text
main:
        rotar_derecha           i,j,CANT_FIL,CANT_COL,matriz,tablero_rotacion_derecha
        imprimir_matriz         formato,saltoLinea,tablero_rotacion_derecha,CANT_COL,CANT_FIL,i,j
        imprimir_matriz         formato, saltoLinea,matriz,CANT_COL,CANT_FIL,i,j
        tablero_vertical        matriz, tablero_espejo
        imprimir_matriz         formato, saltoLinea,tablero_espejo,CANT_COL,CANT_FIL,i,j


        lea     rdi, [opciones]      ; Dirección del vector destino
        lea     rsi, [opcion_salir]       ; Dirección de la cadena fuente
        sub     rsp,    8 
        call    strcpy              ; Llamar a strcpy para copiar la cadena
        add     rsp,    8 
        mov     rbx,    1
        mostrarOpciones         opciones, 1, cadena_pedir
        sub     rsp,    8 
        mov     rdi,    formato_Caracter
        mov     rsi,     opcion_ingresada
        call    scanf
        add     rsp,    8 
        ejecutar_intruccion     opcion_ingresada, opcion_salir
final:
        ret

