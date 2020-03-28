include stringH.asm
include fileH.asm
include screenH.asm
.model small
.386
.stack
.data
ln                  db '$'
fileNameHere        db "Ingrese el nombre del archivo de la forma (@@<ruta de archivo>@@):$"
createFileFailed    db "Error: no se pudo crear el archivo$"
openFileFailed      db "Error: no se pudo abrir el archivo$"
writeFileFailed     db "Error: no se pudo escribir el archivo$"
closeFileFailed     db "Error: No se pudo cerrar el archivo$"
readFileFailed      db "Error: No se pudo leer el archivo$"
illegalCharOnFile   db "Error: car", 0a0h,"cter inv",0a0h,"lido:   $" ;30
illegalEndOnFile    db "Error: no hubo final de instrucción $"
illegalNameFile     db "Error: nombre de archivo no coincide con formato @@<ruta de archivo>@@$"
fileName            db 255 dup(00H)
fileHandler         dw ?
fileBuffer          db 255 dup(00H)
fileBuffChar        db ?
;------------------------------------------------------------------
;FORMATO DE FUNCIONES

;------------------------------------------------------------------
;ENCABEZADO DE REPORTE
reportHeader        db "UNIVERSIDAD DE SAN CARLOS DE GUATEMALA", 0ah, 0dh
                    db "FACULTAD DE INGENIERIA", 0ah, 0dh
                    db "ESCUELA DE CIENCIAS Y SISTEMAS", 0ah, 0dh
                    db "ARQUITECTURA DE COMPUTADORES Y ENSAMBLADORES 1 A", 0ah, 0dh
                    db "PRIMER SEMESTRE 2020", 0ah, 0dh
                    db "SERGIO FERNANDO OTZOY GONZALEZ", 0ah, 0dh
                    db "201602782", 0ah, 0dh, 0ah, 0dh
                    db "REPORTE PRACTICA NO. 3",  0ah, 0dh, 0ah, 0dh
reportDate          db "Fecha: 00/00/0000", 0ah, 0dh
reportTime          db "Hora: 00:00:00", 0ah, 0dh, 0ah, 0dh
reportOriginal      db "Función original", 0ah, 0dh
reportDerivada      db "Función derivada", 0ah, 0dh
reportIntegral      db "Función integral", 0ah, 0dh
fxOriginal          db "f(x) = ", 0ah, 0dh
fxDerivada          db "f'(x) = ", 0ah, 0dh
fxIntegral          db "F(x) = ", 0ah, 0dh
;x1                  db "x"
;x2                  db "x2"
;x3                  db "x3"
;x4                  db "x4"

.code
main proc
    mov ax, @data
    mov ds, ax
    clearScreen
    ;flushStr fileName, 255, 00H
    ;getLine fileName
    ;call validateFileName
    ;openFile fileName, fileHandler   
    ;jc EndMain
    call calculatorMode
    ;printStrln fileBuffer
    EndMain:
        mov ax, 4C00H
        int 21H
main endp

calculatorMode proc
    _calculatorFileName:
        printStrln fileNameHere
        flushStr fileName, 255, 00H
        getLine fileName
        call validateFileName
        jne _calculatorFileName
        openFile fileName, fileHandler
        call readExpression
        jne _calculatorFileName
        printStrln fileBuffer
        ret
calculatorMode endp

;------------------------------------------------------------------
validateFileName proc
; Valida que el nombre del archivo este en este formato ## ##
; Recorre el nombre del archivo hasta encontrar el codigo ascii
; de caracter nulo
;------------------------------------------------------------------
    push cx
    push si
    push ax
    xor cx, cx
    xor si, si
    xor ax, ax
    _validateLoop:
        cmp fileName[SI], 040h
        je _validateLow
        cmp fileName[SI], 00h
        je _validateErr1
    _validateIncSi:
        inc si
        jmp _validateLoop
    _validateErr1:
        printStrln illegalNameFile
        printStrln ln
        mov al, 00h
        cmp al, 01h
        jmp _validateEnd1
    _validateLow:
        cmp al, 02h
        je _validateHigh
        inc al
        jmp _validateIncSi
    _validateHigh:
        cmp ah, 01h
        je _validateEnd
        inc ah
        jmp _validateIncSi
    _validateEnd:
        mov fileName[si], 00h
        mov fileName[si - 1], 00h
        mov cx, si
        xor si, si
        dec cx
    _validateEndLoop:
        mov al, fileName[si + 2]
        mov fileName[si], al
        inc si
        loop _validateEndLoop
        mov al, 00h
        cmp al, 00h
        ;mov fileName[si + 1], '$'
        ;printStrln fileName
    _validateEnd1:
        pop ax
        pop si
        pop cx
        ret
validateFileName endp

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
;------------------------------------------------------------------
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
        printStrln ln
        mov al, 01h
        cmp al, 00h
        JMP _readEndP
    _readErr2:
        mov illegalCharOnFile[1eh], al
        printStrln illegalCharOnFile
        printStrln ln
        mov al, 01h
        cmp al, 00h
        JMP _readEndP
    _readErr3:
        printStrln illegalEndOnFile
        printStrln ln
        mov al, 01h
        cmp al, 00h
        JMP _readEndP
    _readSucc:
        mov fileBuffer[di], al
        mov fileBuffer[di+1], '$' ; <-> para debuggear
        ;printStrln fileBuffer ;<-> para debuggear
        mov al, 00h
        cmp al, 00h
    _readEndP:
        pop di
        pop cx
        pop ax            
        ret
readExpression endp


end main
