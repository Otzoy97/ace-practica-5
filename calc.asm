prec macro char1, char2
LOCAL _isPlusMinus1, _isProductDivision1, _isPlusMinus2, _isProductDivision2, _isChar2, _isCmp
    push ax
    push bx
    cmp char1, '+'
    je _isPlusMinus1
    cmp char1, '-'
    je _isPlusMinus1
    cmp char1, '*'
    je _isProductDivision1
    cmp char1, '/'
    je _isProductDivision1
    _isPlusMinus1:
        mov ax, 01h
        jmp _isChar2
    _isProductDivision1:
        mov ax, 02h
        jmp _isChar2
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
        mov bx, 01h
        jmp _isCmp
    _isProductDivision2:
        mov bx, 02h
        jmp _isCmp
    _isCmp:
        cmp ax, bx
    pop bx
    pop ax
endm