clearScreen macro 
    push ax
    push cx
    mov ah, 02h
    mov dl, 00h
    mov dh, 00h
    int 10h
    mov ah, 0ah
    mov al, 00h
    mov cx, 2710h
    int 10h
    pop cx
    pop ax
endm