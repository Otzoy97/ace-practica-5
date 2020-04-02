clearScreen macro 
    push ax
    push cx
    mov ah, 02h
    mov dl, 00h
    mov dh, 00h
    int 10h
    mov ah, 09h ;escribir carácter y atributo
    mov al, 00h
    mov bl, 07h ;fondo negro, letra gris
    mov cx, 0fa0h
    int 10h
    pop cx
    pop ax
endm

pauseAnyKey macro
    push ax
    printStr pressanykey
    mov ah, 08h
    int 21h 
    pop ax
endm

pauseAnyKeyVideo macro
    push ax
    mov ah, 10h
    int 16h
    ;reestablece el segmento de datos
    ;mov ax, @data
    ;mov ds, ax
    pop ax
endm

printPixelOn macro
    push ax
    push bx
    mov ax, 0c0fh
    mov bx, 0000h
    int 10h
    pop bx
    pop ax
endm

setupScreen macro
LOCAL _1, _2, _3
    push ax
    push cx
    push bx
    push di
    ;pinta toda la pantalla de azul
    mov ax, 0a000h
    mov ds, ax
    ;mov cx, 0fa00h
    ;mov bx, 0001h
    ;xor di, di
    ;_1:
    ;    mov [di], bx
    ;    inc di
    ;    loop _1
    ;pinta el eje y
    xor di, di
    xor ax, ax
    mov ax, 000ah   ; color verde claro
    mov cx, 200   ; 200 lineas
    mov di, 159   ; empieza en 159
    _2:
        mov [di], ax
        add di, 320
        loop _2
    ;pinta el eje x
    xor di, di
    mov di, 7a80h   ; 99 eje x
    mov cx, 140h    ; 320 columnas
    _3:
        mov [di], ax
        inc di
        loop _3
    ;restablece segmento de datos
    mov ax, @data
    mov ds, ax
    pop di
    pop bx
    pop cx
    pop ax
endm

videoModeOn macro
    push ax
    ;configura modo video
    mov ax, 0013h
    int 10h
    pop ax
endm

textModeOn macro
    push ax
    ;configura modo texto
    mov ax, 0003h
    int 10h
    pop ax
endm