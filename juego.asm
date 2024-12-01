global main
extern printf
extern scanf
extern puts
extern strcpy
extern strcmp
extern system

; --------------------------
; UTILS

%macro mputs 1
        mov     rdi,%1       
        sub     rsp,    8 
        call    puts           
        add     rsp,    8 
%endmacro

; Props
;  %1: formato
;  %2: argumento
%macro mprintf 0    
        sub     rsp,    8 
        call    printf           
        add     rsp,    8 
%endmacro

%macro print_opcione_moviento 4
        mov     rdi, %1  
        movzx   rsi, byte [%2]     
        movzx   rdx, byte [%3]     
        movzx   rcx, byte [%4]     
        sub     rsp,    8 
        call    printf           
        add     rsp,    8 
%endmacro

%macro print_s 1
        mov     rdi,%1  
        mov     rsi,0 
        mprintf 
%endmacro

%macro limpiar 0
        mov     rdi,    cmd_clear
        sub     rsp,    8
        call    system
        add     rsp,    8
%endmacro

; --------------------------

; Calcular posicion del vector en base a posicion matriz: 
; props: 
; %1: fil -> x
; %2: col -> y
; %3: cantidad_columnas -> length

%macro obtener_posicion_vector_matriz 3
        movzx   rax,    BYTE [%1]               ; rax = fila (ampliar a 64 bits para cálculos)
        movzx   rbx,    BYTE [%2]               ; rbx = columna (ampliar a 64 bits)
        
        imul    rax,    %3                      ; (fila) * CANT_COL
        add     rax,    rbx                     ; (fila) * CANT_COL + (columna) = pos
%endmacro

; Props
; al: elemento a buscar
; %1: vector
; %2: longitud
; -----------------------------------------------------------
%macro vector_incluye 2

        mov     rcx,    0
%%iterar_vector:
        movzx   rbx,     BYTE [%1+rcx]                    ; [0+rcx] siendo rcx < 16
        cmp     al,      bl                               ; si la poscion adyancente es una posicion invalida
        je      %%encontrado                              ; evaluo la siguiente 
        
        inc     rcx
        cmp     rcx,    %2
        jl      %%iterar_vector             ; repito el loop hasta terminar de iterar sobre invalidas[]
      
        mov     al, 1
        jmp     %%fin

%%encontrado:
        mov     al, 0
        jmp     %%fin
%%fin:
%endmacro       
; -----------------------------------------------------------

section .data
        opcion_comer            db      " %d- 🍴 para comer (%d, %d)",10,0
        opcion_vacia            db      " %d- mover (%d, %d)",10,0
        linea_posiciones        db      "     0  1  2  3  4  5  6",0
        linea_arriba            db      "   ┏━━━━━━━━━━━━━━━━━━━━━┓",0
        linea_abajo             db      "   ┗━━━━━━━━━━━━━━━━━━━━━┛",0
        linea_vertical          db      "┃",0
        formato_contador        db      " %d ", 0
        formato                 db      ' %c ', 0
        formato_int             db      "%d",0
        salto_linea              db      10, 0
        matriz                  db      ' ', ' ', 'X', 'X', 'X', ' ', ' '  ; Fila 1
                                db      ' ', ' ', 'X', 'X', 'X', ' ', ' '  ; Fila 2
                                db      'X', 'X', 'X', 'X', 'X', 'X', 'X'  ; Fila 3
                                db      'X', 'X', 'X', '.', 'X', 'X', 'X'  ; Fila 4
                                db      'X', 'X', '.', '.', '.', 'X', 'X'  ; Fila 5
                                db      ' ', ' ', '.', '.', 'O', ' ', ' '  ; Fila 6
                                db      ' ', ' ', 'O', '.', '.', ' ', ' '  ; Fila 7

        posiciones_oficiales    db      44,39
        oficiales_rodeados      db      0,0

        CANT_FIL                equ     7
        CANT_COL                equ     7
        LONG_ELEM               equ     1
        opcion_incorrecta       db      "------------------------------",10," La opcion ingresada en invalida",10,"------------------------------",10,0
        opcion_salir            db      "🆀-  para salir (en minuscula)",0
        mensaje_ingreso_oficial db      "Ingrese la fila y columna del oficial que desea mover",10,0
        mensaje_ingreso_soldado db      "Ingrese la fila y columna del soldado que desea mover",10,0
        mensaje_fila            db      "Fila: ",0
        mensaje_columna         db      "Columna: ",0
        mensaje_perdio_oficiales db     "No hay ofiales vivos, ganaron los soldados",10,0
        mensaje_perdio_soldados db      "No hay soldados suficientes, ganaron los oficiales",10,0
        mensaje_gano_soldados   db      "Ganaron los soldados, porque llenaron el cueartel",10,0
        mensaje_perdio_oficiales_rodeados db "Todos los oficiales estan rodeados",10,0
        mensaje_cant_soldados   db      " Cantidad soldados : ",0
        oficial                 db      "O"
        soldado                 db      "X"
        pos_vacia               db      "."
        pos_invalida            db      " "
        cmd_clear               db      "clear",0
        jugador                 db      "O" ;; cambiar a soldado
        longitud_posiciones_mov db      0
        posiciones_mov          times 8 db 0
        oficial_comer           db      0
        oficiales_vivos         db      2
        soldados_vivos          db      24
        cuartel                 db      30,31,32,37,38,39,44,45,46
        posiciones_limitadas    db      28,29,33,34

section .bss
        i                       resb    1
        j                       resb    1
        opcion_ingresada        resb    1
        tablero                 resb    CANT_FIL*CANT_COL ; tablero a llenar
        tablero_rotacion_derecha resb   49
        x                       resb    1
        y                       resb    1
        fil                      resb    1
        col                       resb    1

%macro verificar_salir 0
        cmp rsi, 113
        je final_juego
%endmacro

; Leer opcion ingresada
; -----------------------------------------------------------
leer_opcion:
%macro leer_opcion 0
        sub     rsp,    8 
        mov     rdi,    formato_int
        mov     rsi,    opcion_ingresada
        call    scanf                           ; espera a que ingreses una opcion
        add     rsp,    8 

        verificar_salir
%endmacro
; -----------------------------------------------------------


; Imprime la matriz: 
; Props:  
;   %1: matriz 
; -----------------------------------------------------------
imprimir:
%macro imprimir_matriz 0

        mov     BYTE [i], 0                     ; Inicializar fila 1
        mov     BYTE [j], 0                     ; Inicializar columna 1

        mov     rdi,mensaje_cant_soldados  
        mprintf
        mov     rdi,formato_contador  
        movzx   rsi, byte [soldados_vivos] 
        mprintf
        mputs      salto_linea


        mputs         linea_posiciones          ; Imprime tope
        mputs         linea_arriba              ; Imprime tope
        mov     rdi,formato_contador  
        movzx   rsi, byte [i] 
        mprintf        
        print_s       linea_vertical            ; Imprime primer borde izquierdo        

%%inicio:
        cmp     BYTE [j],      CANT_COL          ; Verificar si se llegó al final de las columnas
        je      %%cambioFila

        ; Imprimir el carácter de la posicion i,j 
        obtener_posicion_vector_matriz      i,j,CANT_COL ; rax = posicion del vector
        mov   rdi,formato  
        movzx   rsi, byte [matriz + rax] 
        mprintf   

        inc     BYTE [j]
        jmp     %%inicio

%%cambioFila:
        print_s        linea_vertical           ; imprime borde derecho
        print_s        salto_linea

        inc     BYTE [i]                        ; Ir a la siguiente fila
        cmp     BYTE [i],      CANT_FIL         ; Verificar si se llegó al final de las filas
        je      %%fin

        mov     rdi,formato_contador  
        movzx   rsi, byte [i] 
        mprintf    
        print_s        linea_vertical           ; Imprime borde izquierdo nueva fila
        mov     BYTE    [j],   0                ; Reiniciar columna
        jmp     %%inicio
%%fin:
        mputs         linea_abajo               ; Imprime borde inferior
%endmacro

; -----------------------------------------------------------


; Verifica si la posicion es valida, devuelve al = 0 si es valida, si no al = 1
; -----------------------------------------------------------
verificar_pos_valida:
%macro verificar_posicion_valida 0
        ; mov al, BYTE %1 ; al es la posicion a evaluar
          
        cmp     al, 48
        jg      %%es_invalida            ; si la posicion adyacente es mayor a 48, evaluo la siguiente
        
        cmp     al, 0
        jl      %%es_invalida            ; si la posicion adyacente es menor a 0, evaluo la siguiente
        
        mov    al, 0
        jmp    %%fin

%%es_invalida:
        mov     al, 1
%%fin:
%endmacro
; -----------------------------------------------------------


; Imprime las opciones de movimiento validas para el oficial 
; Props: 
;       %1: fil
;       %2: col 
; -----------------------------------------------------------
imprimir_pos_oficial:
%macro obtener_pos_validas_oficial 2
        mov BYTE [longitud_posiciones_mov], 0
        mov BYTE [posiciones_mov], 0

        mov BYTE [i], -1   
        mov al, BYTE [%1]
        mov [x], al
        mov al, BYTE [%2]
        mov [y], al

        obtener_posicion_vector_matriz       x,y,CANT_COL 
        mov r12b, al
%%filas:
        mov BYTE [j], -1             ; voy a la primera columna aux
        mov al, BYTE [%1]
        add al, [i]
        mov [x], al

%%columnas:
        mov al, BYTE [%2]
        add al, [j]
        mov [y], al

        obtener_posicion_vector_matriz       x,y,CANT_COL ; rax = posicion adyancente del vector

        ; si la poscion adyancente es la posicion inicial es invalida
        cmp     al,    r12b
        je      %%siguiente_posicion_adyacente   

        mov dl, al
        ; si la poscion adyancente es una posicion invalida
        verificar_posicion_valida
        cmp     al, 1
        je      %%siguiente_posicion_adyacente   
        mov al, dl

%%es_pos_valida:
        mov dl, BYTE [matriz+rax]                       ; asigno a dl, el caracter de la matriz
        cmp dl, [pos_invalida]                          ; Si en la posicion es una invalida no es valida
        je %%siguiente_posicion_adyacente

        cmp dl, [oficial]                               ; Si en la posicion es un oficial no es valida
        je %%siguiente_posicion_adyacente
      
        cmp dl, [soldado]                               ; Si en la posicion es un oficial no es valida
        je %%es_soldado

%%mostrar_vacio: 
        mov bl, al
        print_opcione_moviento  opcion_vacia, longitud_posiciones_mov, x, y
        mov al, bl
        jmp     %%añadir_movimiento

%%añadir_movimiento:
        movzx     rdi, BYTE [longitud_posiciones_mov]
        mov     BYTE [posiciones_mov + rdi], al
        inc     BYTE [longitud_posiciones_mov]
        jmp     %%siguiente_posicion_adyacente

%%es_soldado:
        ; Desplazo en la misma direccion 1 mas
        mov al, [x]
        add al, [i]
        mov [x], al

        mov al, [y]
        add al, [j]
        mov [y], al

        ; si es vacia es valida
        obtener_posicion_vector_matriz       x,y,CANT_COL 
        mov dl, BYTE [matriz+rax]                       ; asigno a dl, el caracter de la matriz
        
        mov al, [x]
        sub al, [i]
        mov [x], al

        mov al, [y]
        sub al, [j]
        mov [y], al

        cmp dl, [pos_vacia]
        je %%mostrar_comer
       
%%siguiente_posicion_adyacente:
        inc     BYTE    [j]
        cmp     BYTE    [j],    1
        jle     %%columnas        ; si j es <=1 volvemos a repetir con j+1
        
        inc     BYTE    [i]     
        cmp     BYTE    [i],    1
        jg      %%fin             ; si i es >1 terminamos

        jmp      %%filas    

%%mostrar_comer: 
        print_opcione_moviento  opcion_comer, longitud_posiciones_mov, x, y

        mov BYTE [oficial_comer], 1
        
        obtener_posicion_vector_matriz       x,y,CANT_COL
        jmp     %%añadir_movimiento

%%mostrar_oficial: 
        jmp     %%siguiente_posicion_adyacente

%%fin:
%endmacro
; -----------------------------------------------------------

; Imprime las opciones y solicita la opcion a mover
; -----------------------------------------------------------
amover_oficial:
%macro mover_oficial 0
%%solicitar_opciones:
        obtener_pos_validas_oficial    fil, col        ; bucas las posiciones validas para las coordenadas (x,y) en este cado (6,2)
        leer_opcion

        cmp BYTE [opcion_ingresada], 0
        jl %%invalida
        
        mov al, BYTE [longitud_posiciones_mov]
        cmp BYTE [opcion_ingresada], al
        jge %%invalida

        jmp %%valida
%%invalida:
        print_s opcion_incorrecta
        jmp %%solicitar_opciones

%%valida:
        movzx rdi, BYTE [opcion_ingresada]
        movzx rsi, BYTE [posiciones_mov + rdi] ; rsi = posicion destino
        
        mov al, BYTE [matriz + rsi] ; al = caracter en la posicion destino
        
        cmp al, [pos_vacia]
        je %%mover

%%comer:
        ; posion vacia en el destino soldado
        mov bl, BYTE [pos_vacia]
        mov BYTE [matriz + rsi], bl
        dec BYTE   [soldados_vivos]     ; decremento la cantidad de soldados vivos
        
        ; pisa en la posicion de la matriz con el oficial
        obtener_posicion_vector_matriz    fil,col, CANT_COL ; al = posicion original
        
        mov bl, sil             ; bl = y 
        sub bl, al              ; bl = y - x
        imul rbx, 2             ; bl = 2(y-x)
        add bl, al              ; bl = x + 2(y-x)
        movzx rsi, bl           ; rsi = x + 2(y-x)

        mov BYTE [oficial_comer], 0

%%mover:
        cmp BYTE [oficial_comer], 1
        je %%borrar

        ; pisa en la posicion de destino con el jugador
        mov bl, BYTE [jugador] 
        mov BYTE [matriz + rsi], bl

%%borrar: 
        ; Borrar al oficial de la posicion original dejando un carater vacio
        obtener_posicion_vector_matriz    fil,col, CANT_COL
        mov bl, BYTE [jugador]
        cmp bl, [soldado]
        je %%continua

        mov cl, 0
%%busca_posicion_oficial:
        cmp BYTE [posiciones_oficiales + rcx], al
        je %%encontro

        inc cl
        jmp %%busca_posicion_oficial

%%encontro:
        mov BYTE [posiciones_oficiales + rcx], sil ; actualizo la posicion del oficial

%%continua:
        mov bl, BYTE [pos_vacia]
        mov BYTE [matriz + rax], bl

        cmp BYTE [oficial_comer], 0
        je %%fin

        mov BYTE [posiciones_oficiales + rcx], 0
        cmp BYTE [oficial_comer], 0
        dec BYTE [oficiales_vivos] 
%%fin:
%endmacro
; -----------------------------------------------------------


;Seleccionar la pos de un oficial
; -----------------------------------------------------------
;  %1 : cadena para pedir coedenadas del jugador actual
;  %2 : caracter de personaje actual (oficial o soldado)
aingres_oficial:
%macro ingresar_coordenadas_jugador 2
%%solicitar_posicion:
        ;solicitar la fila y columna del oficial que desea jugar
        print_s %1
        print_s mensaje_fila
        leer_opcion
        mov al, BYTE [opcion_ingresada]
        mov BYTE [fil], al

        print_s mensaje_columna
        leer_opcion
        mov al, BYTE [opcion_ingresada]
        mov BYTE [col], al

        obtener_posicion_vector_matriz    fil, col, CANT_COL
        mov al, BYTE [matriz + rax]
        cmp al, [%2]
        je %%fin
        print_s opcion_incorrecta
        jmp %%solicitar_posicion
%%fin:
%endmacro
; -----------------------------------------------------------

; Revisa si el cuartel esta lleno de soldados
; -----------------------------------------------------------
revi_cuar:
%macro revisar_cuartel 0
        mov rcx, 0
%%iterar_cuartel:
        mov al, BYTE [cuartel + rcx]
        mov al, BYTE [matriz + rax]
        cmp al, [soldado]
        jne %%fin

        inc cl
        cmp cl, 9
        jl %%iterar_cuartel

        print_s mensaje_gano_soldados
        jmp final_juego

%%fin:
%endmacro
; -----------------------------------------------------------

%macro revisar_oficiales 0
        mov cl, 0
%%iterar_oficiales:
        mov al, BYTE [posiciones_oficiales + rcx] ; al posicion oficial
	mov BYTE [i], -1
        mov BYTE [j], -1  

%%iterar_adyacentes:
        mov bl, [i] ; bl = i
        imul rbx, 7  ; bl = i*7 = i*d
        add bl, [j] ; bl = i*d + j
        add bl, al  ; bl = n + i*d + j
        
        movzx rbx, bl

        cmp bl, al  ; si la posicion adyacente es la misma que la original
        je %%next
        cmp bl, 0
        jle %%next ; si la posicion adyacente es menor o igual a 0
        cmp bl, 48
        jg %%next ; si la posicion adyacente es mayor a 48

        mov bl, byte [matriz + rbx] ; bl = matriz[n + i*d + j]
        cmp bl, [soldado] ; si la posicion adyacente es un soldado
        je %%next

        cmp bl, [pos_invalida] ; si la posicion adyacente es invalida
        je %%next

        jmp %%no_rodeado
%%next:
        inc BYTE [j]
        cmp BYTE [j], 2
        jl %%iterar_adyacentes
        mov BYTE [j], -1
        inc BYTE [i]
        cmp BYTE [i], 2
        jl %%iterar_adyacentes

        jmp %%rodeado

%%no_rodeado:
        mov BYTE [oficiales_rodeados + rcx], 0
        jmp %%siguiente_oficial

%%rodeado:
        mov BYTE [oficiales_rodeados + rcx], 1

%%siguiente_oficial:
        inc cl
        cmp cl, 2 
        jl %%iterar_oficiales

%%verificar_todos_rodeados:
        mov cl, 0
%%iterar_oficiales_rodeados:
        mov al, [oficiales_rodeados + rcx]
        cmp al, 0
        je %%fin

        inc cl
        cmp cl, 2
        jl %%iterar_oficiales_rodeados     

        print_s mensaje_perdio_oficiales_rodeados
        jmp final_juego
%%fin:
%endmacro

; Verifica los casos de victoria
; -----------------------------------------------------------
%macro verificar_victoria 0
        cmp BYTE [oficiales_vivos], 0
        je %%perdio_oficiales

        cmp BYTE [soldados_vivos], 9
        jl %%perdio_soldados
        
        revisar_cuartel

        revisar_oficiales

        jmp %%fin

%%perdio_oficiales:
        print_s mensaje_perdio_oficiales
        jmp final_juego

%%perdio_soldados:
        print_s mensaje_perdio_soldados
        jmp final_juego

%%fin:
%endmacro


; -----------------------------------------------------------
; fil y col tienen las coordenadas del soldado
%macro obtener_pos_validas_soldado 0    
        mov BYTE [longitud_posiciones_mov], 0
        mov BYTE [posiciones_mov], 0

        ; si el soldado esta en una posicion roja
        obtener_posicion_vector_matriz  fil,col,CANT_COL
        mov     rcx,0
%%buscar_soldados_rojos:
        cmp al, BYTE [posiciones_limitadas+rcx]
        je  %%soldado_rojo
%%seguir:
        inc     rcx
        cmp rcx, 4
        jl     %%buscar_soldados_rojos
        jmp     %%soldados_normales

%%soldado_rojo:
        cmp     BYTE [col],3
        jl      %%suma_columna
        dec     BYTE [col]
        jmp     %%proseguir
%%suma_columna:
        inc     BYTE [col]
%%proseguir:
        obtener_posicion_vector_matriz  fil,col,CANT_COL
        mov     dl , [matriz+rax]
        cmp     dl, BYTE [pos_vacia]
        jne      %%fin                               ; si es distinto de vacio siguo con la siguiente pos del vector de pos limitadas 

        print_opcione_moviento          opcion_vacia, longitud_posiciones_mov,fil,col
        movzx   rdi, BYTE [longitud_posiciones_mov]
        mov     BYTE [posiciones_mov + rdi], al
        inc     BYTE [longitud_posiciones_mov]
        jmp     %%fin

%%soldados_normales:
        mov cl ,-1 ; contador aux
        inc BYTE [fil]

%%iterar_pos_soldados:
        add     BYTE [col],cl

        obtener_posicion_vector_matriz   fil,col,CANT_COL ; en al se encuentra la direccion
        mov   dl , [matriz+rax]
        cmp   dl,BYTE [pos_vacia]
        jne   %%continuar                       ; si es distinto de vacio , analizo la proxima posicion

        print_opcione_moviento          opcion_vacia, longitud_posiciones_mov,fil,col
        movzx   rdi, BYTE [longitud_posiciones_mov]
        mov     BYTE [posiciones_mov + rdi], al
        inc     BYTE [longitud_posiciones_mov]
        
%%continuar:
        inc   cl
        cmp   cl, 2
        jl   %%iterar_pos_soldados 
%%fin:
%endmacro

%macro mover_soldados 0

        obtener_pos_validas_soldado

%endmacro

section .text
main:
inicio_juego:
       ; limpiar
        imprimir_matriz
        mputs   opcion_salir
        ingresar_coordenadas_jugador  mensaje_ingreso_oficial,oficial
        mover_oficial
        imprimir_matriz

        verificar_victoria   
mari:
        ingresar_coordenadas_jugador   mensaje_ingreso_soldado,soldado
        mover_soldados
        jmp inicio_juego
final_juego:
        ret








; Rotar matriz hacia la derecha:
; Props:
; %1: matriz
; %2: tablero_rotacion_derecha
%macro rotar_derecha 2
        mov     BYTE [i], 0
        mov     BYTE [j], 0
%%inicio:
        cmp     BYTE [i],  CANT_FIL          
        je      %%fin             

        cmp     BYTE [j],  CANT_COL        
        je      %%cambioFila    

        obtener_posicion_vector_matriz  j,i,CANT_COL
        movzx   rdx, BYTE [%1 + rax]   ; rdx = matriz[j][i]

        obtener_posicion_vector_matriz i,j, CANT_COL
        mov     [%2 + rax], rdx         ; matriz_inversa[i][j] = matriz[j][i] 

        inc     BYTE [j]                   
        jmp     %%inicio                     

%%cambioFila:
        inc     BYTE [i]                  
        mov     BYTE [j],    0            
        jmp     %%inicio
%%fin:
%endmacro















;; PROBABLEMENTE NO HACE FALTA
;voltea la matriz hacia abajo %1 matriz fuente, %2: matriz destino
; %macro tablero_vertical 2
;         mov     rdi,    0       ;direccion inicio
;         mov     rsi,    48      ;direccion final 
; %%espejo:
;         cmp     rdi,   rsi
;         jg      %%fin_tablero_espejo
;         mov     al, [%1 + rdi]   ; inicio
;         mov     dl, [%1 + rsi]   

;         mov     [%2 + rdi], dl
;         mov     [%2 + rsi], al

;         inc     rdi
;         dec     rsi
;         jmp     %%espejo

; %%fin_tablero_espejo:
; %endmacro   


; Menu inicial
; %macro ejecutar_intruccion 0
;         mov     bl,    [opcion_ingresada]
;         mov     al,   104       ; codigo h
;         cmp     al,    bl
;         je      final_juego     ;salir

;         mov     al,    49       ; codigo 1
;         cmp     al,    bl
;         je      %%arriba        ;mismo tablero

;         mov     al,    50       ;codigo 2
;         cmp     al,    bl
;         je      %%izquierda

;         mov     al,    51       ;codigo 3
;         cmp     al,    bl
;         je      %%derecha               ;rotar derecha

;         mov     al,    52       ;codigo 4
;         cmp     al,    bl
;         je      %%abajo                 ;rotar abajo
; %%incorrecto:
;         limpiar
;         mputs        opcion_incorrecta
;         jmp     pedir_tablero
; %%arriba:
;         copiar_matriz           matriz
;         jmp     %%fin
; %%derecha:
;         rotar_derecha           matriz, tablero
;         jmp     %%fin
; %%abajo:
;         tablero_vertical        matriz, tablero
;         jmp     %%fin
; %%izquierda:
;         rotar_derecha           matriz, tablero_rotacion_derecha
;         tablero_vertical        tablero_rotacion_derecha,tablero
;         jmp     %%fin
; %%fin:
; %endmacro