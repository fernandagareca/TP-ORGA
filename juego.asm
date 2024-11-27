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
        mov     rdx,    0
        mov     rcx,    %2
opcionesJugada:
        cmp     rcx,    0
        je      finOpciones

        lea     rdi,    [%1 + rdx]      ; Dirección del vector destino
        sub     rsp,    8 
        call    puts              ; Llamar a strcpy para copiar la cadena
        add     rsp,    8 
        dec     rcx
        inc     rdx
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
        jg      %%fin_tablero_espejo
        mov     al, [%1 + rdi]   ; inicio
        mov     dl, [%1 + rsi]   

        mov     [%2 + rdi], dl
        mov     [%2 + rsi], al

        inc     rdi
        dec     rsi
        jmp     %%espejo

%%fin_tablero_espejo:
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
        opcion_salir            db      "[q] = para salir",0
        opcion_arriba           db      "podes moverte arriba",0
        opcion_abajo            db      "podes moverte abajo ",0
        opcion_derecha          db      "podes moverte a la derecha",0
        opcion_izquierda        db      "podes moverte a la izquierda ",0
        opcion_inf_izquierda    db      "podes moverte a la diagonal inferior derecha ",0
        opcion_inf_derecha      db      "podes moverte a la diagonal inferior izquierda ",0
        opcion_sup_derecha      db      "podes moverte a la diagonal superior derecha ",0
        opcion_sup_izquierda    db      "podes moverte a la diagonal superior izquierda ",0
        cant_opciones           dq      0
        formato_Caracter        db      "%c",0
        primer_oficial          db      "O"
        segundo_oficial         db      "O"
        pos_vacia               db      "."
        soldados                times           24        db      "X" ; vector de 24 soldados
        dirrecciones_invalidas  db      0,1,5,6,7,8,12,13,35,36,40,41,42,43,47,48
        invalido                db      " ",0


section .bss
        i                               resb    1
        j                               resb    1
        opcion_ingresada                resb    1
        opciones                        resq    7
        tablero                         resb    CANT_FIL*CANT_COL ; tablero a llenar
        tablero_espejo                  resb    49
        tablero_rotacion_derecha        resb    49
        tablero_rotacion_izquierda      resb    49
        x                               resb    1
        y                               resb    1



%macro imprimir_opcion 1
        mov     rdi,%1       
        sub     rsp,    8 
        call    puts           
        add     rsp,    8 
%endmacro
;imprimir pos validas para oficial=> 
;%1 : fil,%2:col 
%macro imprimir_pos_validas 2

        mov     BYTE    [i],    -1    
        mov     BYTE    [j],    -1
        mov     r12B,    %1    ;fila
        mov     r13B,    %2      ;col
        mov     [x],     r12B
        mov     [y],     r13B
%%filas:
        cmp     BYTE    [i],    1
        jg      %%fin             ;fin del analisis

        mov     [x],     r12B
        mov     r8B,     [i]
        add     [x],    r8B
%%columnas:
        mov     [y],     r13B
        mov     r8B,     [j]
        add     [y],    r8B

        calcular_direccion_de_una_posicion       x,y,CANT_COL    ;pos en al
        mov     rcx,    17
%%posiciones_invalidas:
        movzx   r8,     BYTE [dirrecciones_invalidas+rcx]
        cmp     rax,    r8 
        je      %%continuar
        loop    %%posiciones_invalidas 
        ; la pos es valida 
        mov     dl,    [pos_vacia]
        cmp     BYTE    [matriz+ rax],          dl           
        je      %%pos_valida
%%continuar:
        inc     BYTE    [j]
        cmp     BYTE    [j],    1
        jle     %%columnas        ; si j es <=1 volvemos a repetir con j+1
        inc     BYTE    [i]
        mov     BYTE    [j],    -1
        jmp      %%filas           ; si j >1, incrementamos i ,y volvemos a filas


%%pos_valida:
        cmp     [x],    r12B
        jl      fila_menor
        je      fila_igual
        jg      fila_mayor

fila_mayor:
        cmp     [y],    r13B
        jg      poner_inf_derecha
        je      poner_inf_abajo
        jl      poner_inf_izquierda

fila_igual:
        cmp     [y],    r13B
        jl      poner_izquierda
        jg      poner_derecha

fila_menor:
        cmp     [y],    r13B
        jg      poner_sup_derecha
        je      poner_sup_arriba
        jl      poner_sup_izquierda

poner_inf_derecha:
        imprimir_opcion     opcion_inf_derecha
        jmp     %%continuar
poner_inf_abajo:
        imprimir_opcion     opcion_abajo
        jmp     %%continuar

poner_inf_izquierda:
        imprimir_opcion     opcion_inf_izquierda
        jmp     %%continuar

poner_derecha:
        imprimir_opcion     opcion_derecha
        jmp     %%continuar

poner_izquierda:
        imprimir_opcion     opcion_izquierda
        jmp     %%continuar

poner_sup_izquierda:
        imprimir_opcion     opcion_sup_izquierda
        jmp     %%continuar

poner_sup_arriba:
        imprimir_opcion     opcion_arriba
        jmp     %%continuar

poner_sup_derecha:
        imprimir_opcion     opcion_sup_derecha
        jmp     %%continuar

%%fin:
%endmacro
section .text
main:


        rotar_derecha           i,j,CANT_FIL,CANT_COL,matriz,tablero_rotacion_derecha
        imprimir_matriz         formato,saltoLinea,tablero_rotacion_derecha,CANT_COL,CANT_FIL,i,j
        imprimir_matriz         formato, saltoLinea,matriz,CANT_COL,CANT_FIL,i,j
        tablero_vertical        matriz, tablero_espejo
        imprimir_matriz         formato, saltoLinea,tablero_espejo,CANT_COL,CANT_FIL,i,j
        
        
        imprimir_opcion      cadena_pedir
        imprimir_opcion      opcion_salir

        imprimir_pos_validas    7,3       ; bucas las posiciones validas para las coordenadas (x,y) en este cado (7,3)

        sub     rsp,    8 
        mov     rdi,    formato_Caracter
        mov     rsi,     opcion_ingresada
        call    scanf           ; espera a que ingreses una opcion
        add     rsp,    8 
        ejecutar_intruccion     opcion_ingresada, opcion_salir
final:
        ret





