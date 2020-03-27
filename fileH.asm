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