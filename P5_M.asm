;IMPRIMIR TEXTO
printStr MACRO charArray
    MOV AH, 09H
    MOV DX, OFFSET charArray
    INT 21H
ENDM

printStrln MACRO charArray
    MOV AH, 09H
    MOV DX, OFFSET charArray
    INT 21H
    ;IMRPIME UNA NUEVA LINEA
    MOV DX, 000AH
    MOV AH, 02H
    INT 21H
    MOV DX, 000DH
    INT 21H
ENDM

printChar MACRO char
    MOV AH, 02H
    XOR DX, DX
    MOV DL, char
    INT 21H
ENDM

flushStr MACRO char_cte, size_cte, char
LOCAL CLEAN
    XOR SI, SI
    XOR CX, CX
    MOV CX, size_cte
    CLEAN:
        MOV char_cte[SI], char
        INC SI
        LOOP CLEAN
ENDM


getLine MACRO charArray
LOCAL GETCHAR, EOS, ERASE
    XOR SI, SI
    GETCHAR:
        MOV AH, 01H
        INT 21H
        CMP AL, 0DH
        JE EOS                  ;SI ES IGUAL A SALTO DE LÍNEA
        CMP AL, 08H
        JE ERASE                ;SI ES IGUAL A BACKSPACE
        MOV charArray[SI], AL   ;AGREGA CHAR A CHARARRAY
        INC SI                  ;SI++
        JMP GETCHAR
    ERASE:
        MOV charArray[SI], 00H  ;MUEVE EN CARACTER NULO
        CMP SI, 00H             
        JE GETCHAR              ;SI, SI ES IGUAL A 0 REGRESARÁ A GETCHAR
        DEC SI                  ;DISMINUYE SI
        MOV charArray[SI], 24H  ;MUEVE UN CARACTER DE FINAL DE STRING
        JMP GETCHAR
    EOS:
        MOV AL, 00H             ;NULL
        MOV charArray[SI], AL
ENDM

; -- COMPARA UNA CADENA charAC DESDE LA POSICION
; -- from1 HASTA LA POSICION to1
compareStr MACRO charAC, charAR
LOCAL _1, _2, _3, _4, _5, _6, _7, _8, _9
    XOR SI, SI
    XOR CX, CX
    MOV AL, 01H
    _1:
        CMP charAC[SI], 24H
        JE _2
        CMP charAC[SI], 00H
        JE _2
        INC SI
        INC CL
        JMP _1
    _2:
        XOR SI, SI
    _3:
        CMP charAR[SI], 24H
        JE _4
        CMP charAR[SI], 00H
        JE _4
        INC SI
        INC CH
        JMP _3
    _4:
        XOR SI, SI
    _5:
        CMP CL, CH
        JNE _8
    _6:
        CMP CL, 00H
        JE _9
    _7:
        MOV AH, charAC[SI]
        CMP AH, charAR[SI]
        JNE _8
        INC SI
        DEC CL
        JMP _6
    _8:
        MOV AL, 00H
    _9:
        CMP AL, 01H
ENDM

toLower MACRO charAC
LOCAL _1, _2, _3, _4
    XOR SI, SI
    _1:
        CMP charAC[SI], 24H ;ES IGUAL A '$'   
        JE _4               
        CMP charAC[SI], 00H ;ES IGUAL A NULL
        JE _4
    _2:
        CMP charAC[SI], 61h ;
        JAE _3              ;SI ES MAYOR O IGUAL A 
        ADD charAC[SI], 20h
    _3:
        INC SI
        JMP _1
    _4:
ENDM

createFile MACRO fileName
    MOV AH, 3CH
    MOV CX, 00H
    MOV DX, OFFSET fileName
    INT 21H
ENDM

writeFile MACRO fileHandler, fileContent, fileSize
    MOV AH, 40H
    MOV BX, fileHandler
    MOV CX, fileSize
    MOV DX, OFFSET fileContent
    INT 21H
ENDM

openFile MACRO  fileName, fileHandler
    MOV AH, 3DH
    MOV AL, 02H
    MOV DX, OFFSET fileName
    INT 21H
    ;ESPECIFICAR ERROR
ENDM

closeFile MACRO fileHandler
LOCAL _1
    MOV AH, 3EH
    MOV BX, fileHandler
    INT 21H
    JNC _1
    printStrln fileEr3
    _1:
ENDM

readFile MACRO fileHandler, fileContent, fileSize
    MOV AH, 3FH
    MOV BX, fileHandler
    MOV CX, fileSize
    MOV DX, OFFSET fileContent
    INT 21H
    ;ESPECIFICAR ERROR
ENDM