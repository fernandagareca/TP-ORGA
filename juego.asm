global main
extern printf;    imprimir_matriz formato, saltoLinea,matriz,CANT_COL,CANT_FIL,i,j
extern scanf
extern puts
extern strcpy
extern strcmp
extern  system
;cancular direccion : %1 : fil %2 :col, %3: cantidad_columnas
%macro calcular_direccion_de_una_posicion 3
        movzx   rax,    BYTE [%1]              ; rax = fila (ampliar a 64 bits para cálculos)
        dec     al                          ; fila - 1
        imul    rax,    %3                     ; (fila - 1) * CANT_COL
        movzx   rbx,    BYTE [%2]              ; rbx = columna (ampliar a 64 bits)
        add     rax,    rbx                    ; (fila - 1) * CANT_COL + columna
        dec     al                          ; índice base 0
%endmacro


;--------------------------


section .data
        linea_arriba                   db      " ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓",0
        linea_abajo                   db      "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛",0
        linea_vertical          db      " ┃",0
        formato                 db      '  %c  ', 0
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
        cadena_pedir            db      " Seleccione una opcion ",10,0
        opcion_incorrecta       db      " La opcion ingresada en invalida",0
        tablero_normal          db      " ➊  para un tablero normal",0
        tablero_izquierda       db      " ➋  para un tablero rotado 90° a la izquierda ",0
        tablero_derecha         db      " ➌  para un tablero rotado 90° a la derecha ",0
        tablero_abajo           db      " ➍  para un tablero rotado 180° ",0
        opcion_salir            db      " 🅷  para salir",0
        opcion_arriba           db      " 🆆  Para moverte arriba",0
        opcion_abajo            db      " 🆂  Para moverte abajo ",0
        opcion_derecha          db      " 🅳  Para moverte a la derecha",0
        opcion_izquierda        db      " 🅰  Para moverte a la izquierda ",0
        opcion_inf_izquierda    db      " 🆇  Para moverte a la diagonal inferior derecha ",0
        opcion_inf_derecha      db      " 🆉  Para moverte a la diagonal inferior izquierda ",0
        opcion_sup_derecha      db      " 🅴  Para moverte a la diagonal superior derecha ",0
        opcion_sup_izquierda    db      " 🆀  Para moverte a la diagonal superior izquierda ",0
        formato_Caracter        db      " %c",0
        primer_oficial          db      "O"
        segundo_oficial         db      "O"
        pos_vacia               db      "."
        cmd_clear               db      "clear",0
        dirrecciones_invalidas  db      0,1,5,6,7,8,12,13,35,36,40,41,42,43,47,48


section .bss
        i                               resb    1
        j                               resb    1
        opcion_ingresada                resb    1
        tablero                         resb    CANT_FIL*CANT_COL ; tablero a llenar
        tablero_espejo                  resb    CANT_FIL*CANT_COL
        tablero_rotacion_derecha        resb    49
        tablero_rotacion_izquierda      resb    49
        x                               resb    1
        y                               resb    1


;rotar derecha =>  %1:matriz,%2:tablero_rotacion_derecha
%macro rotar_derecha 2
        mov     BYTE [i],      1
        mov     BYTE [j],      1
%%inicio:
        cmp     BYTE [i],      CANT_FIL          
        jg      %%aca

        cmp     BYTE [j],      CANT_COL        
        jg      %%cambioFila

        calcular_direccion_de_una_posicion  j,i,CANT_COL
        movzx   rdx, BYTE [%1 + rax]   

        calcular_direccion_de_una_posicion i,j, CANT_COL
        mov     [%2 + rax], rdx  

        inc     BYTE [j]                   
        jmp     %%inicio                     

%%cambioFila:
        inc     BYTE [i]                  
        mov     BYTE [j],    1            
        jmp     %%inicio
%%aca:
%endmacro

; imprime la matriz => %1 :matriz 
%macro imprimir_matriz 1
        mov     BYTE [i],      1           ; Inicializar fila (1 byte)
        mov     BYTE [j],      1           ; Inicializar columna (1 byte)
        imprimir_opcion         linea_arriba
        imprimir        linea_vertical

%%inicio:
        cmp     BYTE [i],      CANT_FIL          ; Verificar si se llegó al final de las filas
        jg      %%fin
        cmp     BYTE [j],      CANT_COL          ; Verificar si se llegó al final de las columnas
        jg      %%cambioFila
        calcular_direccion_de_una_posicion      i,j,CANT_COL

        movzx   rdx, BYTE [%1 + rax]        ; Cargar carácter desde matriz
        ; Imprimir el carácter
        sub     rsp,    8
        mov     rdi,   formato
        mov     rsi,    rdx                    ; El carácter se pasa en rsi
        call    printf
        add     rsp,    8

        inc     BYTE [j]
        jmp     %%inicio

%%cambioFila:
        imprimir        linea_vertical
        imprimir        saltoLinea
        imprimir        linea_vertical

        inc     BYTE    [i]                   ; Ir a la siguiente fila
        mov     BYTE    [j],   1                ; Reiniciar columna
        jmp     %%inicio
%%fin:
        imprimir_opcion         linea_abajo
%endmacro
%macro imprimir_opcion 1
        mov     rdi,%1       
        sub     rsp,    8 
        call    puts           
        add     rsp,    8 
%endmacro
%macro imprimir 1
        mov     rdi,%1       
        sub     rsp,    8 
        call    printf           
        add     rsp,    8 
%endmacro
;imprimir pos validas para oficial=> %1 : fil,%2:col 
%macro imprimir_pos_validas 2
        imprimir_opcion      opcion_salir
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
        jl      %%fila_menor
        je      %%fila_igual
        jg      %%fila_mayor

%%fila_mayor:
        cmp     [y],    r13B
        jg      %%poner_inf_derecha
        je      %%poner_inf_abajo
        jl      %%poner_inf_izquierda

%%fila_igual:
        cmp     [y],    r13B
        jl      %%poner_izquierda
        jg      %%poner_derecha

%%fila_menor:
        cmp     [y],    r13B
        jg      %%poner_sup_derecha
        je      %%poner_sup_arriba
        jl      %%poner_sup_izquierda

%%poner_inf_derecha:
        imprimir_opcion     opcion_inf_derecha
        jmp     %%continuar
%%poner_inf_abajo:
        imprimir_opcion     opcion_abajo
        jmp     %%continuar

%%poner_inf_izquierda:
        imprimir_opcion     opcion_inf_izquierda
        jmp     %%continuar

%%poner_derecha:
        imprimir_opcion     opcion_derecha
        jmp     %%continuar

%%poner_izquierda:
        imprimir_opcion     opcion_izquierda
        jmp     %%continuar

%%poner_sup_izquierda:
        imprimir_opcion     opcion_sup_izquierda
        jmp     %%continuar

%%poner_sup_arriba:
        imprimir_opcion     opcion_arriba
        jmp     %%continuar

%%poner_sup_derecha:
        imprimir_opcion     opcion_sup_derecha
        jmp     %%continuar

%%fin:
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
; => %1 : opcion ingresada, %2 : opcion a comparar
%macro  comparar_opciones 2
        mov     al,    [%1]
        mov     bl,    %2
        cmp     al,    bl
%endmacro

%macro copiar_matriz 1
        mov     rcx,    0
%%inicio:
        cmp     rcx,    49
        jg      %%fin
        mov     al,     [%1+ rcx]
        mov     [tablero+rcx], al
        inc     rcx
        jmp     %%inicio
%%fin:
%endmacro
%macro  limpiar 0
        mov     rdi,    cmd_clear
        sub     rsp,    8
        call    system
        add     rsp,    8
%endmacro
;ejecuta la instruccion ingresada => %1 : opcion ingresada, %2 : opcion
%macro ejecutar_intruccion 1
        mov     bl,    [opcion_ingresada]
        mov     al,   104       ; codigo h
        cmp     al,    bl
        je      final_juego             ;salir

        mov     al,    49       ; codigo 1
        cmp     al,    bl
        je      %%arriba                ;mismo tablero

        mov     al,    50       ;codigo 2
        cmp     al,    bl
        je      %%izquierda

        mov     al,    51       ;codigo 3
        cmp     al,    bl
        je      %%derecha               ;rotar derecha

        mov     al,    52       ;codigo 4
        cmp     al,    bl
        je      %%abajo                 ;rotar abajo
        jmp     %%incorrecto
%%incorrecto:
        limpiar
        imprimir_opcion        opcion_incorrecta
        jmp     pedir_tablero
%%arriba:
        copiar_matriz           matriz
        jmp     %%fin
%%derecha:
        rotar_derecha           matriz, tablero
        jmp     %%fin
%%abajo:
        tablero_vertical        matriz, tablero
        jmp     %%fin
%%izquierda:
        rotar_derecha           matriz, tablero_rotacion_derecha
        tablero_vertical          tablero_rotacion_derecha,tablero
        jmp     %%fin
%%fin:

%endmacro

; => %1 : 
%macro leer_entrada 0
        sub     rsp,    8 
        mov     rdi,    formato_Caracter
        mov     rsi,     opcion_ingresada
        call    scanf           ; espera a que ingreses una opcion
        add     rsp,    8 
%endmacro

section .text
main:
pedir_tablero:
        imprimir_opcion         cadena_pedir
        imprimir_opcion         tablero_normal
        imprimir_opcion         tablero_abajo
        imprimir_opcion         tablero_derecha
        imprimir_opcion         tablero_izquierda
        leer_entrada  
        ejecutar_intruccion     opcion_ingresada
        limpiar
        imprimir_matriz         tablero
inicio_juego:


        ;imprimir_opcion      cadena_pedir
        imprimir_pos_validas    7,3       ; bucas las posiciones validas para las coordenadas (x,y) en este cado (7,3)

        ;leer_entrada      
        ;ejecutar_intruccion     opcion_ingresada
final_juego:
        ret





