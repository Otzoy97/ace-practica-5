prec macro char1, char2
LOCAL _isPlusMinus1, _isProductDivision1, _isPlusMinus2, _isProductDivision2, _isChar2, _isCmp
    push bx
    xor bx, bx
    cmp char1, '+'
    je _isPlusMinus1
    cmp char1, '-'
    je _isPlusMinus1
    cmp char1, '*'
    je _isProductDivision1
    cmp char1, '/'
    je _isProductDivision1
    _isPlusMinus1:
        mov bl, 1h
        jmp _isChar2
    _isProductDivision1:
        mov bl, 2h
    _isChar2:
        cmp char2, '+'
        je _isPlusMinus2
        cmp char2, '-'
        je _isPlusMinus2
        cmp char2, '*'
        je _isProductDivision2
        cmp char2, '/'
        je _isProductDivision2
    _isPlusMinus2:
        mov bh, 1h
        jmp _isCmp
    _isProductDivision2:
        mov bh, 2h
    _isCmp:
        cmp bl, bh
    pop bx
endm

validateNumber macro charArr, temp
LOCAL _vNLoop, _vNLoop1S, _vNLoop1SM, _vNLoop1SP, _vNLoop2S, _vNErr, _vNEnd
    xor si, si
    xor cx, cx    
    xor bx, bx
    xor ax, ax
    .while (charArr[si] != 00h)
        .if (cl == 0)
            .if (charArr[si] == '-')
                mov ch, 01h
                inc cl
                inc si
            .elseif (charArr[si] == '+')
                mov ch, 00h
                inc cl
                inc si
            .elseif (charArr[si] >= '0' && charArr[si] <= '9')
                xor ax, ax
                mov al, charArr[si]
                sub al, '0'
                mov temp, ax
                ;push ax
                inc cl
                inc si
            .else
                jmp _vNErr
            .endif
        .else
            .if (charArr[si] >= '0' && charArr[si] <= '9')
                xor ax, ax
                xor bx, bx
                mov ax, temp
                mov bx, 0ah
                mul bx
                xor bx, bx
                mov bl, charArr[si]
                sub bl, '0'
                add ax, bx
                mov temp, ax
                ;push ax
                inc si
            .else
                jmp _vNErr
            .endif
        .endif
    .endw
    mov ax, temp
    .if (ch == 01)
        neg ax
    .endif
    mov temp , ax
    jmp _vNEnd
    _vNErr:
        printStr illegalCharOnFile
        printChar charArr[si]
        printStrln ln
        xor ax, ax
    _vNEnd:
        cmp ax, 00h
endm