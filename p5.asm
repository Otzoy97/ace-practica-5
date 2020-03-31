include stringH.asm
include fileH.asm
include screenH.asm
include calc.asm

.model small
.386
.stack
.data
ln                  db '$'
pressanykey         db "Presione cualquier tecla para continuar...$"
fileNameHere        db "Ingrese el nombre del archivo de la forma (##<ruta de archivo>##):$"
createFileFailed    db "Error: no se pudo crear el archivo$"
openFileFailed      db "Error: no se pudo abrir el archivo$"
writeFileFailed     db "Error: no se pudo escribir el archivo$"
closeFileFailed     db "Error: No se pudo cerrar el archivo$"
readFileFailed      db "Error: No se pudo leer el archivo$"
illegalCharOnFile   db "Error: caracter inv",0a0h,"lido: $" ;30
illegalEndOnFile    db "Error: no hubo final de instrucci", 0a2h ,"n $"
illegalNameFile     db "Error: nombre de archivo no coincide con formato ##<ruta de archivo>##$"
fileName            db 150 dup(00h)
fileBuffer          db 255 dup(00h)
fileBuffChar        db ?
fileHandler         dw ?
;------------------------------------------------------------------
; MENU PRINCIPAL
mainMenu            db 0b3h," UNIVERSIDAD DE SAN CARLOS DE GUATEMALA                                      ", 0b3h, 0ah, 0dh
                    db 0b3h," FACULTAD DE INGENIERIA                                                      ", 0b3h, 0ah, 0dh
                    db 0b3h," ESCUELA DE CIENCIAS Y SISTEMAS                                              ", 0b3h, 0ah, 0dh
                    db 0b3h," ARQUITECTURA DE COMPUTADORES Y ENSAMBLADORES 1 A                            ", 0b3h, 0ah, 0dh
                    db 0b3h," PRIMER SEMESTRE 2020                                                        ", 0b3h, 0ah, 0dh
                    db 0b3h," SERGIO FERNANDO OTZOY GONZALEZ                                              ", 0b3h, 0ah, 0dh
                    db 0b3h," 201602782                                                                   ", 0b3h, 0ah, 0dh
                    db 0b3h,"                                                                             ", 0b3h, 0ah, 0dh
                    db 0b3h," QUINTA PRACTICA                                                             ", 0b3h, 0ah, 0dh, 0ah, 0dh
                    db "     MENU PRINCIPAL", 0dh, 0ah
                    db " 1.  Ingresar funci", 0a2h ,"n f(x)", 0dh, 0ah
                    db " 2.  Funci", 0a2h ,"n en memoria", 0dh, 0ah
                    db " 3.  Derivada f'(x)", 0dh, 0ah
                    db " 4.  Integral F(x)", 0dh, 0ah
                    db " 5.  Graficar funciones", 0dh, 0ah
                    db " 6.  Reporte", 0dh, 0ah
                    db " 7.  Modo calculadora", 0dh, 0ah
                    db " 8.  Salir", 0dh, 0ah,"$"
choose              db " Elija una opci", 0a2h ,"n: $"
chooseWrong         db " Opci", 0a2h ,"n no v",0a0h,"lida$"
chooseH             db 50 dup(00h)
choose1             db "1$"
choose2             db "2$"
choose3             db "3$"
choose4             db "4$"
choose5             db "5$"
choose6             db "6$"
choose7             db "7$"
choose8             db "8$"
;------------------------------------------------------------------
; INGRESAR FUNCION
funcxInst           db "Ingrese coeficiente por coeficiente (ej: -4, 0, +2): $"
funcfX              db "- Coeficiente de x4: $" ;18
funcfXWrong         db "Coeficiente inv", 0a0h,"lido: $"
funcNoMem           db "No hay ninguna funci", 0a2h, "n en memoria$"
funcIsMem           db 0b3h, " Funci", 0a2h ,"n original:$"
funcIsDev           db 0b3h, " Derivada de la funci", 0a2h ,"n:$"
funcIsInt           db 0b3h, " Integral de la funci", 0a2h ,"n:$"
funcOnMemf          db 5 dup(00h)
funcOnMemd          db 5 dup(00h)
funcIntCte          db ?
funcThereIsF        db 0
funcOriginal        db " f(x) = $"
funcDerivada        db " f'(x) = $"
functegral          db " F(x) = $"
;------------------------------------------------------------------
; MOSTRAR FUNCION
funcxDExist         db "No hay funci", 0a2h, "n en memoria $"
;------------------------------------------------------------------
; CALCULADORA
postFixOper         db 66 dup(00h)
tempOper            dd 0
operOverflow        db 0b3h," Error: desbordamiento en multiplicaci", 0a2h, "n$"
operDiviZero        db 0b3h," Error: divisi", 0a2h, "n ilegal entre cero$"
operInfo            db 0b3h," Operaci", 0a2h, "n:$"
operInfo2           db 0b3h,"    $"
operInfoSucc        db 0b3h," Resultado:$"
;------------------------------------------------------------------
; ENCABEZADO DE REPORTE
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

.code
main proc
    mov ax, @data
    mov ds, ax
    mainGetUserOp:
        clearScreen ;limpia la pantalla
        printChar 0dah
        printCharTimes 0c4h, 4dh
        printChar 0bfh
        printStrln ln
        printStrln mainMenu ;imprime el encabezado
        printStr choose ;imprime una decisión
        flushStr chooseH, 50, 00H ;limpia la entrada del usuario
        getLine chooseH ;recupera la entrada del usuario
        compareStr chooseH, choose1 ;compara la entrada con 1
        je mainEnterFunction
        compareStr chooseH, choose2 ;compara la entrada con 2
        je mainShowFunction
        compareStr chooseH, choose3 ;compara la entrada con 3
        je mainShowDevFunction
        compareStr chooseH, choose4 ;compara la entrada con 4
        je mainShowIntFunction
        compareStr chooseH, choose5 ;compara la entrada con 5
        je mainGraphFunction
        compareStr chooseH, choose6 ;compara la entrada con 6
        je mainGenRep
        compareStr chooseH, choose7 ;compara la entrada con 7
        je mainCalcMode
        compareStr chooseH, choose8 ;compara la entrada con 8
        je EndMain
        printStrln chooseWrong ;no es una opción válida
        pauseAnyKey 
        jmp mainGetUserOp ;regresa al main
    mainEnterFunction:
        clearScreen
        call enterFunction
    mainShowFunction:
        clearScreen
        cmp funcThereIsF, 00h
        jz mainGetUserOp
        call showFunction
        jmp mainGetUserOp
    mainShowDevFunction:
        clearScreen
        cmp funcThereIsF, 00h
        jz mainGetUserOp
        call showDevFunction
        jmp mainGetUserOp
    mainShowIntFunction:
        clearScreen
        cmp funcThereIsF, 00h
        jz mainGetUserOp
        call showIntFunction
        jmp mainGetUserOp
    mainGraphFunction:
        clearScreen
        jmp mainGetUserOp
    mainGenRep:  
        clearScreen
        jmp mainGetUserOp
    mainCalcMode:
        call calculatorMode
        jmp mainGetUserOp
    EndMain:
        mov ax, 4C00H
        int 21H
main endp

;------------------------------------------------------------------
enterFunction proc
; Solicita la entra de 5 coeficientes,
; valida la entrada del usuario, asegurandose que sean número con
; o sin signo. Si son números con signo negativo obtiene su comple-
; mento y luego lo guarda, si es positivo simplemente lo guarda
;------------------------------------------------------------------
    push di
    push si
    push cx
    push ax
    push bx
    mov cx, 05h
    _enterFCoef:
        xor di, di ;restablecer indice
        xor bx, bx ;restablece base
        clearScreen
        printStr funcfX
        flushStr chooseH, 50, 00h
        getLine chooseH
        _enterFCoefPosNull:
            cmp chooseH[di], 00h ;verifica que no sea nulo
            je _enterFCoefWrong ;salta a indicar que es un error
            cmp bh, 00h ;verifica si bl es 0
            je _enterFCoefSignFlow 
        _enterFCoefNumber1:
            cmp chooseH[di], '0'
            jb _enterFCoefWrong
            cmp chooseH[di], '9'
            ja _enterFCoefWrong
            mov al, chooseH[di]
            sub al, '0'
            cmp bh, 00h
            jne _enterFCoefNumberNeg
        _enterFCoefNumber2:
            mov funcOnMemf[si], al
            xor bl, bl
            inc si
            mov al, funcfX[12h] ;compone la etiqueta de coeficiente
            dec al
            mov funcfX[12h], al
            dec cx  ;emula el loop (ya que está muy lejos)
            cmp cl, 00h
            jnz _enterFCoef ;regresa
            jmp EndEnter
        _enterFCoefNumberNeg:
            neg al
            jmp _enterFCoefNumber2   
        _enterFCoefSignFlow:
            cmp chooseH[di], '-'
            je _enterFCoefSignFlowMinus
            cmp chooseH[di], '+'
            je _enterIncIndexes
            jmp _enterFCoefNumber1
        _enterFCoefSignFlowMinus:
            mov bh, 01h
        _enterIncIndexes:
            inc bl
            inc di
            jmp _enterFCoefPosNull
        _enterFCoefWrong:
            printStrln ln
            printStr funcfXWrong
            printChar chooseH[di]
            printStrln ln
            pauseAnyKey
            jmp _enterFCoef
    EndEnter:
        xor si, si
        xor cx, 05h
        _enterSetDerivate:
            mov al, cl ;mueve el contado actual 
            dec al     ;resta uno
            mov bl, funcOnMemf[si] ;mete coef
            imul bl     ;multiplica
            mov funcOnMemd[si], al ;almacena el coef de derivada
            inc si
            loop _enterSetDerivate
        mov funcThereIsF, 01h
        mov funcfX[12h], '4'
        pauseAnyKey
        pop bx
        pop ax
        pop cx
        pop si
        pop di
        ret
enterFunction endp

;------------------------------------------------------------------
showFunction proc
; Imprime consecutivamente la ifromaciónde funcOnMemf
;------------------------------------------------------------------
    push cx
    push si
    printChar 0dah
    printCharTimes 0c4h, 4eh
    printStrln ln
    printStrln funcIsMem
    printStrln operInfo2
    printStr operInfo2
    printStr funcOriginal
    xor cx, cx
    xor si, si
    mov cl, 05
    _showPrintFunction:
        cmp funcOnMemf[si], 00h
        jz _showPrinIncSi
        mov bl, funcOnMemf[si]
        rol bl, 01h
        ror bl, 01h
        jc _showNegFunc
        printChar '+'     ;imprime un signo más
        printChar 20h     ;imprime un espacio
        jmp _showNumberFunc
        _showNegFunc:
            neg bl
            printChar '-' ;imprime un signo menos
            printChar 20h ;imprime un espacio
        _showNumberFunc:
            add bl, '0'
            printChar bl  ;imprime el coeficiente
        cmp cx, 01h       ;si es 1 no imprime 1x0, solo el coef
        je _showPrinIncSi
        printChar 0fah    ;imprime un punto
        printChar 'x'     ;imprime una x
        cmp cx, 02h       ;si es 2 no imprme x1, solo x
        je _showPrinIncSiPrev
        mov al, cl        ;imprime la potencia de x
        dec al
        add al, '0'
        printChar al
        _showPrinIncSiPrev:
            printChar 20h ;imprime un espacio
        _showPrinIncSi:
            inc si
            dec cx
            cmp cl, 00h
            jnz _showPrintFunction
    _endShowFunction:
        printStrln ln
        printChar 0c0h
        printCharTimes 0c4h, 4eh
        printStrln ln
        printStrln ln
        pop si
        pop cx
        ret
showFunction endp

;------------------------------------------------------------------
showDevFunction proc
; Imprime consecutivamente la información de funcOnMemD
;------------------------------------------------------------------
    push ax
    push bx
    push cx
    push si
    printChar 0dah
    printCharTimes 0c4h, 4eh
    printStrln ln
    printStrln funcIsDev
    printStrln operInfo2
    printStr operInfo2
    printStr funcDerivada
    xor ax, ax
    xor bx, bx  
    xor cx, cx
    xor si, si
    mov cl, 05h
    _showDevPrint:
        cmp funcOnMemd[si], 00h  ;no imprime los coeficientes 0
        jz _showReturnDevPrint    ;salta e incrementa si
        mov al, funcOnMemd[si]  
        rol al, 01h
        ror al, 01h
        jc _showDevNeg           ;determina si es negativo
        printChar '+'            ;imprime un signo 'más'
        printChar 20h            ;imprime un espacio
        jmp _showDevNumberFunc
        _showDevNeg:
            neg al
            printChar '-'        ;imprime un signo 'menos'
            printChar 20h        ;imprime un espacio
        _showDevNumberFunc:      ;a través de un loop compone el número
            push cx              ;guarda el contador
            xor cx, cx           ;limpia el contador
            xor ah, ah           ;limpia el acumulador high
            mov bl, 0ah          ;mueve un 10 a la base
        _showDevNumberFunc1:
            cwd                  ;extiende el signo de ax a dx
            div bx               ;divide dentro de 10
            push dx              ;obtiene el residuo
            inc cx               ;aumenta el contador
            xor dx, dx           ;limpia el residuo
            cmp ax, 0000h        ;si el cociente no es cero
            jnz _showDevNumberFunc1 
            _showDevNumberFunc1Ascii:
                pop ax           ;recupera el número
                add al, '0'      ;le suma un '0'  
                mov bl, al        
                printChar bl     ;imprime el número
                loop _showDevNumberFunc1Ascii
            pop cx               ;reestablece el contador superior
            cmp cx, 02h          ;si es 02 no imprime 1x0, solo el coef
            jz _showReturnDevPrint
            printChar 0fah
            printChar 'x'
            cmp cx, 03h          ;si es 03 no imprime 1x1, solo 1x
            jz _showReturnDevPrintPrev
            mov al, cl
            sub al, 02h          ;le resta dos para obtener la potencia
            add al, '0'
            printChar al
            _showReturnDevPrintPrev:
                printChar 20h
            _showReturnDevPrint:
                inc si
                dec cx
                cmp cl, 00h
                jnz _showDevPrint
        printStrln ln
        printChar 0c0h
        printCharTimes 0c4h, 4eh
        printStrln ln
        printStrln ln
        pauseAnyKey
        pop si
        pop cx
        pop bx
        pop ax    
        ret
showDevFunction endp
;------------------------------------------------------------------
showIntFunction proc
; Imprime consecutivamente la información de funOnMemf
; junto con eso imprime la forma correcta de los coeficientes
; en una integral
;------------------------------------------------------------------
    push ax
    push bx
    push cx
    push si
    printChar 0dah
    printCharTimes 0c4h, 4eh
    printStrln ln
    printStrln funcIsInt
    printStrln operInfo2
    printStr operInfo2
    printStr functegral
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor si, si
    mov cl, 05h
    _showIFMain:
        cmp funcOnMemf[si], 00h ;no imprime los coeficientes 0
        jz _showIFMainIncSi     ;se salta todo el proc e inc si
        mov al, funcOnMemf[si]
        rol al, 01h
        ror al, 01h
        jc _showIFNeg
        printChar '+'            ;imprime el signo más
        jmp _showIFNumber
        _showIFNeg:
            neg al
            printChar '-'
        _showIFNumber:
            printChar 20h        ;imprime un espacio
            add al, '0'
            printChar al         ;imprime el numerador
            cmp cx, 01h          ;si es 1 no imprime 1/1 x solo 1x
            jz _showIFX
            mov al, cl           ;prepara el denominador
            add al, '0'             
            printChar '/'     
            printChar al         ;imprime el denominador  
        _showIFX:
            printChar 0fah
            printChar 'x' 
            cmp cx, 01h          ;no imprime x1, solo x
            jz _showIFMainIncSi
            printChar al
            printChar 20h        ;imprime un espacio
        _showIFMainIncSi:
            inc si
            dec cx
            cmp cl, 00
            jnz _showIFMain
    printChar 20h
    printChar '+'
    printChar 20h
    printChar 'c'
    printStrln ln
    printChar 0c0h
    printCharTimes 0c4h, 4eh
    printStrln ln
    printStrln ln
    pauseAnyKey
    pop si
    pop cx
    pop bx
    pop ax
    ret
showIntFunction endp


genReport proc
    push ax
    push bx
    push cx
    push si
    

    pop si
    pop cx
    pop bx
    pop ax
genReport endp

;------------------------------------------------------------------
calculatorMode proc
; solicita al usuario la entrada de una ruta de archivo verifica que 
; la ruta esté en el formato correcto
; lee el archivo y verifica que no tenga ningún caracter inválido
; arregla la operación leída (infija) a notación postfija
; opera la operación postfija utilizando la pila
;------------------------------------------------------------------
    _calculatorFileName:
        clearScreen
        printStrln fileNameHere
        flushStr fileName, 255, 00H
        getLine fileName
        call validateFileName ;verifica que la ruta del archivo este rodeada de ##
        jne _calculatorFileName
        openFile fileName, fileHandler ;abre el archivo y obtiene el handler
        jc _calculatorFileName 
        call readExpression ;lee y valida la expresión alojada en el archivo
        jne _calculatorFileName
        call toPostFixed ;compone la expresión a notación infija
        clearScreen 
        printChar 0dah
        printCharTimes 0c4h, 4eh
        printStrln ln
        printStrln operInfo 
        printStrln operInfo2 
        printStr operInfo2 
        printStrln fileBuffer ;imprime el expresión leída
        printChar 0c3h
        printCharTimes 0c4h, 4eh
        printStrln ln
        call calculateExpression
        printChar 0c0h
        printCharTimes 0c4h, 4eh
        printStrln ln
        pauseAnyKey
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
        cmp fileName[si], 23h
        je _validateLow
        cmp fileName[si], 00h
        je _validateErr1
    _validateIncSi:
        inc si
        jmp _validateLoop
    _validateErr1:
        printStrln illegalNameFile
        printStrln ln
        pauseAnyKey
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
    push bx
    mov ax, 4202h
    xor cx, cx
    xor dx, dx
    mov bx, fileHandler
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
        pauseAnyKey
        mov al, 01h
        cmp al, 00h
        JMP _readEndP
    _readErr2:
        printStr illegalCharOnFile
        printChar fileBuffChar
        printStrln ln
        printStrln ln
        pauseAnyKey
        mov al, 01h
        cmp al, 00h
        JMP _readEndP
    _readErr3:
        printStrln illegalEndOnFile
        printStrln ln
        pauseAnyKey
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
        closeFile fileHandler
        pop bx
        pop di
        pop cx
        pop ax            
        ret
readExpression endp

;------------------------------------------------------------------
toPostFixed proc
; Utiliza el fileBuffer y pasa la expresion infija a postfijo
;------------------------------------------------------------------
    push di
    push si
    push ax
    xor di, di
    xor si, si
    xor ax, ax
    mov al, '$'
    push ax
    _whileNotDollar:
        cmp fileBuffer[si], 3bh
        je _whilePopTilDollar ;si es igual a ';' se salta a whilePopTilDollar
        cmp fileBuffer[si], '0'
        jb _verifyOperator ;es menor a 0, debe ser un operador
        cmp fileBuffer[si], '9'
        ja _verifyOperator ;es mayor a 0, debe ser un operador
        mov al, fileBuffer[si] 
        mov postFixOper[di], al ;almacena el numero en la cadena postfija
        inc di
        inc si 
        jmp _whileNotDollar
        _verifyOperator:
            pop ax ;recupera el valor de la pila
            cmp al, '$'
            je _returnToStack ;es igual a '$', es el final de la pila
            prec fileBuffer[si], al ;determina la precedencia de los operandos
            ja _returnToStack ;el operando de filebuffer tiene mayor 
                                     ;precedencia al obtenido de la pila
            mov postFixOper[di], al ;almacena el operando en la cadena postfija
            inc di
            ;mov postFixOper[di+1], '$'
            ;printStrln postFixOper
            ;mov postFixOper[di+1], 00h
            jmp _verifyOperator 
        _returnToStack:
            push ax 
            xor ax, ax
            mov al, fileBuffer[si]
            ;printChar al
            push ax ;mete el operando a la pila
            inc si
            jmp _whileNotDollar ;regresa al proceso original
    _whilePopTilDollar:
        pop ax
        cmp al, '$'
        je _endPostFixed ;es igual al signo de dolar, llegó al final
        ;printChar al
        mov postFixOper[di], al ;almacena el operando en la cadena postfija
        inc di
        jmp _whilePopTilDollar
    _endPostFixed:
        mov postFixOper[di+1], 3bh ;mueve el simbolo ; para especificar el final de la cadena
        ;printStrln postFixOper
        pop ax
        pop si
        pop di
        ret
toPostFixed endp

;------------------------------------------------------------------
calculateExpression proc
; Recorre el arreglo postfijo, recupera el número que representa el
; código ascii y lo apila. 
; Al encontrar un operando, desapila dos números y vuelve a apilar
; el resultado
; Luego desapila el resultado y lo convierte a decimal, apilando
; cada digito (el tope de la pila sería el digito más significativo)
; Al finalizar desapila cada número, suma '0' e imprime el ascii
;------------------------------------------------------------------
    push si
    push ax
    push cx
    push bx
    xor si, si
    xor ax, ax
    xor bx, bx
    xor cx, cx
    _calcTillSemiColon:
        cmp postFixOper[si], 3bh 
        je _calcToAscii
        cmp postFixOper[si], '+'
        je _calcAdd
        cmp postFixOper[si], '-'
        je _calcSub
        cmp postFixOper[si], '*'
        je _calcMul
        cmp postFixOper[si], '/'
        je _calcDiv
    _toBinaryUnit:
        xor eax, eax
        xor ebx, ebx
        cmp cx, 0001h 
        je _toBinaryDec ;ya hay un numero, debe ser decimal
        mov al, postFixOper[si] 
        sub al, '0' ;recupera el número "real"
        mov tempOper, eax ;lo almacena para un posterior uso
        inc cx
        inc si
        jmp _calcTillSemiColon
    _toBinaryDec:
        xor eax, eax
        xor ebx, ebx
        mov eax, tempOper ;recupera el número
        mov ebx, 0ah 
        mul ebx ;lo multiplica pro 10
        mov bl, postFixOper[si]
        sub bl, '0' ;recupera el número "real"
        add eax, ebx ;suma el decena con la unidad
        push eax ;apila el numero
        xor cx, cx ;reinicia el contador
        inc si
        jmp _calcTillSemiColon
    _calcAdd:
        pop ebx ;segundo operando
        pop eax ;primer operando
        add eax, ebx ;opera la suma
        push eax ;guarda el resultado
        inc si
        jmp _calcTillSemiColon
    _calcSub:
        pop ebx ;segundo operando
        pop eax ;primer operando
        sub eax, ebx ;opera la resta
        push eax ;guarda el resultado
        inc si
        jmp _calcTillSemiColon
    _calcMul:
        pop ebx ;segundo operando
        pop eax ;primer operando
        imul ebx ;opera el producto
        push eax ;guarda el resultado
        inc si
        jo _calcErrOverflow ;hubo un desbordamiento
        jmp _calcTillSemiColon
    _calcDiv:
        pop ebx ;segundo operando
        pop eax ;primer operando
        cdq
        cmp ebx, 00h
        je _caclErrDiv0 ;division indefinida
        idiv ebx ;opera la división
        push eax ;guarda el resultado
        inc si
        jmp _calcTillSemiColon
    _calcToAscii:
        mov fileBuffChar, 00h ;almacena un null
        xor cx, cx ;limpia el conteo
        pop eax ;recupera el valor
        push eax ;lo vuelve a meter
        shl eax, 01h ;mueve hacia la izq 1 bit -> eax ya no es igual
        pop eax ;vuelve a recupera el valor a eax
        jnc _calcToAscii1 ;no hay carry -> flujo usual
        mov fileBuffChar, '-' ;almacena el signo menos
        neg eax ;obtiene el complemento a dos
        _calcToAscii1:
            xor ebx, ebx
            mov bl, 0ah
        _calcLoopToAscii:
            cdq
            div ebx      ;divide dentro de 10
            push edx     ;almacena el residuo
            inc cx
            xor edx, edx ;limpia dato
            cmp eax, 00000000h ;eax debe ser igual a 0 para saltar a mostrar el resultado
            jne _calcLoopToAscii
            printStrln operInfoSucc
            printStrln operInfo2
            printStr operInfo2
            printChar fileBuffChar
            jmp _calcShowResult
    _calcErrOverflow:
        printStrln operOverflow
        jmp _calcTillSemiColon ;sigue con la operación
    _caclErrDiv0:
        printStrln operDiviZero
        pauseAnyKey
        jmp _calcEnd
    _calcShowResult:
        pop eax ;digito a acumulador
        add al, '0' ;a ascii
        mov bl, al
        printChar bl ;imprime el caracter
        loop _calcShowResult
        printStrln ln
    _calcEnd:
        pop bx
        pop cx
        pop ax
        pop si
    ret
calculateExpression endp
end main
