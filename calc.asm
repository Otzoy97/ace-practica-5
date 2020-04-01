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

validateNumber macro charArr
LOCAL _vNLoop, _vNLoop1S, _vNLoop1SM, _vNLoop1SP, _vNLoop2S, _vNErr, _vNEnd
    push si
    push cx
    push bx
    xor si, si
    xor cx, cx    
    xor bx, bx
    xor ax, ax
    _vNLoop:
        cmp charArr[si], 00h
        jz _vNEnd
        cmp cl, 00h             ;primer estado
        je _vNLoop1S
        jmp _vNLoop2S           ;salta al 2do estado
        _vNLoop1S:
            cmp charArr[si], '-'
            jz _vNLoop1SM
            cmp charArr[si], '+'
            jz _vNLoop1SP
            cmp charArr[si], '0'
            jb _vNErr
            cmp charArr[si], '9'
            ja _vNErr
            xor ah, ah
            mov al, charArr[si]
            sub al, '0'
            push ax
            inc cl
            inc si
            jmp _vNLoop
            _vNLoop1SM:
                mov ch, 01h
                inc cl
                inc si
                jmp _vNLoop
            _vNLoop1SP:
                mov ch, 00h
                inc cl
                inc si
                jmp _vNLoop
        _vNLoop2S:
            cmp charArr[si], '0'
            jb _vNErr
            cmp charArr[si], '9'
            ja _vNErr
            xor bh, bh
            mov bl, 0ah
            pop ax
            mul bx
            sub charArr[si], '0'
            add al, charArr[si]
            push ax
            inc si
            jmp _vNLoop
    pop ax
    cmp ch, 01h
    jne _vNEnd
    neg al
    jmp _vNEnd
    _vNErr:
        printStr illegalCharOnFile
        printChar charArr[si]
        printStrln ln
        xor ax, ax
    _vNEnd:   
        printChar al
        cmp ax, 00h
        pop si
        pop cx
        pop bx 
endm