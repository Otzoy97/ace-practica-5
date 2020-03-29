clearScreen macro 
    push ax
    push cx
    mov ah, 02h
    mov dl, 00h
    mov dh, 00h
    int 10h
    mov ah, 0ah
    mov al, 00h
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