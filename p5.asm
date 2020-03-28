include stringH.asm
include fileH.asm
.model small
.386
.stack
.data
createFileFailed    db "-- Error: no se pudo crear el archivo --$"
openFileFailed      db "-- Error: no se pudo abrir el archivo --$"
writeFileFailed     db "-- Error: no se pudo escribir el archivo --$"
closeFileFailed     db "-- Error: No se pudo cerrar el archivo --$"
readFileFailed      db "-- Error: No se pudo leer el archivo --$"
illegalCharOnFile   db "-- Error: car", 0a0h,"cter inv",0a0h,"lido:   --$" ;30
illegalEndOnFile    db "-- Error: no hubo final de instrucción --$"
fileName            db 255 dup(00H)
fileHandler         dw ?
fileBuffer          db 255 dup(00H)
fileBuffChar        db ?
.code
main proc
    mov ax, @data
    mov ds, ax
    flushStr fileName, 255, 00H
    getLine fileName
    openFile fileName, fileHandler   
    jc EndMain
    call readExpression
    ;printStrln fileBuffer
    EndMain:
        mov ax, 4C00H
        int 21H
main endp

;------------------------------------------------------------------
readExpression proc
;
; Utiliza el handle almacenado para recuperar una cadena que 
; representa una operación aritmética.
; Recupera el largo del archivo y a través de un loop lee hasta
; encontrar un puntoy coma (;) o hasta que finalize el archivo
; si no encuentra un punto y coma o encunetra caracter no válidos 
; (caracter válidos: + - * / 0 1 2 3 4 5 6 7 8 9) se detendrá el 
; procedimiento y se mostrará un error mostrando el caracter
; inválido, la fila y la columna.
    push ax ;almacena el valor previo de ax
    push cx ;almacena el valor previo de cx
    push di ;almacena el valor previos de di
    mov ax, 4202h
    xor cx, cx
    xor dx, dx
    int 21H
    jc _readErr1 ;no se pudo leer el archivo
    push ax ;almacena el largo del archivo
    mov ax, 4200h 
    xor cx, cx
    xor dx, dx
    int 21h ;reestablece el puntero del archivo
    pop cx ;inicializa el contador
    xor di, di
    flushStr fileBuffer, 255, 00H
    flushStr fileBuffChar, 1, 00H
    _readReadChar:
        readFile fileHandler, fileBuffChar, 01h
        mov al, fileBuffChar
        cmp al, 3bh ;caracter es igual a ';'
        je _readSucc             
        cmp al, 0ah ;caracter es igual a retorno de carro        
        je _readIncSi
        cmp al, 0dh ;caracter es igual a nueva línea
        je _readIncSi
        cmp al, 20h ;caracter es igual a espacio
        je _readIncSi
        cmp al, '+' 
        je _readSaveChar
        cmp al, '-' 
        je _readSaveChar
        cmp al, '*'
        je _readSaveChar 
        cmp al, '/'
        je _readSaveChar 
        cmp al, '0' 
        jb _readErr2
        cmp al, '9' 
        ja _readErr2
    _readSaveChar:
        mov fileBuffer[di], al
        inc di
    _readIncSi:
        LOOP _readReadChar
        jmp _readErr3
    _readErr1:
        printStrln readFileFailed
        JMP _readEndP
    _readErr2:
        mov illegalCharOnFile[1eh], al
        printStrln illegalCharOnFile
        JMP _readEndP
    _readErr3:
        printStrln illegalEndOnFile
        JMP _readEndP
    _readSucc:
        mov fileBuffer[di], al
        ;mov fileBuffer[di+1], '$' <-> para debuggear
        ;printStrln fileBuffer <-> para debuggear
    _readEndP:
        pop di
        pop cx
        pop ax            
        ret
readExpression endp


end main